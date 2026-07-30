// purge-storage — removes storage objects nobody owns any more.
//
// SQL cannot delete storage objects, so the split is: the database decides what
// is garbage (public.list_orphan_storage_objects + public.storage_purge_queue),
// this function deletes it with the service-role key. It never decides on its own.
//
// Invocation:
//   - pg_cron → net.http_post (see 005_storage_purge.sql)
//   - manually with { "dry_run": true } to see what would go
//
// See supabase/templates/sql/005_storage_purge.sql for the orphan rules.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const BUCKET = "avatars";
const DELETE_CHUNK = 100;
const QUEUE_BATCH = 500;
const DEFAULT_MIN_AGE_HOURS = 24;

function mustEnv(key: string): string {
  const value = Deno.env.get(key);
  if (!value) throw new Error(`Missing env: ${key}`);
  return value;
}

const admin = createClient(
  mustEnv("SUPABASE_URL"),
  mustEnv("SUPABASE_SERVICE_ROLE_KEY"),
  { auth: { persistSession: false } },
);

Deno.serve(async (req) => {
  let dryRun = false;
  let minAgeHours = DEFAULT_MIN_AGE_HOURS;

  try {
    const body = await req.json();
    dryRun = body?.dry_run === true;
    if (typeof body?.min_age_hours === "number") {
      minAgeHours = body.min_age_hours;
    }
  } catch {
    // No body = defaults: real delete, 24h age floor.
  }

  const { data, error } = await admin.rpc("list_orphan_storage_objects", {
    p_min_age_hours: minAgeHours,
  });

  if (error) {
    console.error("purge-storage: rpc failed", error.message);
    return Response.json({ error: error.message }, { status: 500 });
  }

  const names: string[] = (data ?? []).map((row: { name: string }) => row.name);

  // Paths captured before their owning rows were deleted. The orphan scan cannot
  // see these — by the time it runs, the ownership link is already gone.
  const { data: queued, error: queueError } = await admin
    .from("storage_purge_queue")
    .select("id, path")
    .is("purged_at", null)
    .limit(QUEUE_BATCH);

  if (queueError) {
    console.error("purge-storage: queue read failed", queueError.message);
    return Response.json({ error: queueError.message }, { status: 500 });
  }

  const queueRows: { id: number; path: string }[] = queued ?? [];

  if (dryRun) {
    console.log(
      `purge-storage: dry run — ${names.length} orphan(s), ${queueRows.length} queued`,
    );
    return Response.json({
      dry_run: true,
      orphans: names.length,
      queued: queueRows.length,
      names,
      queued_paths: queueRows.map((row) => row.path),
    });
  }

  const failures: string[] = [];

  async function removeAll(paths: string[]): Promise<number> {
    let removed = 0;
    for (let i = 0; i < paths.length; i += DELETE_CHUNK) {
      const chunk = paths.slice(i, i + DELETE_CHUNK);
      const { error: removeError } = await admin.storage.from(BUCKET).remove(chunk);
      if (removeError) {
        console.error(`purge-storage: chunk failed — ${removeError.message}`);
        failures.push(removeError.message);
        continue;
      }
      removed += chunk.length;
    }
    return removed;
  }

  const deleted = await removeAll(names);
  const queueDeleted = await removeAll(queueRows.map((row) => row.path));

  // Only mark the queue when every chunk landed — a failed batch has to be
  // retried on the next run, not silently forgotten.
  if (queueDeleted > 0 && failures.length === 0) {
    const { error: markError } = await admin
      .from("storage_purge_queue")
      .update({ purged_at: new Date().toISOString() })
      .in("id", queueRows.map((row) => row.id));
    if (markError) {
      console.error("purge-storage: queue mark failed", markError.message);
      failures.push(markError.message);
    }
  }

  console.log(
    `purge-storage: ${deleted}/${names.length} orphan, ${queueDeleted}/${queueRows.length} queued`,
  );
  return Response.json({
    orphans: names.length,
    deleted,
    queued: queueRows.length,
    queue_deleted: queueDeleted,
    failures,
  });
});

# Supabase

Server side of the app: Postgres (RLS + SECURITY DEFINER RPCs), Realtime, Storage,
and the edge functions below. This directory is a **template seed** — the SQL and
the edge function are canonical starting points, not a live deployment. Wire them
into the next app's own Supabase project, fill the env placeholders, and deploy.

## Edge functions

| Function | Role |
|---|---|
| `send-push/` | Push pipeline worker. Invoked by pg_cron with a batch of `push_outbox` row IDs: loads outbox rows + recipient device tokens, mints an APNs ES256 JWT (cached), builds channel-specific APNs payloads, fans out to APNs per token environment, prunes dead tokens. |
| `feedback/` | The only path between the app and the support channel. Holds the destination's credentials in env secrets, caps the body at 4KB and rate-limits per IP. Deploy with `--no-verify-jwt`: sign-in failures are worth receiving and happen before a session exists. |
| `revenuecat-webhook/` | Subscription state → `users.is_premium` / `premium_until`. Connects with the service-role key, which is what `006_premium.sql`'s guard trigger lets through. Shared secret in `REVENUECAT_AUTH_HEADER`. |
| `purge-storage/` | Deletes storage objects the database marked as garbage (orphan scan + purge queue). SQL cannot delete storage objects; this function is that half. Scheduled by pg_cron, supports `{"dry_run": true}`. |

Deploying an edge function change is mandatory before testing from iOS — local edits
do nothing until deployed.

## Push pipeline — 4 hard rules

Every push-related change must respect all four. Each rule exists because breaking it
produced a production-grade bug in the app this seed was harvested from.

### 1. Hybrid payloads are forbidden
Never combine `aps.alert` with `content-available: 1`. iOS launches the app in
background mode and races the banner tap — a cold launch dies before the first scene
renders.
- Visible push (`apns-push-type: alert`): no `content-available`. The NSE fires via
  `mutable-content: 1`, which is enough for widget reloads.
- Silent push (`apns-push-type: background`): `content-available` required.

### 2. One event = one `push_outbox` row
Never write a silent + a visible row for the same event — delivery order is not
guaranteed, the NSE double-fires, and APNs may drop the silent one. Want a banner
**and** a widget refresh? One row: `channel='visible'` + `kinds=['SomeWidget']` — the
NSE reads `kinds` and reloads timelines.
- Review rule: two `INSERT INTO push_outbox` in one trigger → stop and question it.
- A drain coalescer can group pending rows by (recipient, channel, title key) so
  same-window visible pushes of the same kind merge.

### 3. Deploy order for new loc-keys: client first
If a trigger sends a `visible_title_key`/`visible_body_key` the installed client
doesn't have, iOS shows the RAW KEY in the banner.
- New key: xcstrings + translations → client released ("Ready for Sale") → **then**
  deploy the migration.
- Key already present in shipped versions → early deploy is safe.
- Inverse rule (the RPC exception): if the sender is a client button (an RPC the user
  taps), the migration deploys **before** the client — nobody can call the RPC without
  the button, so there is no window where an old client emits an unknown key.
- Loc-keys resolve in the **system** language, not the app's in-app language selection.

### 4. Silent push / cold-launch race
Silent pushes launch the app in the background, which races the splash. The permanent
defense (harvested as `SplashViewController.startWhenForeground()` + a SceneDelegate
fallback) holds the UI until the app is actually foregrounded:
- `handleSilentPush` must guard `currentUser == nil` (cold launch, session not loaded).
- No heavy work (realtime subscribe, multi-fetch) on background launches.
- Any change adding a silent trigger must pass this device test: trigger silent →
  wait 10s → tap the app **icon** (not a banner) → the splash must flow.

## Migration conventions

- Migrations are numbered `NNN_short_name.sql` (`001`, `002`, …) and applied via the
  Supabase SQL editor in order.
- The **latest migration body is the source of truth** for a function/trigger: always
  edit the newest copy of a definition, never an older one. When a definition changes,
  add a new numbered migration that `CREATE OR REPLACE`s it — the history stays as an
  append-only log, and the highest number wins.
- Templates live under `templates/sql/`. Copy them into the app's real migration
  sequence and renumber as needed.

| Template | Contents |
|---|---|
| `001_users.sql` | `public.users` mirror of `auth.users`, own-row RLS, `delete_my_account()` |
| `002_device_tokens_outbox.sql` | Device tokens + push outbox |
| `003_app_config.sql` | Remote config table, `admins` registry, `is_admin()`, admin-only writes |
| `004_storage.sql` | Private bucket + owner-scoped storage RLS |
| `005_storage_purge.sql` | Purge queue, orphan scan, cron wiring |
| `006_premium.sql` | Premium columns + guard trigger (service-role writes only) |
| `007_items.sql` | Per-user collection: owner RLS, server-stamped `updated_at`, realtime publication |

## Two rules the templates encode

**Storage policies OR together.** One bucket-wide `authenticated` policy cancels every
narrow policy beside it — any signed-in user can then read, overwrite and delete every
object in the bucket. Audit `pg_policy` for leftovers before trusting a narrow policy,
and put the owner id in the object path from day one (`004_storage.sql`). Retrofitting
an owner segment later means moving every existing file.

**Capture file paths before the rows that name them are deleted.** After the delete
there is no way to ask who a file belonged to. `enqueue_storage_paths()` runs inside
the delete path; the orphan scan alone can only catch files whose path carries an owner
(`005_storage_purge.sql`).

## Realtime

A table the app listens to must be in the `supabase_realtime` publication — without it
the channel subscribes happily and never fires. `007_items.sql` shows the idempotent
`alter publication` block to copy.

## Tests

`tests/000_rls_baseline_test.sql` is the regression pattern: one transaction, a temp
`t(no, name, expected, actual)` table, `set_config('request.jwt.claims', …)` to
impersonate users, a final PASS/FAIL render, then `ROLLBACK`. Write the assertions
before a policy migration goes live — "looks right" and "denies the right rows" are
different claims.

-- 005_storage_purge.sql — orphan storage sweep + delete-before-you-lose-the-owner queue.
-- Template. Copy into the app's migration sequence. Requires 004_storage.sql.
--
-- Two mechanisms, because one is not enough:
--
--   1. Orphan sweep — objects whose owner row is gone. Only works when the path
--      carries the owner id (see 004). Runs on a schedule, ignores fresh files.
--
--   2. Purge queue — the row that names the file is about to be deleted, so the
--      path is captured BEFORE the delete. Once the row is gone nobody can ask
--      who the file belonged to; asking afterwards is already too late.
--
-- SQL cannot delete storage objects, so both feed the purge-storage edge function,
-- which does the actual removal with the service-role key.

begin;

-- =====================================================
-- Queue — RLS on with no policies: no client role can read or write it.
-- Reachable only by service_role (bypasses RLS) and SECURITY DEFINER functions.
-- =====================================================
create table if not exists public.storage_purge_queue (
    id          bigserial primary key,
    path        text not null unique,
    enqueued_at timestamptz not null default now(),
    purged_at   timestamptz
);

create index if not exists idx_storage_purge_queue_pending
    on public.storage_purge_queue (id) where purged_at is null;

alter table public.storage_purge_queue enable row level security;
revoke all on public.storage_purge_queue from public, anon, authenticated;

-- =====================================================
-- enqueue_storage_paths — call this from any delete path, before the delete
-- =====================================================
create or replace function public.enqueue_storage_paths(p_paths text[])
returns void
language sql
security definer
set search_path = pg_catalog, public
as $$
    insert into public.storage_purge_queue (path)
    select distinct unnest(p_paths)
    where p_paths is not null
    on conflict (path) do nothing;
$$;
revoke all on function public.enqueue_storage_paths(text[]) from public, anon, authenticated;

-- =====================================================
-- list_orphan_storage_objects — files whose owner no longer exists
-- The empty-users guard is the safety catch: if the users table is empty
-- (restore in progress, wrong database) every file would look orphaned.
-- =====================================================
create or replace function public.list_orphan_storage_objects(p_min_age_hours integer default 24)
returns table(name text)
language plpgsql
stable security definer
set search_path = pg_catalog, public, storage
as $$
declare
    v_cutoff timestamptz := now() - make_interval(hours => greatest(p_min_age_hours, 1));
begin
    if not exists (select 1 from public.users) then
        raise warning 'list_orphan_storage_objects: users table is empty, returning nothing';
        return;
    end if;

    return query
    select o.name
    from storage.objects o
    where o.bucket_id = 'avatars'
      and o.created_at < v_cutoff
      and (
            -- profile_images/{user_id}.{ext}
            (o.name like 'profile_images/%'
             and not exists (
                   select 1 from public.users u
                   where lower(u.user_id::text) = lower(split_part(split_part(o.name, '/', 2), '.', 1))))

            -- user_files/{user_id}/…
         or (o.name like 'user_files/%'
             and not exists (
                   select 1 from public.users u
                   where lower(u.user_id::text) = lower(split_part(o.name, '/', 2))))
      );
end;
$$;

alter function public.list_orphan_storage_objects(integer) owner to postgres;
revoke all on function public.list_orphan_storage_objects(integer) from public, anon, authenticated;
grant execute on function public.list_orphan_storage_objects(integer) to service_role;

-- =====================================================
-- delete_my_account — 001's body plus the enqueue step.
-- Replaced here rather than edited in 001: the newest definition of a function is
-- the source of truth, and 001 must stay runnable on its own.
-- =====================================================
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
    uid uuid := auth.uid();
begin
    if uid is null then
        raise exception 'not authenticated';
    end if;

    -- Capture this account's files while the rows that name them still exist.
    perform public.enqueue_storage_paths(
        array(
            select o.name from storage.objects o
            where o.bucket_id = 'avatars'
              and (o.name like 'profile_images/' || uid::text || '.%'
                or o.name like 'user_files/' || uid::text || '/%')
        )
    );

    -- Delete app-owned public rows first. Add per-app tables here.
    delete from public.users where user_id = uid;

    -- Remove the auth identity last — cascades to anything still referencing it.
    delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_my_account() from public;
grant execute on function public.delete_my_account() to authenticated;

commit;

-- =====================================================
-- Scheduling (run once, in the SQL editor)
-- =====================================================
-- Needs the pg_cron and pg_net extensions, plus the function's own URL and the
-- service-role key. Keep the key out of migrations — paste it here manually.
--
--   select cron.schedule(
--     'purge-storage-daily', '17 3 * * *',
--     $$ select net.http_post(
--          url     := 'https://<project-ref>.supabase.co/functions/v1/purge-storage',
--          headers := jsonb_build_object(
--                       'Content-Type', 'application/json',
--                       'Authorization', 'Bearer <service-role-key>'),
--          body    := '{}'::jsonb) $$);
--
-- Dry run first — it deletes nothing and reports what it would remove:
--   curl -X POST .../functions/v1/purge-storage -d '{"dry_run": true}'

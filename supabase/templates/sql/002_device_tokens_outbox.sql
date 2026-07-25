-- 002_device_tokens_outbox.sql — APNs device tokens + the push outbox the edge
-- function drains. Template. Copy into the app's migration sequence.

-- =====================================================
-- device_tokens
-- The APNs token is the natural key: it is globally unique per app install, so it
-- is the PRIMARY KEY. Re-registration from the same device upserts the same row
-- (client upsert conflicts on the token PK); a different account signing in on the
-- same device flips user_id to the new owner. This subsumes the (user_id, token)
-- uniqueness — a token can only ever exist in one row.
-- =====================================================
create table if not exists public.device_tokens (
    token      text primary key,
    user_id    uuid not null references public.users (user_id) on delete cascade,
    platform   text not null default 'ios',
    updated_at timestamptz not null default now()
);

create index if not exists device_tokens_user_id_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

drop policy if exists device_tokens_select_own on public.device_tokens;
create policy device_tokens_select_own on public.device_tokens
    for select using (auth.uid() = user_id);

drop policy if exists device_tokens_insert_own on public.device_tokens;
create policy device_tokens_insert_own on public.device_tokens
    for insert with check (auth.uid() = user_id);

drop policy if exists device_tokens_update_own on public.device_tokens;
create policy device_tokens_update_own on public.device_tokens
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists device_tokens_delete_own on public.device_tokens;
create policy device_tokens_delete_own on public.device_tokens
    for delete using (auth.uid() = user_id);

-- Sign-out invalidation. The client deletes its own rows directly under the
-- delete-own RLS policy (SupabaseDatabaseHelper.delete on user_id); no RPC needed.
-- Run it BEFORE auth.signOut() so auth.uid() still resolves.

-- =====================================================
-- push_outbox
-- One row = one event (hard rule #2). channel decides the APNs push type; kinds
-- tells the NSE which widget timelines to reload. loc-key columns carry only keys +
-- args — never rendered strings — so no user data lives in the payload.
-- =====================================================
create table if not exists public.push_outbox (
    id                bigint generated always as identity primary key,
    recipient_user_id uuid not null references public.users (user_id) on delete cascade,
    channel           text not null check (channel in ('visible', 'silent')),
    kinds             text[] not null default '{}',
    visible_title_key text,
    visible_body_key  text,
    visible_loc_args  jsonb,
    created_at        timestamptz not null default now(),
    attempts          int not null default 0,
    next_attempt_at   timestamptz not null default now(),
    dispatched_at     timestamptz,
    failed_at         timestamptz,
    last_error        text
);

-- Drain query index: pending = not dispatched, not failed, attempt window open.
create index if not exists push_outbox_pending_idx
    on public.push_outbox (next_attempt_at)
    where dispatched_at is null and failed_at is null;

-- push_outbox is written only by triggers / SECURITY DEFINER functions and drained
-- only by the service-role edge function — no direct client access. RLS on with no
-- policies = deny all for anon/authenticated.
alter table public.push_outbox enable row level security;

-- =====================================================
-- Example: AFTER INSERT trigger that enqueues one visible push (hard rule #2:
-- exactly one push_outbox row per event — never a silent + a visible row for the
-- same event). Commented out; adapt the source table + loc-keys per app, then have
-- pg_cron poll pending rows and invoke the send-push edge function with their ids.
-- =====================================================
-- create or replace function public.enqueue_example_push()
-- returns trigger
-- language plpgsql
-- security definer
-- set search_path = public
-- as $$
-- begin
--     insert into public.push_outbox (
--         recipient_user_id, channel, kinds, visible_title_key, visible_body_key, visible_loc_args
--     ) values (
--         NEW.recipient_user_id,           -- who receives it
--         'visible',                       -- ONE row — banner + widget refresh together
--         array['DemoWidget'],             -- NSE reloads these timelines
--         'push.example.title',            -- client must ship this loc-key first (hard rule #3)
--         'push.example.body',
--         to_jsonb(array[NEW.some_arg]::text[])
--     );
--     return NEW;
-- end;
-- $$;
--
-- create trigger example_after_insert
--     after insert on public.some_source_table
--     for each row execute function public.enqueue_example_push();

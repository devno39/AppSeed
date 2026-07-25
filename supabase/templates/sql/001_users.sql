-- 001_users.sql — public.users mirror of auth.users + own-row RLS + account deletion RPC.
-- Template. Copy into the app's migration sequence and adjust columns to the app's User model.

-- =====================================================
-- Table
-- =====================================================
create table if not exists public.users (
    user_id       uuid primary key references auth.users (id) on delete cascade,
    email         text,
    display_name  text,
    avatar_url    text,
    birth_date    date,
    created_at    timestamptz not null default now(),
    last_login_at timestamptz,
    last_seen_at  timestamptz
);

-- =====================================================
-- Row Level Security — own row only
-- =====================================================
alter table public.users enable row level security;

drop policy if exists users_select_own on public.users;
create policy users_select_own on public.users
    for select using (auth.uid() = user_id);

drop policy if exists users_insert_own on public.users;
create policy users_insert_own on public.users
    for insert with check (auth.uid() = user_id);

drop policy if exists users_update_own on public.users;
create policy users_update_own on public.users
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- =====================================================
-- delete_my_account() — SECURITY DEFINER account deletion
-- Deletes the caller's public rows, then the auth user. Runs as definer so it can
-- reach auth.users; the WHERE clause is pinned to auth.uid() so a caller can only
-- ever delete themselves. FK cascades from auth.users clean up any child rows that
-- reference user_id (e.g. device_tokens).
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

    -- Delete app-owned public rows first. Add per-app tables here.
    delete from public.users where user_id = uid;

    -- Remove the auth identity last — cascades to anything still referencing it.
    delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_my_account() from public;
grant execute on function public.delete_my_account() to authenticated;

-- 003_app_config.sql — remote config table + admin write path.
-- Template. Copy into the app's migration sequence.
--
-- Why this exists: values that must change without shipping a build (force-update
-- floor, feature flags, legal copy). The app reads them through
-- SupabaseAppConfigHelper; a small web panel writes them with the public anon key.
-- All write authority lives in RLS here — never in a client-side secret.
--
-- Post-deploy (manual, one-time — the uid isn't known at migration time):
--   1. Supabase Dashboard → Authentication → Add user (email + password).
--   2. insert into public.admins (user_id)
--        select id from auth.users where email = '<admin-email>';

begin;

-- =====================================================
-- Table
-- =====================================================
create table if not exists public.app_config (
    key         text primary key,
    value       text not null,
    value_type  text not null default 'string',
    description text,
    updated_at  timestamptz not null default now()
);

alter table public.app_config drop constraint if exists app_config_value_type_check;
alter table public.app_config add constraint app_config_value_type_check
    check (value_type in ('string', 'bool', 'int', 'double'));

-- =====================================================
-- Admin registry — RLS-locked with no policies of its own.
-- Only is_admin() (SECURITY DEFINER) ever reads it.
-- =====================================================
create table if not exists public.admins (
    user_id    uuid primary key references auth.users (id) on delete cascade,
    created_at timestamptz not null default now()
);
alter table public.admins enable row level security;

-- SECURITY DEFINER so the lookup bypasses RLS — a plain subquery inside the
-- app_config policy would recurse into that same policy.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
    select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- =====================================================
-- RLS — everyone signed in reads, only admins write
-- =====================================================
alter table public.app_config enable row level security;

drop policy if exists app_config_read on public.app_config;
create policy app_config_read on public.app_config
    for select using (auth.role() = 'authenticated');

drop policy if exists app_config_admin_write on public.app_config;
create policy app_config_admin_write on public.app_config
    for all using (is_admin()) with check (is_admin());

-- =====================================================
-- Audit stamp
-- =====================================================
create or replace function public.app_config_touch()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end $$;

drop trigger if exists app_config_touch_trg on public.app_config;
create trigger app_config_touch_trg
    before insert or update on public.app_config
    for each row execute function public.app_config_touch();

-- =====================================================
-- Seed keys the app already reads
-- =====================================================
insert into public.app_config (key, value, value_type, description) values
    ('minimum_supported_version', '1.0.0', 'string',
     'Below this app version the force-update gate fires on Splash.')
on conflict (key) do nothing;

commit;

-- Verification:
--   A) A non-admin cannot write:
--      set role authenticated;
--      update app_config set value = 'x' where key = 'minimum_supported_version';  -- denied
--      reset role;
--
--   B) After registering an admin, with that admin's JWT:
--      select public.is_admin();   -- true

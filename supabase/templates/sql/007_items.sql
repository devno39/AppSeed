-- 007_items.sql — the shape every per-user collection copies.
-- Template. Copy into the app's migration sequence, rename the table and columns.
--
-- What this demonstrates and the app's own tables should keep:
--   * owner column + own-row RLS on all four verbs
--   * server-stamped updated_at (a client clock must never decide write order)
--   * realtime publication (the app's list listener needs it)
--   * cascade from auth.users so account deletion takes the rows with it

begin;

create table if not exists public.items (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    title      text not null,
    note       text,
    emoji      text,
    is_done    boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_items_user_created
    on public.items (user_id, created_at desc);

-- =====================================================
-- Row Level Security — own rows only
-- =====================================================
alter table public.items enable row level security;

drop policy if exists items_select_own on public.items;
create policy items_select_own on public.items
    for select using (auth.uid() = user_id);

drop policy if exists items_insert_own on public.items;
create policy items_insert_own on public.items
    for insert with check (auth.uid() = user_id);

drop policy if exists items_update_own on public.items;
create policy items_update_own on public.items
    for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists items_delete_own on public.items;
create policy items_delete_own on public.items
    for delete using (auth.uid() = user_id);

-- =====================================================
-- updated_at — stamped by the server, not the client
-- =====================================================
create or replace function public.items_touch()
returns trigger
language plpgsql
as $$
begin
    new.updated_at := now();
    return new;
end $$;

drop trigger if exists items_touch_trg on public.items;
create trigger items_touch_trg
    before insert or update on public.items
    for each row execute function public.items_touch();

-- =====================================================
-- Realtime — without this the list listener never fires
-- =====================================================
do $$
begin
    if not exists (
        select 1 from pg_publication_tables
        where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'items'
    ) then
        alter publication supabase_realtime add table public.items;
    end if;
end $$;

commit;

-- Verification:
--   A) Another user's row is invisible:
--      select count(*) from items where user_id <> auth.uid();   -- 0
--
--   B) The table is published:
--      select tablename from pg_publication_tables where pubname = 'supabase_realtime';

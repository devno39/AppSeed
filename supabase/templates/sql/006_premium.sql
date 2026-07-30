-- 006_premium.sql — server-owned premium state.
-- Template. Copy into the app's migration sequence. Requires 001_users.sql.
--
-- Premium state must never be client-writable. A jailbroken client can flip its
-- own row, and anything that reads premium from the database — a shared view, a
-- server-side gate, an export — then trusts it. The subscription provider's
-- webhook is the only writer; everything else is silently reverted.
--
-- Silent revert instead of an exception, deliberately: already-shipped builds may
-- still try to write these columns, and raising would surface errors to users and
-- back off the provider's webhook retries. The write "succeeds" and changes nothing.

begin;

alter table public.users
    add column if not exists is_premium    boolean not null default false,
    add column if not exists premium_until timestamptz;

create or replace function public.users_premium_guard()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
    -- service_role is the webhook (and manual admin work).
    if auth.role() = 'service_role' then
        return new;
    end if;

    -- A crafted signup must not be able to mint a premium row.
    if tg_op = 'INSERT' then
        new.is_premium := false;
        new.premium_until := null;
        return new;
    end if;

    -- Everything else in the row updates normally; only these two snap back.
    if new.is_premium is distinct from old.is_premium then
        new.is_premium := old.is_premium;
    end if;
    if new.premium_until is distinct from old.premium_until then
        new.premium_until := old.premium_until;
    end if;

    return new;
end;
$$;

alter function public.users_premium_guard() owner to postgres;

-- BEFORE, so the revert lands before any realtime row event fires — subscribers
-- never see a transient premium flip.
drop trigger if exists users_premium_guard on public.users;
create trigger users_premium_guard
    before insert or update on public.users
    for each row execute function public.users_premium_guard();

commit;

-- Verification:
--   A) As an authenticated user, on your own row:
--      update users set is_premium = true where user_id = auth.uid();
--      select is_premium from users where user_id = auth.uid();  -- still false
--
--   B) Trigger is registered BEFORE INSERT OR UPDATE:
--      select tgname, tgtype from pg_trigger where tgrelid = 'public.users'::regclass;

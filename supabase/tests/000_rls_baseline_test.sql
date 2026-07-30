-- 000_rls_baseline_test.sql — regression suite for the seed's own policies.
--
-- Usage: paste into the Supabase SQL Editor after the templates in
-- supabase/templates/sql/ have been applied. Everything runs inside one
-- transaction that ends in ROLLBACK, so it leaves nothing behind. Synthetic
-- users only (aaaa…/bbbb…) — it never touches real rows.
--
-- The pattern to copy for your own migrations:
--   1. temp table `t(no, name, expected, actual)`
--   2. impersonate a user with set_config('request.jwt.claims', …) + SET LOCAL ROLE
--   3. one INSERT INTO t per assertion
--   4. final SELECT renders PASS/FAIL, then ROLLBACK
--
-- Writing the assertions before the migration goes live is the point: a policy
-- that "looks right" and a policy that denies the right rows are different things.

begin;

create temp table t(no int, name text, expected text, actual text) on commit drop;
grant all on t to authenticated;

insert into public.users (user_id, display_name) values
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Test A'),
    ('bbbbbbbb-0000-0000-0000-000000000001', 'Test B');

-- =====================================================
-- users RLS — own row only
-- =====================================================
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}', true);

insert into t values (1, 'sees own row', '1',
    (select count(*) from public.users where user_id = 'aaaaaaaa-0000-0000-0000-000000000001')::text);

insert into t values (2, 'cannot see another user''s row', '0',
    (select count(*) from public.users where user_id = 'bbbbbbbb-0000-0000-0000-000000000001')::text);

update public.users set display_name = 'Hijacked' where user_id = 'bbbbbbbb-0000-0000-0000-000000000001';
reset role;

insert into t values (3, 'cannot update another user''s row', 'Test B',
    (select display_name from public.users where user_id = 'bbbbbbbb-0000-0000-0000-000000000001'));

-- =====================================================
-- premium guard (006_premium.sql) — client writes revert
-- =====================================================
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}', true);
update public.users set is_premium = true where user_id = 'aaaaaaaa-0000-0000-0000-000000000001';
reset role;

insert into t values (4, 'client cannot grant itself premium', 'false',
    (select is_premium from public.users where user_id = 'aaaaaaaa-0000-0000-0000-000000000001')::text);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"cccccccc-0000-0000-0000-000000000001","role":"authenticated"}', true);
insert into public.users (user_id, display_name, is_premium)
values ('cccccccc-0000-0000-0000-000000000001', 'Test C', true);
reset role;

insert into t values (5, 'insert cannot mint a premium row', 'false',
    (select is_premium from public.users where user_id = 'cccccccc-0000-0000-0000-000000000001')::text);

-- =====================================================
-- app_config (003_app_config.sql) — admin-only writes
-- =====================================================
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-0000-0000-000000000001","role":"authenticated"}', true);
update public.app_config set value = '99.0.0' where key = 'minimum_supported_version';
reset role;

insert into t values (6, 'non-admin cannot write app_config', 'false',
    (select (value = '99.0.0')::text from public.app_config where key = 'minimum_supported_version'));

-- The splash reads the version floor before sign-in, so anon must see that row — and
-- only that row.
set local role anon;
select set_config('request.jwt.claims', '', true);

insert into t values (7, 'anon reads the public version floor', '1',
    (select count(*) from public.app_config where key = 'minimum_supported_version')::text);

insert into t values (8, 'anon sees no private config', '0',
    (select count(*) from public.app_config where is_public = false)::text);
reset role;

-- =====================================================
-- Results
-- =====================================================
select no, name, expected, actual,
       case when expected is not distinct from actual then 'PASS' else '*** FAIL ***' end as result
from t order by no;

rollback;

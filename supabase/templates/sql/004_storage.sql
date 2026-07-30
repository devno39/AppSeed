-- 004_storage.sql — private bucket + owner-scoped RLS for user uploads.
-- Template. Copy into the app's migration sequence.
--
-- ⚠️ The rule this file exists to enforce:
--   Storage RLS policies are PERMISSIVE and OR together. One bucket-wide policy
--   ("bucket_id = 'avatars' and auth.role() = 'authenticated'") silently cancels
--   every narrow policy next to it — any signed-in user can then read, overwrite
--   and delete every object in the bucket. Never create a bucket-wide policy, and
--   audit for leftovers before trusting the narrow ones below:
--
--     select polname, polcmd, pg_get_expr(polqual, 'storage.objects'::regclass)
--     from pg_policy where polrelid = 'storage.objects'::regclass order by polname;
--
-- Path convention: put the owner id in the path from day one —
--   profile_images/{user_id}.{ext}      (one file per user, matches SupabaseStorageHelper)
--   user_files/{user_id}/{uuid}.{ext}   (many files per user)
-- Without an owner segment the policy has no way to tell who may delete an object,
-- and retrofitting it later means moving every existing file.

begin;

-- =====================================================
-- Bucket — private; the app hands out signed URLs
-- =====================================================
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', false)
on conflict (id) do nothing;

-- =====================================================
-- profile_images/{user_id}.{ext}
-- Reads stay open to any signed-in user: SupabaseStorageHelper re-signs expired
-- URLs, and that has to keep working for other people's avatars. Writes are the
-- destructive surface, so those are pinned to the owner.
-- =====================================================
drop policy if exists profile_images_select on storage.objects;
create policy profile_images_select on storage.objects
    for select to authenticated
    using (bucket_id = 'avatars' and name like 'profile_images/%');

drop policy if exists profile_images_insert_own on storage.objects;
create policy profile_images_insert_own on storage.objects
    for insert to authenticated
    with check (
        bucket_id = 'avatars'
        and name like 'profile_images/%'
        and lower(split_part(split_part(name, '/', 2), '.', 1)) = lower((auth.uid())::text)
    );

drop policy if exists profile_images_update_own on storage.objects;
create policy profile_images_update_own on storage.objects
    for update to authenticated
    using (
        bucket_id = 'avatars'
        and name like 'profile_images/%'
        and lower(split_part(split_part(name, '/', 2), '.', 1)) = lower((auth.uid())::text)
    )
    with check (
        bucket_id = 'avatars'
        and name like 'profile_images/%'
        and lower(split_part(split_part(name, '/', 2), '.', 1)) = lower((auth.uid())::text)
    );

drop policy if exists profile_images_delete_own on storage.objects;
create policy profile_images_delete_own on storage.objects
    for delete to authenticated
    using (
        bucket_id = 'avatars'
        and name like 'profile_images/%'
        and lower(split_part(split_part(name, '/', 2), '.', 1)) = lower((auth.uid())::text)
    );

-- =====================================================
-- user_files/{user_id}/… — fully owner-scoped, read included
-- Enable this prefix for anything that isn't meant to be visible to others.
-- =====================================================
drop policy if exists user_files_own on storage.objects;
create policy user_files_own on storage.objects
    for all to authenticated
    using (
        bucket_id = 'avatars'
        and name like 'user_files/%'
        and lower(split_part(name, '/', 2)) = lower((auth.uid())::text)
    )
    with check (
        bucket_id = 'avatars'
        and name like 'user_files/%'
        and lower(split_part(name, '/', 2)) = lower((auth.uid())::text)
    );

commit;

-- Verification:
--   A) No bucket-wide policy survives:
--      select polname from pg_policy where polrelid = 'storage.objects'::regclass;
--      -- expect only the profile_images_* / user_files_* names above
--
--   B) Another user's avatar cannot be deleted:
--      delete from storage.objects
--      where bucket_id = 'avatars' and name = 'profile_images/<other-uuid>.png';  -- 0 rows

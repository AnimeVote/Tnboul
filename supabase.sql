-- TunLine database and storage setup
-- Run this entire file in Supabase Dashboard > SQL Editor.

create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) between 1 and 160),
  poster_path text not null,
  created_at timestamptz not null default now()
);

alter table public.entries enable row level security;

drop policy if exists "Public can read entries" on public.entries;
create policy "Public can read entries"
on public.entries for select
to anon, authenticated
using (true);

drop policy if exists "Only TunLine admin can insert entries" on public.entries;
create policy "Only TunLine admin can insert entries"
on public.entries for insert
to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Only TunLine admin can update entries" on public.entries;
create policy "Only TunLine admin can update entries"
on public.entries for update
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "Only TunLine admin can delete entries" on public.entries;
create policy "Only TunLine admin can delete entries"
on public.entries for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Public read access for poster images; only Admin can upload, replace or delete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('posters', 'posters', true, 8388608, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = true,
  file_size_limit = 8388608,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Public can view TunLine posters" on storage.objects;
create policy "Public can view TunLine posters"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'posters');

drop policy if exists "Only TunLine admin can upload posters" on storage.objects;
create policy "Only TunLine admin can upload posters"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'posters'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

drop policy if exists "Only TunLine admin can update posters" on storage.objects;
create policy "Only TunLine admin can update posters"
on storage.objects for update
to authenticated
using (
  bucket_id = 'posters'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
)
with check (
  bucket_id = 'posters'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

drop policy if exists "Only TunLine admin can delete posters" on storage.objects;
create policy "Only TunLine admin can delete posters"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'posters'
  and (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- After creating your one Admin user in Authentication > Users,
-- replace the email below with that exact email and run this separately:
-- update auth.users
-- set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
-- where email = 'YOUR_ADMIN_EMAIL';
--
-- Do NOT put a service_role key in index.html.

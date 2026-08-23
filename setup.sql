-- Moderated wedding wishes for a static GitHub Pages site.
-- Safe to run more than once in the Supabase SQL editor.

create extension if not exists pgcrypto;
create schema if not exists private;
revoke all on schema private from public;

create table if not exists public.wishes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  message text not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null,
  constraint wishes_name_length check (char_length(name) between 1 and 80),
  constraint wishes_name_trimmed check (name = btrim(name)),
  constraint wishes_message_length check (char_length(message) between 1 and 1000),
  constraint wishes_message_trimmed check (message = btrim(message)),
  constraint wishes_status_allowed check (status in ('pending', 'approved', 'rejected')),
  constraint wishes_review_state check (
    (status = 'pending' and reviewed_at is null and reviewed_by is null)
    or
    (status in ('approved', 'rejected') and reviewed_at is not null and reviewed_by is not null)
  )
);

create table if not exists public.wish_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  added_at timestamptz not null default now()
);

create index if not exists wishes_public_feed_idx
  on public.wishes (created_at desc)
  where status = 'approved';

create index if not exists wishes_moderation_queue_idx
  on public.wishes (status, created_at desc);

alter table public.wishes enable row level security;
alter table public.wish_admins enable row level security;

-- Remove the earlier RPC-based helper if this project used a prior draft.
drop policy if exists "Admins can read every wish" on public.wishes;
drop policy if exists "Admins can moderate wishes" on public.wishes;
drop policy if exists "Admins can delete wishes" on public.wishes;
drop function if exists public.is_wish_admin();

drop trigger if exists stamp_wish_review_before_write on public.wishes;
drop function if exists public.stamp_wish_review();

create or replace function private.stamp_wish_review()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    new.created_at := old.created_at;
    new.name := old.name;
    new.message := old.message;
  end if;

  if new.status = 'pending' then
    new.reviewed_at := null;
    new.reviewed_by := null;
  else
    new.reviewed_at := now();
    new.reviewed_by := auth.uid();
  end if;

  return new;
end;
$$;

create trigger stamp_wish_review_before_write
before insert or update on public.wishes
for each row execute function private.stamp_wish_review();

drop policy if exists "Public can read approved wishes" on public.wishes;
create policy "Public can read approved wishes"
on public.wishes
for select
to anon, authenticated
using (status = 'approved');

drop policy if exists "Anyone can submit pending wishes" on public.wishes;
create policy "Anyone can submit pending wishes"
on public.wishes
for insert
to anon, authenticated
with check (
  status = 'pending'
  and reviewed_at is null
  and reviewed_by is null
);

drop policy if exists "Admins can read every wish" on public.wishes;
create policy "Admins can read every wish"
on public.wishes
for select
to authenticated
using (
  exists (
    select 1 from public.wish_admins
    where user_id = (select auth.uid())
  )
);

drop policy if exists "Admins can moderate wishes" on public.wishes;
create policy "Admins can moderate wishes"
on public.wishes
for update
to authenticated
using (
  exists (
    select 1 from public.wish_admins
    where user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.wish_admins
    where user_id = (select auth.uid())
  )
);

drop policy if exists "Admins can delete wishes" on public.wishes;
create policy "Admins can delete wishes"
on public.wishes
for delete
to authenticated
using (
  exists (
    select 1 from public.wish_admins
    where user_id = (select auth.uid())
  )
);

drop policy if exists "Users can read their own admin membership" on public.wish_admins;
create policy "Users can read their own admin membership"
on public.wish_admins
for select
to authenticated
using (user_id = (select auth.uid()));

revoke all on table public.wishes from anon, authenticated;
grant select (id, name, message, status, created_at) on table public.wishes to anon;
grant select (id, name, message, status, created_at, reviewed_at, reviewed_by) on table public.wishes to authenticated;
grant insert (name, message) on table public.wishes to anon, authenticated;
grant update (status) on table public.wishes to authenticated;
grant delete on table public.wishes to authenticated;

revoke all on table public.wish_admins from anon, authenticated;
grant select (user_id) on table public.wish_admins to authenticated;

-- After creating the admin in Authentication > Users, replace the email below
-- and run this statement separately:
-- insert into public.wish_admins (user_id)
-- select id from auth.users where email = 'YOUR_ADMIN_EMAIL';

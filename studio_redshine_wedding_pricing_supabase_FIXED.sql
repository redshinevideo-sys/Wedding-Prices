-- Studio Redshine Wedding Builder: shared cloud pricing (FIXED)
-- Run this in the EXISTING Studio Redshine Supabase project.
-- Safe to run repeatedly. Does not delete or reset business data.
-- Fixes the missing public.is_admin() function error.

-- 1) Make sure the existing profile/role table exists.
--    If your V3 migration already created this table, this does nothing.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'staff' check (role in ('admin','staff')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- 2) Create the admin-check function required by the pricing RLS policies.
--    SECURITY DEFINER prevents the function from being blocked by profiles RLS.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

grant execute on function public.is_admin() to anon, authenticated;

-- 3) Shared pricing table.
create table if not exists public.wedding_pricing_config (
  id integer primary key default 1 check (id = 1),
  config jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.wedding_pricing_config enable row level security;

-- 4) Public customer builder can READ the current price list.
drop policy if exists wedding_pricing_public_read on public.wedding_pricing_config;
create policy wedding_pricing_public_read
on public.wedding_pricing_config
for select
using (true);

-- 5) Only a Studio Redshine Administrator can WRITE prices.
drop policy if exists wedding_pricing_admin_insert on public.wedding_pricing_config;
create policy wedding_pricing_admin_insert
on public.wedding_pricing_config
for insert
with check (public.is_admin());

drop policy if exists wedding_pricing_admin_update on public.wedding_pricing_config;
create policy wedding_pricing_admin_update
on public.wedding_pricing_config
for update
using (public.is_admin())
with check (public.is_admin());

-- 6) Required Data API table permissions.
grant select on public.wedding_pricing_config to anon, authenticated;
grant insert, update on public.wedding_pricing_config to authenticated;

-- 7) Create the single shared pricing row if it does not exist yet.
insert into public.wedding_pricing_config (id, config)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- Done.
-- Next: open the Studio Redshine admin-pricing.html page,
-- sign in with your Admin account, and save prices.

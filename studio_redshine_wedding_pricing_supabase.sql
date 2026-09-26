-- Studio Redshine Wedding Builder: shared cloud pricing
-- Uses the existing Studio Redshine Supabase project.
-- Safe: adds only one new table and its RLS policies.

create table if not exists public.wedding_pricing_config (
  id integer primary key default 1 check (id = 1),
  config jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.wedding_pricing_config enable row level security;

-- Public customer builder must be able to read the current price list.
drop policy if exists wedding_pricing_public_read on public.wedding_pricing_config;
create policy wedding_pricing_public_read
on public.wedding_pricing_config
for select
using (true);

-- Only an authenticated Studio Redshine Administrator can write prices.
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

insert into public.wedding_pricing_config (id, config)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

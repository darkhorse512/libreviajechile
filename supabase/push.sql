-- =============================================================================
-- Libre Viaje Chile — Notificaciones push (tokens de dispositivo)
-- Ejecuta este script en el SQL Editor de Supabase (después de schema.sql).
-- =============================================================================

create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null references public.profiles (id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);

create index if not exists device_tokens_user_idx
  on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

-- Cada usuario administra solo sus propios tokens. La Edge Function usa la
-- service role key y omite RLS para leer los tokens de los conductores.
drop policy if exists "device_tokens manage own" on public.device_tokens;
create policy "device_tokens manage own" on public.device_tokens
  for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

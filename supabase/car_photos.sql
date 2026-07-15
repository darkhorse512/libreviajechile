-- =============================================================================
-- Fotos del auto del conductor (URLs en Cloudflare R2).
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================
alter table public.driver_details
  add column if not exists car_photos text[] not null default '{}';

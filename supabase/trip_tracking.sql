-- =============================================================================
-- Seguimiento del viaje: "voy en camino", "llegué" y ubicación en vivo.
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================
alter table public.trips
  add column if not exists driver_on_way boolean not null default false,
  add column if not exists driver_arrived_at timestamptz,
  add column if not exists driver_lat double precision,
  add column if not exists driver_lng double precision;

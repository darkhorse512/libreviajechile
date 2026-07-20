-- =============================================================================
-- Presencia del conductor en vivo (ubicación + última vez visto).
-- Se usa para:
--   · distribuir solicitudes solo a conductores cercanos al punto de partida, y
--   · mostrar conductores disponibles en el mapa del pasajero en tiempo real.
--
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================
alter table public.driver_details
  add column if not exists last_lat   double precision,
  add column if not exists last_lng   double precision,
  add column if not exists last_seen  timestamptz;

-- Índice para consultar rápidamente a los conductores en línea y recientes.
create index if not exists driver_details_online_seen_idx
  on public.driver_details (is_online, last_seen);

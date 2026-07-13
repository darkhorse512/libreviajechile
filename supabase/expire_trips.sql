-- =============================================================================
-- Expiración automática de solicitudes de viaje
-- -----------------------------------------------------------------------------
-- Cancela los viajes que llevan más de 5 minutos en estado 'requested' sin que
-- el pasajero haya aceptado una oferta. Funciona aunque la app esté cerrada
-- (la app también corre una cuenta regresiva del lado del cliente).
--
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================

-- Función que cancela las solicitudes vencidas.
create or replace function public.expire_stale_trips()
returns void
language sql
security definer
set search_path = public
as $$
  update public.trips
     set status = 'cancelled',
         updated_at = now()
   where status = 'requested'
     and created_at < now() - interval '5 minutes';
$$;

-- Programación cada minuto con pg_cron (extensión disponible en Supabase).
create extension if not exists pg_cron;

-- Evita duplicar el job si ya existe.
do $$
begin
  perform cron.unschedule('expire-stale-trips');
exception when others then null;
end $$;

select cron.schedule(
  'expire-stale-trips',
  '* * * * *', -- cada minuto
  $$ select public.expire_stale_trips(); $$
);

-- Nota: si prefieres BORRAR físicamente en lugar de cancelar, reemplaza el
-- cuerpo de expire_stale_trips() por:
--   delete from public.trips
--    where status = 'requested' and created_at < now() - interval '5 minutes';

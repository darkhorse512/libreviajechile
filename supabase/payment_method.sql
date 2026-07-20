-- =============================================================================
-- Método de pago elegido por el pasajero al solicitar el viaje.
-- Es informativo (la app no procesa el cobro): el conductor lo ve para saber
-- cómo cobrará. Valores: cash, pago_rut, mercado_pago, banco_santander, mach,
-- tenpo.
--
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================
alter table public.trips
  add column if not exists payment_method text not null default 'cash';

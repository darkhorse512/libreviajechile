-- =============================================================================
-- Verificación de pasajeros (KYC).
-- El pasajero sube su documento de identidad (frente y reverso) tras
-- registrarse; queda en estado 'pending' y NO puede solicitar viajes hasta que
-- un administrador lo apruebe. Espeja el sistema de verificación de conductores
-- (driver_details) pero sobre la tabla profiles.
--
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================

alter table public.profiles
  add column if not exists verification_status text not null default 'pending'
    check (verification_status in ('pending', 'approved', 'rejected')),
  add column if not exists doc_id_front                 text,
  add column if not exists doc_id_back                  text,
  add column if not exists verification_rejection_reason text,
  add column if not exists verification_submitted_at    timestamptz,
  add column if not exists verification_reviewed_at     timestamptz;

-- Grandfather: los usuarios YA existentes se dan por aprobados para no
-- bloquear a quienes ya usan la app. Solo los registros NUEVOS (default
-- 'pending' del trigger handle_new_user) requerirán aprobación.
update public.profiles
  set verification_status = 'approved'
  where verification_status = 'pending';

create index if not exists profiles_verification_status_idx
  on public.profiles (verification_status);

-- Refuerzo a nivel de base de datos: un pasajero NO aprobado no puede crear
-- viajes, aunque burle la app.
drop policy if exists "trips insert own" on public.trips;
create policy "trips insert own" on public.trips
  for insert with check (
    passenger_id = auth.uid()
    and exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.verification_status = 'approved'
    )
  );

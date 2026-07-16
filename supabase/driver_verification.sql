-- =============================================================================
-- Verificación de conductores (KYC).
-- El conductor sube 4 documentos (imagen o PDF) tras registrarse; queda en
-- estado 'pending' y NO puede aceptar viajes hasta que un admin lo apruebe.
--
-- Ejecuta este script UNA VEZ en el SQL Editor de Supabase.
-- =============================================================================

alter table public.driver_details
  add column if not exists status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  add column if not exists doc_car_front        text,
  add column if not exists doc_license          text,
  add column if not exists doc_vehicle_reg      text,
  add column if not exists doc_vehicle_reg_back text,
  add column if not exists rejection_reason     text,
  add column if not exists submitted_at         timestamptz,
  add column if not exists reviewed_at          timestamptz;

-- Grandfather: los conductores YA existentes se dan por aprobados para no
-- bloquear a quienes ya están operando. Solo los registros NUEVOS (default
-- 'pending' del trigger handle_new_user) requerirán aprobación.
update public.driver_details
  set status = 'approved'
  where status = 'pending';

-- Mantén is_verified (usado como "insignia" en la app) sincronizado.
update public.driver_details
  set is_verified = (status = 'approved');

create index if not exists driver_details_status_idx
  on public.driver_details (status);

-- Refuerzo a nivel de base de datos: un conductor NO aprobado no puede crear
-- ofertas (aceptar viajes), aunque burle la app.
drop policy if exists "offers insert driver" on public.offers;
create policy "offers insert driver" on public.offers
  for insert with check (
    driver_id = auth.uid()
    and exists (select 1 from public.trips t where t.id = trip_id and t.status = 'requested')
    and exists (
      select 1 from public.driver_details d
      where d.id = auth.uid() and d.status = 'approved'
    )
  );

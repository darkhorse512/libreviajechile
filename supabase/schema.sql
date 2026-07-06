-- =============================================================================
-- Libre Viaje Chile — Esquema de base de datos (Supabase / PostgreSQL)
-- =============================================================================
-- Ejecuta este script en el SQL Editor de tu proyecto Supabase.
-- Incluye: tablas, enums, RLS, triggers de perfil y agregados de calificación,
-- y la función transaccional accept_offer().
-- =============================================================================

-- ----- Extensiones -----------------------------------------------------------
create extension if not exists "uuid-ossp";

-- ----- Enums -----------------------------------------------------------------
do $$ begin
  create type user_role as enum ('passenger', 'driver', 'admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type trip_status as enum ('requested', 'accepted', 'in_progress', 'completed', 'cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type offer_kind as enum ('accept', 'counter');
exception when duplicate_object then null; end $$;

do $$ begin
  create type offer_status as enum ('pending', 'accepted', 'rejected', 'withdrawn');
exception when duplicate_object then null; end $$;

-- ----- profiles --------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  role         user_role not null default 'passenger',
  full_name    text not null default '',
  phone        text,
  city         text,
  avatar_url   text,
  rating_avg   numeric(3,2) not null default 0,
  rating_count integer not null default 0,
  trips_count  integer not null default 0,
  is_banned    boolean not null default false,
  created_at   timestamptz not null default now()
);

-- ----- driver_details --------------------------------------------------------
create table if not exists public.driver_details (
  id             uuid primary key references public.profiles (id) on delete cascade,
  make           text not null,
  model          text not null,
  year           integer not null,
  color          text not null,
  plate          text not null,
  seats          integer not null default 4,
  license_number text,
  is_online      boolean not null default false,
  is_verified    boolean not null default false,
  updated_at     timestamptz not null default now()
);

-- ----- trips -----------------------------------------------------------------
create table if not exists public.trips (
  id                  uuid primary key default uuid_generate_v4(),
  passenger_id        uuid not null references public.profiles (id) on delete cascade,
  driver_id           uuid references public.profiles (id),
  city                text not null,
  origin_address      text not null,
  origin_lat          double precision,
  origin_lng          double precision,
  destination_address text not null,
  destination_lat     double precision,
  destination_lng     double precision,
  offered_fare        integer not null check (offered_fare >= 1500),
  final_fare          integer,
  passengers          integer not null default 1,
  note                text,
  status              trip_status not null default 'requested',
  accepted_offer_id   uuid,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);
create index if not exists trips_city_status_idx on public.trips (city, status);
create index if not exists trips_passenger_idx on public.trips (passenger_id);
create index if not exists trips_driver_idx on public.trips (driver_id);

-- ----- offers ----------------------------------------------------------------
create table if not exists public.offers (
  id          uuid primary key default uuid_generate_v4(),
  trip_id     uuid not null references public.trips (id) on delete cascade,
  driver_id   uuid not null references public.profiles (id) on delete cascade,
  amount      integer not null check (amount >= 1500),
  kind        offer_kind not null default 'accept',
  message     text,
  eta_minutes integer,
  status      offer_status not null default 'pending',
  created_at  timestamptz not null default now(),
  unique (trip_id, driver_id)
);
create index if not exists offers_trip_idx on public.offers (trip_id);

-- ----- ratings ---------------------------------------------------------------
create table if not exists public.ratings (
  id         uuid primary key default uuid_generate_v4(),
  trip_id    uuid not null references public.trips (id) on delete cascade,
  rater_id   uuid not null references public.profiles (id) on delete cascade,
  ratee_id   uuid references public.profiles (id) on delete cascade,
  stars      integer not null check (stars between 1 and 5),
  comment    text,
  created_at timestamptz not null default now(),
  unique (trip_id, rater_id)
);

-- =============================================================================
-- Triggers
-- =============================================================================

-- Crea automáticamente un perfil al registrarse un usuario en auth.users.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_role user_role := coalesce((new.raw_user_meta_data ->> 'role')::user_role, 'passenger');
  v_meta jsonb := new.raw_user_meta_data;
begin
  insert into public.profiles (id, role, full_name, phone, city)
  values (
    new.id,
    v_role,
    coalesce(v_meta ->> 'full_name', ''),
    v_meta ->> 'phone',
    v_meta ->> 'city'
  )
  on conflict (id) do update set
    role      = excluded.role,
    full_name = excluded.full_name,
    phone     = coalesce(excluded.phone, public.profiles.phone),
    city      = coalesce(excluded.city, public.profiles.city);

  -- Si es conductor y llegó la info del vehículo en la metadata, crea/actualiza
  -- driver_details automáticamente.
  if v_role = 'driver' and (v_meta ? 'make') then
    insert into public.driver_details (id, make, model, year, color, plate, seats)
    values (
      new.id,
      coalesce(v_meta ->> 'make', ''),
      coalesce(v_meta ->> 'model', ''),
      coalesce((v_meta ->> 'year')::int, extract(year from now())::int),
      coalesce(v_meta ->> 'color', ''),
      upper(coalesce(v_meta ->> 'plate', '')),
      coalesce((v_meta ->> 'seats')::int, 4)
    )
    on conflict (id) do update set
      make = excluded.make, model = excluded.model, year = excluded.year,
      color = excluded.color, plate = excluded.plate, seats = excluded.seats;
  end if;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Determina el "calificado" (ratee) y recalcula el promedio del perfil.
create or replace function public.handle_new_rating()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_ratee uuid;
begin
  select case when t.passenger_id = new.rater_id then t.driver_id
              else t.passenger_id end
    into v_ratee
  from public.trips t where t.id = new.trip_id;

  new.ratee_id := v_ratee;

  if v_ratee is not null then
    update public.profiles p set
      rating_count = p.rating_count + 1,
      rating_avg   = round(((p.rating_avg * p.rating_count) + new.stars)::numeric
                           / (p.rating_count + 1), 2)
    where p.id = v_ratee;
  end if;
  return new;
end $$;

drop trigger if exists on_rating_created on public.ratings;
create trigger on_rating_created
  before insert on public.ratings
  for each row execute function public.handle_new_rating();

-- =============================================================================
-- Función transaccional: aceptar una oferta
-- =============================================================================
create or replace function public.accept_offer(p_trip_id uuid, p_offer_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_offer public.offers%rowtype;
begin
  select * into v_offer from public.offers where id = p_offer_id and trip_id = p_trip_id;
  if not found then raise exception 'Oferta no encontrada'; end if;

  -- El viaje debe pertenecer al usuario autenticado y estar abierto.
  if not exists (
    select 1 from public.trips
    where id = p_trip_id and passenger_id = auth.uid() and status = 'requested'
  ) then
    raise exception 'No autorizado o el viaje ya no está disponible';
  end if;

  update public.trips set
    status = 'accepted',
    driver_id = v_offer.driver_id,
    final_fare = v_offer.amount,
    accepted_offer_id = p_offer_id,
    updated_at = now()
  where id = p_trip_id;

  update public.offers set status = 'accepted' where id = p_offer_id;
  update public.offers set status = 'rejected'
    where trip_id = p_trip_id and id <> p_offer_id and status = 'pending';
end $$;

-- =============================================================================
-- Row Level Security
-- =============================================================================
alter table public.profiles       enable row level security;
alter table public.driver_details enable row level security;
alter table public.trips          enable row level security;
alter table public.offers         enable row level security;
alter table public.ratings        enable row level security;

-- Helper: ¿es admin el usuario actual?
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- ----- profiles -----
drop policy if exists "profiles read" on public.profiles;
create policy "profiles read" on public.profiles
  for select using (true); -- perfiles públicos (nombre, rating) para mostrar en viajes

drop policy if exists "profiles update self" on public.profiles;
create policy "profiles update self" on public.profiles
  for update using (auth.uid() = id or public.is_admin());

drop policy if exists "profiles insert self" on public.profiles;
create policy "profiles insert self" on public.profiles
  for insert with check (auth.uid() = id);

-- ----- driver_details -----
drop policy if exists "driver read" on public.driver_details;
create policy "driver read" on public.driver_details for select using (true);

drop policy if exists "driver write self" on public.driver_details;
create policy "driver write self" on public.driver_details
  for all using (auth.uid() = id or public.is_admin())
  with check (auth.uid() = id or public.is_admin());

-- ----- trips -----
-- Conductores ven viajes abiertos; pasajero/conductor asignado ven los suyos.
drop policy if exists "trips read" on public.trips;
create policy "trips read" on public.trips for select using (
  status = 'requested'
  or passenger_id = auth.uid()
  or driver_id = auth.uid()
  or public.is_admin()
);

drop policy if exists "trips insert own" on public.trips;
create policy "trips insert own" on public.trips
  for insert with check (passenger_id = auth.uid());

drop policy if exists "trips update participants" on public.trips;
create policy "trips update participants" on public.trips
  for update using (
    passenger_id = auth.uid() or driver_id = auth.uid() or public.is_admin()
  );

-- ----- offers -----
drop policy if exists "offers read participants" on public.offers;
create policy "offers read participants" on public.offers for select using (
  driver_id = auth.uid()
  or exists (select 1 from public.trips t where t.id = trip_id and t.passenger_id = auth.uid())
  or public.is_admin()
);

drop policy if exists "offers insert driver" on public.offers;
create policy "offers insert driver" on public.offers
  for insert with check (
    driver_id = auth.uid()
    and exists (select 1 from public.trips t where t.id = trip_id and t.status = 'requested')
  );

drop policy if exists "offers update driver" on public.offers;
create policy "offers update driver" on public.offers
  for update using (driver_id = auth.uid() or public.is_admin());

-- ----- ratings -----
drop policy if exists "ratings read" on public.ratings;
create policy "ratings read" on public.ratings for select using (true);

drop policy if exists "ratings insert participant" on public.ratings;
create policy "ratings insert participant" on public.ratings
  for insert with check (
    rater_id = auth.uid()
    and exists (
      select 1 from public.trips t
      where t.id = trip_id
        and (t.passenger_id = auth.uid() or t.driver_id = auth.uid())
        and t.status = 'completed'
    )
  );

-- =============================================================================
-- Realtime: publica las tablas necesarias
-- =============================================================================
do $$ begin
  alter publication supabase_realtime add table public.trips;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.offers;
exception when duplicate_object then null; end $$;

-- Listo. Recuerda crear tu primer usuario admin manualmente:
--   update public.profiles set role = 'admin' where id = '<uuid-del-usuario>';

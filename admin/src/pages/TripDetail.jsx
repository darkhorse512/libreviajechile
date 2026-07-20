import { useParams, Link } from 'react-router-dom'
import {
  ArrowLeft,
  MapPin,
  Users as UsersIcon,
  StickyNote,
  Star,
  Clock,
  Wallet,
} from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { clp, dateTime } from '../lib/format'

const PAYMENT_LABELS = {
  cash: 'Efectivo',
  pago_rut: 'PagoRUT',
  mercado_pago: 'Mercado Pago',
  banco_santander: 'Banco Santander',
  mach: 'MACH',
  tenpo: 'Tenpo',
}
import { tripStatusMeta, offerStatusMeta } from '../lib/constants'
import { Card, Spinner, Badge, Avatar, EmptyState } from '../components/ui'
import TripMap from '../components/TripMap'

async function fetchTrip(id) {
  const [tripRes, offersRes, ratingsRes] = await Promise.all([
    supabase
      .from('trips')
      .select(
        '*, passenger:profiles!passenger_id(full_name, avatar_url, phone, rating_avg), ' +
          'driver:profiles!driver_id(full_name, avatar_url, phone, rating_avg)',
      )
      .eq('id', id)
      .maybeSingle(),
    supabase
      .from('offers')
      .select('*, driver:profiles(full_name, avatar_url, rating_avg)')
      .eq('trip_id', id)
      .order('created_at', { ascending: true }),
    supabase
      .from('ratings')
      .select('*, rater:profiles!rater_id(full_name), ratee:profiles!ratee_id(full_name)')
      .eq('trip_id', id),
  ])
  if (tripRes.error) throw tripRes.error
  return {
    trip: tripRes.data,
    offers: offersRes.data ?? [],
    ratings: ratingsRes.data ?? [],
  }
}

function InfoRow({ icon: Icon, label, children }) {
  return (
    <div className="flex items-center gap-3 py-2.5">
      <Icon size={18} className="shrink-0 text-slate-400" />
      <span className="text-sm text-slate-500">{label}</span>
      <span className="ml-auto text-sm font-semibold text-slate-800">{children}</span>
    </div>
  )
}

function Person({ role, person }) {
  if (!person) {
    return (
      <div className="rounded-xl border border-dashed border-slate-200 p-3 text-sm text-slate-400">
        {role}: sin asignar
      </div>
    )
  }
  return (
    <div className="flex items-center gap-3 rounded-xl bg-slate-50 p-3">
      <Avatar name={person.full_name} src={person.avatar_url} size={40} />
      <div className="min-w-0">
        <p className="text-xs uppercase tracking-wide text-slate-400">{role}</p>
        <p className="truncate font-semibold text-slate-800">{person.full_name}</p>
      </div>
      <span className="ml-auto inline-flex items-center gap-1 text-sm text-slate-600">
        <Star size={13} className="fill-star text-star" />
        {Number(person.rating_avg ?? 0).toFixed(1)}
      </span>
    </div>
  )
}

export default function TripDetail() {
  const { id } = useParams()
  const { data, loading, error } = useQuery(() => fetchTrip(id), [id])

  if (loading) return <Spinner label="Cargando viaje…" />
  if (error || !data?.trip)
    return (
      <div>
        <BackLink />
        <EmptyState title="Viaje no encontrado" message={error} />
      </div>
    )

  const { trip, offers, ratings } = data
  const meta = tripStatusMeta(trip.status)
  const hasRoute =
    trip.origin_lat != null &&
    trip.origin_lng != null &&
    trip.destination_lat != null &&
    trip.destination_lng != null

  return (
    <div className="animate-fade-in">
      <BackLink />
      <div className="mb-6 flex flex-wrap items-center gap-3">
        <h1 className="text-2xl font-bold text-navy">Detalle del viaje</h1>
        <Badge className={meta.className}>{meta.label}</Badge>
        <span className="text-sm text-slate-400">#{String(trip.id).slice(0, 8)}</span>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Columna principal */}
        <div className="space-y-4 lg:col-span-2">
          {hasRoute ? (
            <Card className="overflow-hidden">
              <TripMap
                origin={[trip.origin_lat, trip.origin_lng]}
                destination={[trip.destination_lat, trip.destination_lng]}
                height={320}
              />
            </Card>
          ) : (
            <Card className="p-6 text-center text-sm text-slate-400">
              Este viaje no tiene coordenadas guardadas para mostrar el mapa.
            </Card>
          )}

          {/* Ruta */}
          <Card className="p-5">
            <div className="flex gap-3">
              <div className="flex flex-col items-center pt-1">
                <span className="h-3 w-3 rounded-full border-2 border-brand bg-brand/20" />
                <span className="my-1 w-0.5 flex-1 bg-slate-200" style={{ minHeight: 28 }} />
                <MapPin size={16} className="text-danger" />
              </div>
              <div className="flex-1 space-y-4">
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Origen</p>
                  <p className="font-medium text-slate-800">{trip.origin_address}</p>
                </div>
                <div>
                  <p className="text-xs font-semibold uppercase tracking-wide text-slate-400">Destino</p>
                  <p className="font-medium text-slate-800">{trip.destination_address}</p>
                </div>
              </div>
            </div>
          </Card>

          {/* Ofertas */}
          <Card className="p-5">
            <h3 className="mb-3 text-sm font-semibold text-slate-700">
              Ofertas recibidas ({offers.length})
            </h3>
            {offers.length === 0 ? (
              <p className="py-4 text-center text-sm text-slate-400">Aún no hay ofertas.</p>
            ) : (
              <div className="space-y-2">
                {offers.map((o) => {
                  const om = offerStatusMeta(o.status)
                  return (
                    <div key={o.id} className="flex items-center gap-3 rounded-xl border border-slate-100 p-3">
                      <Avatar name={o.driver?.full_name} src={o.driver?.avatar_url} size={38} />
                      <div className="min-w-0 flex-1">
                        <p className="truncate font-medium text-slate-800">
                          {o.driver?.full_name || 'Conductor'}
                        </p>
                        <p className="text-xs text-slate-400">
                          {o.kind === 'counter' ? 'Contraoferta' : 'Aceptó tarifa'}
                          {o.eta_minutes != null && ` · ${o.eta_minutes} min`}
                        </p>
                      </div>
                      <div className="text-right">
                        <p className="font-bold text-amber-600">{clp(o.amount)}</p>
                        <Badge className={om.className}>{om.label}</Badge>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </Card>

          {/* Calificaciones */}
          {ratings.length > 0 && (
            <Card className="p-5">
              <h3 className="mb-3 text-sm font-semibold text-slate-700">Calificaciones</h3>
              <div className="space-y-2">
                {ratings.map((r) => (
                  <div key={r.id} className="rounded-xl bg-slate-50 p-3">
                    <div className="flex items-center gap-2">
                      <span className="inline-flex items-center gap-0.5">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star
                            key={i}
                            size={14}
                            className={i < r.stars ? 'fill-star text-star' : 'text-slate-300'}
                          />
                        ))}
                      </span>
                      <span className="text-sm text-slate-500">
                        {r.rater?.full_name} → {r.ratee?.full_name}
                      </span>
                    </div>
                    {r.comment && <p className="mt-1 text-sm italic text-slate-600">“{r.comment}”</p>}
                  </div>
                ))}
              </div>
            </Card>
          )}
        </div>

        {/* Columna lateral */}
        <div className="space-y-4">
          <Card className="p-5">
            <h3 className="mb-2 text-sm font-semibold text-slate-700">Resumen</h3>
            <div className="divide-y divide-slate-100">
              <InfoRow icon={Star} label="Tarifa final">
                <span className="text-amber-600">{clp(trip.final_fare ?? trip.offered_fare)}</span>
              </InfoRow>
              <InfoRow icon={UsersIcon} label="Pasajeros">
                {trip.passengers}
              </InfoRow>
              <InfoRow icon={Wallet} label="Método de pago">
                {PAYMENT_LABELS[trip.payment_method] ?? 'Efectivo'}
              </InfoRow>
              <InfoRow icon={MapPin} label="Ciudad">
                {trip.city}
              </InfoRow>
              <InfoRow icon={Clock} label="Creado">
                {dateTime(trip.created_at)}
              </InfoRow>
            </div>
            {trip.note && (
              <div className="mt-3 flex gap-2 rounded-xl bg-amber-50 p-3 text-sm text-amber-800">
                <StickyNote size={16} className="mt-0.5 shrink-0" />
                <span>{trip.note}</span>
              </div>
            )}
          </Card>

          <Card className="space-y-3 p-5">
            <h3 className="text-sm font-semibold text-slate-700">Participantes</h3>
            <Person role="Pasajero" person={trip.passenger} />
            <Person role="Conductor" person={trip.driver} />
          </Card>
        </div>
      </div>
    </div>
  )
}

function BackLink() {
  return (
    <Link
      to="/viajes"
      className="mb-4 inline-flex items-center gap-1.5 text-sm font-medium text-slate-500 hover:text-slate-800"
    >
      <ArrowLeft size={16} />
      Volver a viajes
    </Link>
  )
}

import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { Route as RouteIcon, RefreshCw, ChevronRight, MapPin } from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { clp, number, relative } from '../lib/format'
import { tripStatusMeta, TRIP_STATUS } from '../lib/constants'
import {
  Card,
  PageHeader,
  Spinner,
  Badge,
  EmptyState,
  SearchInput,
} from '../components/ui'

async function fetchTrips() {
  const { data, error } = await supabase
    .from('trips')
    .select(
      'id, city, origin_address, destination_address, offered_fare, final_fare, ' +
        'passengers, status, created_at, ' +
        'passenger:profiles!passenger_id(full_name), driver:profiles!driver_id(full_name)',
    )
    .order('created_at', { ascending: false })
    .limit(500)
  if (error) throw error
  return data ?? []
}

export default function Trips() {
  const { data, loading, error, refetch } = useQuery(fetchTrips, [])
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('all')
  const [city, setCity] = useState('all')

  const cities = useMemo(() => {
    if (!data) return []
    return [...new Set(data.map((t) => t.city).filter(Boolean))].sort()
  }, [data])

  const filtered = useMemo(() => {
    if (!data) return []
    const q = search.trim().toLowerCase()
    return data.filter((t) => {
      if (status !== 'all' && t.status !== status) return false
      if (city !== 'all' && t.city !== city) return false
      if (!q) return true
      return (
        t.origin_address?.toLowerCase().includes(q) ||
        t.destination_address?.toLowerCase().includes(q) ||
        t.passenger?.full_name?.toLowerCase().includes(q) ||
        t.driver?.full_name?.toLowerCase().includes(q)
      )
    })
  }, [data, search, status, city])

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Viajes"
        subtitle={data ? `${number(data.length)} viajes (últimos 500)` : 'Cargando…'}
        actions={
          <button onClick={refetch} className="btn-outline">
            <RefreshCw size={16} />
            Actualizar
          </button>
        }
      />

      <Card className="mb-4 p-4">
        <div className="flex flex-col gap-3 lg:flex-row lg:items-center">
          <div className="flex-1">
            <SearchInput
              value={search}
              onChange={setSearch}
              placeholder="Buscar por dirección, pasajero o conductor…"
            />
          </div>
          <select value={city} onChange={(e) => setCity(e.target.value)} className="input sm:w-48">
            <option value="all">Todas las ciudades</option>
            {cities.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
          <select value={status} onChange={(e) => setStatus(e.target.value)} className="input sm:w-48">
            <option value="all">Todos los estados</option>
            {Object.entries(TRIP_STATUS).map(([value, meta]) => (
              <option key={value} value={value}>
                {meta.label}
              </option>
            ))}
          </select>
        </div>
      </Card>

      <Card className="overflow-hidden">
        {loading ? (
          <Spinner label="Cargando viajes…" />
        ) : error ? (
          <EmptyState title="Error al cargar" message={error} />
        ) : filtered.length === 0 ? (
          <EmptyState icon={RouteIcon} title="Sin viajes" message="No hay viajes que coincidan con el filtro." />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-5 py-3 font-semibold">Ruta</th>
                  <th className="px-5 py-3 font-semibold">Pasajero</th>
                  <th className="px-5 py-3 font-semibold">Conductor</th>
                  <th className="px-5 py-3 font-semibold">Tarifa</th>
                  <th className="px-5 py-3 font-semibold">Estado</th>
                  <th className="px-5 py-3 font-semibold">Creado</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((t) => {
                  const meta = tripStatusMeta(t.status)
                  return (
                    <tr key={t.id} className="group hover:bg-slate-50/70">
                      <td className="px-5 py-3">
                        <Link to={`/viajes/${t.id}`} className="block">
                          <p className="flex items-center gap-1.5 font-medium text-slate-800">
                            <MapPin size={13} className="text-brand" />
                            <span className="max-w-[220px] truncate">{t.origin_address}</span>
                          </p>
                          <p className="flex items-center gap-1.5 text-slate-500">
                            <MapPin size={13} className="text-danger" />
                            <span className="max-w-[220px] truncate">{t.destination_address}</span>
                          </p>
                          <p className="mt-0.5 text-xs text-slate-400">{t.city}</p>
                        </Link>
                      </td>
                      <td className="px-5 py-3 text-slate-600">{t.passenger?.full_name || '—'}</td>
                      <td className="px-5 py-3 text-slate-600">{t.driver?.full_name || '—'}</td>
                      <td className="px-5 py-3">
                        <span className="font-semibold text-amber-600">
                          {clp(t.final_fare ?? t.offered_fare)}
                        </span>
                      </td>
                      <td className="px-5 py-3">
                        <Badge className={meta.className}>{meta.label}</Badge>
                      </td>
                      <td className="px-5 py-3 text-slate-500">{relative(t.created_at)}</td>
                      <td className="px-5 py-3 text-right">
                        <Link
                          to={`/viajes/${t.id}`}
                          className="inline-grid h-8 w-8 place-items-center rounded-lg text-slate-400 hover:bg-slate-200 hover:text-slate-600"
                        >
                          <ChevronRight size={18} />
                        </Link>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  )
}

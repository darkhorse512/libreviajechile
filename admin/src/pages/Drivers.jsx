import { useMemo, useState } from 'react'
import { Car, BadgeCheck, RefreshCw, Circle } from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { number } from '../lib/format'
import {
  Card,
  PageHeader,
  Spinner,
  Badge,
  Avatar,
  EmptyState,
  SearchInput,
  Toggle,
} from '../components/ui'

async function fetchDrivers() {
  const { data, error } = await supabase
    .from('driver_details')
    .select(
      'id, make, model, year, color, plate, seats, license_number, is_online, is_verified, ' +
        'profile:profiles(full_name, phone, city, avatar_url, rating_avg, rating_count, trips_count, is_banned)',
    )
    .order('updated_at', { ascending: false })
  if (error) throw error
  return data ?? []
}

const FILTERS = [
  { value: 'all', label: 'Todos' },
  { value: 'verified', label: 'Verificados' },
  { value: 'unverified', label: 'Sin verificar' },
  { value: 'online', label: 'En línea' },
]

export default function Drivers() {
  const { data, loading, error, refetch, setData } = useQuery(fetchDrivers, [])
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('all')
  const [savingId, setSavingId] = useState(null)

  const filtered = useMemo(() => {
    if (!data) return []
    const q = search.trim().toLowerCase()
    return data.filter((d) => {
      if (filter === 'verified' && !d.is_verified) return false
      if (filter === 'unverified' && d.is_verified) return false
      if (filter === 'online' && !d.is_online) return false
      if (!q) return true
      return (
        d.profile?.full_name?.toLowerCase().includes(q) ||
        d.plate?.toLowerCase().includes(q) ||
        `${d.make} ${d.model}`.toLowerCase().includes(q) ||
        d.profile?.city?.toLowerCase().includes(q)
      )
    })
  }, [data, search, filter])

  const stats = useMemo(() => {
    if (!data) return { total: 0, verified: 0, online: 0 }
    return {
      total: data.length,
      verified: data.filter((d) => d.is_verified).length,
      online: data.filter((d) => d.is_online).length,
    }
  }, [data])

  const toggleVerify = async (driver, next) => {
    setSavingId(driver.id)
    const { error } = await supabase
      .from('driver_details')
      .update({ is_verified: next })
      .eq('id', driver.id)
    setSavingId(null)
    if (!error) {
      setData((prev) =>
        prev.map((d) => (d.id === driver.id ? { ...d, is_verified: next } : d)),
      )
    }
  }

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Conductores"
        subtitle={
          data
            ? `${number(stats.total)} conductores · ${number(stats.verified)} verificados · ${number(stats.online)} en línea`
            : 'Cargando…'
        }
        actions={
          <button onClick={refetch} className="btn-outline">
            <RefreshCw size={16} />
            Actualizar
          </button>
        }
      />

      <Card className="mb-4 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
          <div className="flex-1">
            <SearchInput
              value={search}
              onChange={setSearch}
              placeholder="Buscar por nombre, patente, vehículo o ciudad…"
            />
          </div>
          <div className="flex flex-wrap gap-1.5">
            {FILTERS.map((f) => (
              <button
                key={f.value}
                onClick={() => setFilter(f.value)}
                className={`rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
                  filter === f.value
                    ? 'bg-navy text-white'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {loading ? (
        <Spinner label="Cargando conductores…" />
      ) : error ? (
        <EmptyState title="Error al cargar" message={error} />
      ) : filtered.length === 0 ? (
        <EmptyState icon={Car} title="Sin conductores" message="No hay conductores que coincidan con el filtro." />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {filtered.map((d) => (
            <Card key={d.id} className="p-5 transition-shadow hover:shadow-card-hover">
              <div className="flex items-start gap-3">
                <Avatar name={d.profile?.full_name} src={d.profile?.avatar_url} size={48} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-1.5">
                    <p className="truncate font-semibold text-slate-800">
                      {d.profile?.full_name || 'Conductor'}
                    </p>
                    {d.is_verified && <BadgeCheck size={16} className="shrink-0 text-brand" />}
                  </div>
                  <p className="text-xs text-slate-400">{d.profile?.city || '—'}</p>
                </div>
                <span
                  className={`inline-flex items-center gap-1 text-xs font-medium ${
                    d.is_online ? 'text-emerald-600' : 'text-slate-400'
                  }`}
                >
                  <Circle size={8} className={d.is_online ? 'fill-emerald-500 text-emerald-500' : 'fill-slate-300 text-slate-300'} />
                  {d.is_online ? 'En línea' : 'Offline'}
                </span>
              </div>

              <div className="mt-4 rounded-xl bg-slate-50 p-3">
                <div className="flex items-center gap-2 text-sm">
                  <Car size={16} className="text-slate-400" />
                  <span className="font-medium text-slate-700">
                    {d.make} {d.model} {d.year}
                  </span>
                </div>
                <div className="mt-2 flex flex-wrap gap-2 text-xs">
                  <Badge className="bg-white text-slate-600 ring-1 ring-slate-200">
                    Patente {d.plate}
                  </Badge>
                  <Badge className="bg-white text-slate-600 ring-1 ring-slate-200">
                    {d.color}
                  </Badge>
                  <Badge className="bg-white text-slate-600 ring-1 ring-slate-200">
                    {d.seats} asientos
                  </Badge>
                </div>
              </div>

              <div className="mt-4 flex items-center justify-between">
                <div className="text-xs text-slate-500">
                  <span className="font-semibold text-slate-700">
                    {Number(d.profile?.rating_avg ?? 0).toFixed(1)}★
                  </span>{' '}
                  · {d.profile?.trips_count ?? 0} viajes
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-xs font-medium text-slate-500">Verificado</span>
                  <Toggle
                    checked={d.is_verified}
                    disabled={savingId === d.id}
                    onChange={(next) => toggleVerify(d, next)}
                  />
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}

import { useMemo } from 'react'
import {
  Users as UsersIcon,
  Car,
  Route as RouteIcon,
  DollarSign,
  TrendingUp,
  RefreshCw,
  Wifi,
} from 'lucide-react'
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
} from 'recharts'
import { format, subDays, isSameDay } from 'date-fns'
import { es } from 'date-fns/locale'
import { Link } from 'react-router-dom'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { clp, number, relative } from '../lib/format'
import { tripStatusMeta } from '../lib/constants'
import { Card, PageHeader, Spinner, Badge, EmptyState } from '../components/ui'

const STATUS_COLORS = {
  requested: '#0060C4',
  accepted: '#4FBE2A',
  in_progress: '#F59E0B',
  completed: '#2FA84F',
  cancelled: '#E5484D',
}

async function fetchDashboard() {
  const [
    usersTotal,
    passengers,
    driversTotal,
    driversOnline,
    driversVerified,
    tripsRes,
  ] = await Promise.all([
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'passenger'),
    supabase.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'driver'),
    supabase.from('driver_details').select('*', { count: 'exact', head: true }).eq('is_online', true),
    supabase.from('driver_details').select('*', { count: 'exact', head: true }).eq('is_verified', true),
    supabase
      .from('trips')
      .select('id, status, final_fare, offered_fare, city, created_at, origin_address, destination_address')
      .order('created_at', { ascending: false }),
  ])

  const trips = tripsRes.data ?? []
  return {
    usersTotal: usersTotal.count ?? 0,
    passengers: passengers.count ?? 0,
    driversTotal: driversTotal.count ?? 0,
    driversOnline: driversOnline.count ?? 0,
    driversVerified: driversVerified.count ?? 0,
    trips,
  }
}

function StatCard({ icon: Icon, label, value, sub, tint }) {
  return (
    <Card className="p-5">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-slate-500">{label}</p>
          <p className="mt-1 text-3xl font-extrabold tracking-tight text-navy">
            {value}
          </p>
          {sub && <p className="mt-1 text-xs text-slate-400">{sub}</p>}
        </div>
        <div className={`grid h-11 w-11 place-items-center rounded-xl ${tint}`}>
          <Icon size={22} />
        </div>
      </div>
    </Card>
  )
}

function ChartCard({ title, children, className = '' }) {
  return (
    <Card className={`p-5 ${className}`}>
      <h3 className="mb-4 text-sm font-semibold text-slate-700">{title}</h3>
      {children}
    </Card>
  )
}

export default function Dashboard() {
  const { data, loading, error, refetch } = useQuery(fetchDashboard, [])

  const derived = useMemo(() => {
    if (!data) return null
    const trips = data.trips
    const completed = trips.filter((t) => t.status === 'completed')
    const revenue = completed.reduce((sum, t) => sum + (t.final_fare ?? 0), 0)

    // Serie de últimos 14 días.
    const days = Array.from({ length: 14 }, (_, i) => subDays(new Date(), 13 - i))
    const series = days.map((d) => ({
      label: format(d, 'd MMM', { locale: es }),
      viajes: trips.filter((t) => isSameDay(new Date(t.created_at), d)).length,
    }))

    // Por estado.
    const byStatus = Object.keys(STATUS_COLORS)
      .map((status) => ({
        status,
        name: tripStatusMeta(status).label,
        value: trips.filter((t) => t.status === status).length,
      }))
      .filter((s) => s.value > 0)

    // Top ciudades.
    const cityMap = {}
    for (const t of trips) {
      if (!t.city) continue
      cityMap[t.city] = (cityMap[t.city] ?? 0) + 1
    }
    const topCities = Object.entries(cityMap)
      .map(([city, count]) => ({ city, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 6)

    return { revenue, completed: completed.length, series, byStatus, topCities, recent: trips.slice(0, 6) }
  }, [data])

  if (loading) return <Spinner label="Cargando métricas…" />
  if (error)
    return (
      <EmptyState title="No se pudo cargar el dashboard" message={error} />
    )

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Dashboard"
        subtitle="Resumen general de la plataforma"
        actions={
          <button onClick={refetch} className="btn-outline">
            <RefreshCw size={16} />
            Actualizar
          </button>
        }
      />

      {/* KPIs */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          icon={UsersIcon}
          label="Usuarios totales"
          value={number(data.usersTotal)}
          sub={`${number(data.passengers)} pasajeros · ${number(data.driversTotal)} conductores`}
          tint="bg-accent-soft text-accent-dark"
        />
        <StatCard
          icon={RouteIcon}
          label="Viajes totales"
          value={number(data.trips.length)}
          sub={`${number(derived.completed)} completados`}
          tint="bg-brand-soft text-brand-dark"
        />
        <StatCard
          icon={DollarSign}
          label="Ingresos (completados)"
          value={clp(derived.revenue)}
          sub="Suma de tarifas finales"
          tint="bg-amber-100 text-amber-600"
        />
        <StatCard
          icon={Wifi}
          label="Conductores en línea"
          value={number(data.driversOnline)}
          sub={`${number(data.driversVerified)} verificados`}
          tint="bg-emerald-100 text-emerald-600"
        />
      </div>

      {/* Charts */}
      <div className="mt-6 grid gap-4 lg:grid-cols-3">
        <ChartCard title="Viajes · últimos 14 días" className="lg:col-span-2">
          <ResponsiveContainer width="100%" height={260}>
            <AreaChart data={derived.series} margin={{ left: -20, right: 8, top: 8 }}>
              <defs>
                <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#4FBE2A" stopOpacity={0.35} />
                  <stop offset="100%" stopColor="#4FBE2A" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eef2f6" />
              <XAxis
                dataKey="label"
                tick={{ fontSize: 11, fill: '#94a3b8' }}
                axisLine={false}
                tickLine={false}
                interval="preserveStartEnd"
              />
              <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} allowDecimals={false} />
              <Tooltip
                contentStyle={{ borderRadius: 12, border: '1px solid #e2e8f0', fontSize: 13 }}
                labelStyle={{ fontWeight: 600 }}
              />
              <Area
                type="monotone"
                dataKey="viajes"
                stroke="#4FBE2A"
                strokeWidth={2.5}
                fill="url(#g)"
              />
            </AreaChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard title="Viajes por estado">
          {derived.byStatus.length === 0 ? (
            <EmptyState title="Sin viajes aún" />
          ) : (
            <>
              <ResponsiveContainer width="100%" height={200}>
                <PieChart>
                  <Pie
                    data={derived.byStatus}
                    dataKey="value"
                    nameKey="name"
                    innerRadius={55}
                    outerRadius={85}
                    paddingAngle={2}
                  >
                    {derived.byStatus.map((s) => (
                      <Cell key={s.status} fill={STATUS_COLORS[s.status]} />
                    ))}
                  </Pie>
                  <Tooltip contentStyle={{ borderRadius: 12, border: '1px solid #e2e8f0', fontSize: 13 }} />
                </PieChart>
              </ResponsiveContainer>
              <div className="mt-2 space-y-1.5">
                {derived.byStatus.map((s) => (
                  <div key={s.status} className="flex items-center gap-2 text-sm">
                    <span
                      className="h-2.5 w-2.5 rounded-full"
                      style={{ background: STATUS_COLORS[s.status] }}
                    />
                    <span className="text-slate-600">{s.name}</span>
                    <span className="ml-auto font-semibold text-slate-800">{s.value}</span>
                  </div>
                ))}
              </div>
            </>
          )}
        </ChartCard>
      </div>

      {/* Ciudades + actividad reciente */}
      <div className="mt-4 grid gap-4 lg:grid-cols-3">
        <ChartCard title="Ciudades con más viajes" className="lg:col-span-2">
          {derived.topCities.length === 0 ? (
            <EmptyState title="Sin datos de ciudades" />
          ) : (
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={derived.topCities} margin={{ left: -20, right: 8 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eef2f6" />
                <XAxis dataKey="city" tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis tick={{ fontSize: 11, fill: '#94a3b8' }} axisLine={false} tickLine={false} allowDecimals={false} />
                <Tooltip
                  cursor={{ fill: '#f1f5f9' }}
                  contentStyle={{ borderRadius: 12, border: '1px solid #e2e8f0', fontSize: 13 }}
                />
                <Bar dataKey="count" name="Viajes" fill="#0060C4" radius={[6, 6, 0, 0]} maxBarSize={48} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </ChartCard>

        <Card className="p-5">
          <div className="mb-4 flex items-center gap-2">
            <TrendingUp size={16} className="text-brand" />
            <h3 className="text-sm font-semibold text-slate-700">Actividad reciente</h3>
          </div>
          {derived.recent.length === 0 ? (
            <EmptyState title="Sin viajes recientes" />
          ) : (
            <div className="space-y-3">
              {derived.recent.map((t) => {
                const meta = tripStatusMeta(t.status)
                return (
                  <Link
                    key={t.id}
                    to={`/viajes/${t.id}`}
                    className="flex items-center gap-3 rounded-xl p-2 -mx-2 hover:bg-slate-50"
                  >
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm font-medium text-slate-700">
                        {t.origin_address} → {t.destination_address}
                      </p>
                      <p className="text-xs text-slate-400">{relative(t.created_at)}</p>
                    </div>
                    <Badge className={meta.className}>{meta.label}</Badge>
                  </Link>
                )
              })}
            </div>
          )}
        </Card>
      </div>
    </div>
  )
}

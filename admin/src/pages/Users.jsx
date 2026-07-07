import { useMemo, useState } from 'react'
import { Users as UsersIcon, Ban, ShieldCheck, Star, RefreshCw } from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { dateShort, number } from '../lib/format'
import { roleMeta } from '../lib/constants'
import {
  Card,
  PageHeader,
  Spinner,
  Badge,
  Avatar,
  EmptyState,
  SearchInput,
  Modal,
} from '../components/ui'

const ROLE_FILTERS = [
  { value: 'all', label: 'Todos' },
  { value: 'passenger', label: 'Pasajeros' },
  { value: 'driver', label: 'Conductores' },
  { value: 'admin', label: 'Admins' },
]

async function fetchUsers() {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data ?? []
}

export default function Users() {
  const { data, loading, error, refetch, setData } = useQuery(fetchUsers, [])
  const [search, setSearch] = useState('')
  const [role, setRole] = useState('all')
  const [target, setTarget] = useState(null) // usuario a banear/desbanear
  const [working, setWorking] = useState(false)

  const filtered = useMemo(() => {
    if (!data) return []
    const q = search.trim().toLowerCase()
    return data.filter((u) => {
      if (role !== 'all' && u.role !== role) return false
      if (!q) return true
      return (
        u.full_name?.toLowerCase().includes(q) ||
        u.phone?.toLowerCase().includes(q) ||
        u.city?.toLowerCase().includes(q)
      )
    })
  }, [data, search, role])

  const toggleBan = async () => {
    if (!target) return
    setWorking(true)
    const next = !target.is_banned
    const { error } = await supabase
      .from('profiles')
      .update({ is_banned: next })
      .eq('id', target.id)
    setWorking(false)
    if (!error) {
      setData((prev) =>
        prev.map((u) => (u.id === target.id ? { ...u, is_banned: next } : u)),
      )
      setTarget(null)
    }
  }

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Usuarios"
        subtitle={data ? `${number(data.length)} cuentas registradas` : 'Cargando…'}
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
              placeholder="Buscar por nombre, teléfono o ciudad…"
            />
          </div>
          <div className="flex flex-wrap gap-1.5">
            {ROLE_FILTERS.map((f) => (
              <button
                key={f.value}
                onClick={() => setRole(f.value)}
                className={`rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
                  role === f.value
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

      <Card className="overflow-hidden">
        {loading ? (
          <Spinner label="Cargando usuarios…" />
        ) : error ? (
          <EmptyState title="Error al cargar" message={error} />
        ) : filtered.length === 0 ? (
          <EmptyState icon={UsersIcon} title="Sin resultados" message="Prueba con otro filtro o término de búsqueda." />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-5 py-3 font-semibold">Usuario</th>
                  <th className="px-5 py-3 font-semibold">Rol</th>
                  <th className="px-5 py-3 font-semibold">Ciudad</th>
                  <th className="px-5 py-3 font-semibold">Rating</th>
                  <th className="px-5 py-3 font-semibold">Viajes</th>
                  <th className="px-5 py-3 font-semibold">Registro</th>
                  <th className="px-5 py-3 font-semibold text-right">Acción</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filtered.map((u) => {
                  const rm = roleMeta(u.role)
                  return (
                    <tr key={u.id} className="hover:bg-slate-50/70">
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-3">
                          <Avatar name={u.full_name} src={u.avatar_url} size={38} />
                          <div className="min-w-0">
                            <p className="flex items-center gap-1.5 font-semibold text-slate-800">
                              {u.full_name || 'Sin nombre'}
                              {u.is_banned && (
                                <Badge className="bg-red-100 text-red-600">Baneado</Badge>
                              )}
                            </p>
                            <p className="text-xs text-slate-400">{u.phone || '—'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="px-5 py-3">
                        <Badge className={rm.className}>{rm.label}</Badge>
                      </td>
                      <td className="px-5 py-3 text-slate-600">{u.city || '—'}</td>
                      <td className="px-5 py-3">
                        <span className="inline-flex items-center gap-1 text-slate-700">
                          <Star size={13} className="fill-star text-star" />
                          {Number(u.rating_avg ?? 0).toFixed(1)}
                          <span className="text-xs text-slate-400">({u.rating_count ?? 0})</span>
                        </span>
                      </td>
                      <td className="px-5 py-3 text-slate-600">{u.trips_count ?? 0}</td>
                      <td className="px-5 py-3 text-slate-500">{dateShort(u.created_at)}</td>
                      <td className="px-5 py-3 text-right">
                        {u.role === 'admin' ? (
                          <span className="text-xs text-slate-400">—</span>
                        ) : u.is_banned ? (
                          <button
                            onClick={() => setTarget(u)}
                            className="btn inline-flex px-3 py-1.5 text-xs font-semibold text-emerald-600 hover:bg-emerald-50"
                          >
                            <ShieldCheck size={14} />
                            Reactivar
                          </button>
                        ) : (
                          <button
                            onClick={() => setTarget(u)}
                            className="btn inline-flex px-3 py-1.5 text-xs font-semibold text-red-600 hover:bg-red-50"
                          >
                            <Ban size={14} />
                            Banear
                          </button>
                        )}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      <Modal
        open={Boolean(target)}
        onClose={() => !working && setTarget(null)}
        title={target?.is_banned ? 'Reactivar cuenta' : 'Banear cuenta'}
      >
        <p className="text-sm text-slate-600">
          {target?.is_banned ? (
            <>
              ¿Deseas reactivar la cuenta de{' '}
              <span className="font-semibold">{target?.full_name}</span>? Podrá
              volver a usar la plataforma.
            </>
          ) : (
            <>
              ¿Deseas banear a{' '}
              <span className="font-semibold">{target?.full_name}</span>? No podrá
              iniciar sesión ni operar en la plataforma.
            </>
          )}
        </p>
        <div className="mt-6 flex justify-end gap-2">
          <button onClick={() => setTarget(null)} className="btn-outline" disabled={working}>
            Cancelar
          </button>
          <button
            onClick={toggleBan}
            disabled={working}
            className={`btn px-4 py-2.5 text-white ${
              target?.is_banned ? 'bg-emerald-600 hover:bg-emerald-700' : 'bg-danger hover:brightness-95'
            }`}
          >
            {working ? 'Guardando…' : target?.is_banned ? 'Sí, reactivar' : 'Sí, banear'}
          </button>
        </div>
      </Modal>
    </div>
  )
}

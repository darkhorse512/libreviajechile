import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { Star, RefreshCw, ExternalLink } from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { dateShort, number } from '../lib/format'
import {
  Card,
  PageHeader,
  Spinner,
  Avatar,
  EmptyState,
  SearchInput,
} from '../components/ui'

async function fetchRatings() {
  const { data, error } = await supabase
    .from('ratings')
    .select(
      'id, trip_id, stars, comment, created_at, ' +
        'rater:profiles!rater_id(full_name, avatar_url), ratee:profiles!ratee_id(full_name)',
    )
    .order('created_at', { ascending: false })
    .limit(500)
  if (error) throw error
  return data ?? []
}

function Stars({ value }) {
  return (
    <span className="inline-flex items-center gap-0.5">
      {Array.from({ length: 5 }).map((_, i) => (
        <Star
          key={i}
          size={15}
          className={i < value ? 'fill-star text-star' : 'text-slate-300'}
        />
      ))}
    </span>
  )
}

export default function Ratings() {
  const { data, loading, error, refetch } = useQuery(fetchRatings, [])
  const [search, setSearch] = useState('')
  const [minStars, setMinStars] = useState(0)

  const stats = useMemo(() => {
    if (!data || data.length === 0) return { avg: 0, count: 0 }
    const sum = data.reduce((s, r) => s + r.stars, 0)
    return { avg: sum / data.length, count: data.length }
  }, [data])

  const filtered = useMemo(() => {
    if (!data) return []
    const q = search.trim().toLowerCase()
    return data.filter((r) => {
      if (r.stars < minStars) return false
      if (!q) return true
      return (
        r.rater?.full_name?.toLowerCase().includes(q) ||
        r.ratee?.full_name?.toLowerCase().includes(q) ||
        r.comment?.toLowerCase().includes(q)
      )
    })
  }, [data, search, minStars])

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Calificaciones"
        subtitle={
          data
            ? `${number(stats.count)} calificaciones · promedio ${stats.avg.toFixed(2)}★`
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
              placeholder="Buscar por nombre o comentario…"
            />
          </div>
          <div className="flex flex-wrap gap-1.5">
            {[0, 5, 4, 3, 2, 1].map((s) => (
              <button
                key={s}
                onClick={() => setMinStars(s)}
                className={`rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
                  minStars === s
                    ? 'bg-navy text-white'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {s === 0 ? 'Todas' : `${s}★+`}
              </button>
            ))}
          </div>
        </div>
      </Card>

      {loading ? (
        <Spinner label="Cargando calificaciones…" />
      ) : error ? (
        <EmptyState title="Error al cargar" message={error} />
      ) : filtered.length === 0 ? (
        <EmptyState icon={Star} title="Sin calificaciones" message="No hay calificaciones que coincidan." />
      ) : (
        <div className="grid gap-3 md:grid-cols-2">
          {filtered.map((r) => (
            <Card key={r.id} className="p-4">
              <div className="flex items-start gap-3">
                <Avatar name={r.rater?.full_name} src={r.rater?.avatar_url} size={40} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="truncate text-sm font-semibold text-slate-800">
                      {r.rater?.full_name || 'Usuario'}
                    </p>
                    <Stars value={r.stars} />
                  </div>
                  <p className="text-xs text-slate-400">
                    para <span className="font-medium text-slate-500">{r.ratee?.full_name || '—'}</span>{' '}
                    · {dateShort(r.created_at)}
                  </p>
                  {r.comment && (
                    <p className="mt-2 text-sm italic text-slate-600">“{r.comment}”</p>
                  )}
                  <Link
                    to={`/viajes/${r.trip_id}`}
                    className="mt-2 inline-flex items-center gap-1 text-xs font-medium text-accent hover:underline"
                  >
                    Ver viaje <ExternalLink size={12} />
                  </Link>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}

import { useMemo, useState } from 'react'
import {
  ShieldCheck,
  RefreshCw,
  Phone,
  MapPin,
  FileText,
  ExternalLink,
  Check,
  X,
} from 'lucide-react'
import { supabase } from '../lib/supabase'
import { useQuery } from '../hooks/useQuery'
import { dateTime } from '../lib/format'
import {
  Card,
  PageHeader,
  Spinner,
  Badge,
  Avatar,
  EmptyState,
  Modal,
} from '../components/ui'

const DOCS = [
  { key: 'doc_id_front', label: 'Cédula — frente' },
  { key: 'doc_id_back', label: 'Cédula — reverso' },
]

async function fetchPending() {
  const { data, error } = await supabase
    .from('profiles')
    .select(
      'id, full_name, phone, city, avatar_url, created_at, ' +
        'verification_status, verification_submitted_at, doc_id_front, doc_id_back',
    )
    .eq('role', 'passenger')
    .eq('verification_status', 'pending')
    .order('verification_submitted_at', { ascending: true, nullsFirst: false })
  if (error) throw error
  return data ?? []
}

const isPdf = (url) => typeof url === 'string' && url.toLowerCase().includes('.pdf')

function DocThumb({ label, url, onView }) {
  if (!url) {
    return (
      <div className="rounded-xl border border-dashed border-slate-200 p-3 text-center">
        <FileText size={20} className="mx-auto text-slate-300" />
        <p className="mt-1 text-xs text-slate-400">{label}</p>
        <p className="text-[11px] font-medium text-amber-500">Sin subir</p>
      </div>
    )
  }
  return (
    <button
      onClick={() => onView({ label, url })}
      className="group relative overflow-hidden rounded-xl border border-slate-200 text-left transition-shadow hover:shadow-card-hover"
    >
      {isPdf(url) ? (
        <div className="grid h-32 w-full place-items-center bg-slate-50">
          <FileText size={30} className="text-rose-500" />
        </div>
      ) : (
        <img src={url} alt={label} className="h-32 w-full object-cover" />
      )}
      <div className="flex items-center justify-between gap-1 px-2.5 py-1.5">
        <span className="truncate text-xs font-medium text-slate-600">{label}</span>
        <ExternalLink size={13} className="shrink-0 text-slate-400" />
      </div>
    </button>
  )
}

export default function PassengerApprovals() {
  const { data, loading, error, refetch, setData } = useQuery(fetchPending, [])
  const [savingId, setSavingId] = useState(null)
  const [viewer, setViewer] = useState(null) // { label, url }
  const [rejecting, setRejecting] = useState(null) // profile row
  const [reason, setReason] = useState('')

  const count = useMemo(() => data?.length ?? 0, [data])

  const remove = (id) => setData((prev) => prev.filter((d) => d.id !== id))

  const approve = async (p) => {
    setSavingId(p.id)
    const { error: err } = await supabase
      .from('profiles')
      .update({
        verification_status: 'approved',
        verification_rejection_reason: null,
        verification_reviewed_at: new Date().toISOString(),
      })
      .eq('id', p.id)
    setSavingId(null)
    if (!err) remove(p.id)
  }

  const confirmReject = async () => {
    if (!rejecting) return
    const p = rejecting
    setSavingId(p.id)
    const { error: err } = await supabase
      .from('profiles')
      .update({
        verification_status: 'rejected',
        verification_rejection_reason: reason.trim() || null,
        verification_reviewed_at: new Date().toISOString(),
      })
      .eq('id', p.id)
    setSavingId(null)
    setRejecting(null)
    setReason('')
    if (!err) remove(p.id)
  }

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Verificación de pasajeros"
        subtitle={
          data ? `${count} pendiente${count === 1 ? '' : 's'} de aprobación` : 'Cargando…'
        }
        actions={
          <button onClick={refetch} className="btn-outline">
            <RefreshCw size={16} />
            Actualizar
          </button>
        }
      />

      {loading ? (
        <Spinner label="Cargando solicitudes…" />
      ) : error ? (
        <EmptyState title="Error al cargar" message={error} />
      ) : count === 0 ? (
        <EmptyState
          icon={ShieldCheck}
          title="Todo al día"
          message="No hay pasajeros pendientes de aprobación."
        />
      ) : (
        <div className="grid gap-4 xl:grid-cols-2">
          {data.map((p) => (
            <Card key={p.id} className="p-5">
              <div className="flex items-start gap-3">
                <Avatar name={p.full_name} src={p.avatar_url} size={52} />
                <div className="min-w-0 flex-1">
                  <p className="truncate font-semibold text-slate-800">
                    {p.full_name || 'Pasajero'}
                  </p>
                  <div className="mt-1 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1">
                      <MapPin size={12} /> {p.city || '—'}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <Phone size={12} /> {p.phone || '—'}
                    </span>
                  </div>
                </div>
                <Badge className="bg-amber-100 text-amber-700">Pendiente</Badge>
              </div>

              {p.verification_submitted_at && (
                <p className="mt-3 text-[11px] text-slate-400">
                  Enviado el {dateTime(p.verification_submitted_at)}
                </p>
              )}

              <div className="mt-3 grid grid-cols-2 gap-2.5">
                {DOCS.map((doc) => (
                  <DocThumb
                    key={doc.key}
                    label={doc.label}
                    url={p[doc.key]}
                    onView={setViewer}
                  />
                ))}
              </div>

              <div className="mt-4 flex gap-2.5">
                <button
                  onClick={() => approve(p)}
                  disabled={savingId === p.id}
                  className="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700 disabled:opacity-50"
                >
                  <Check size={16} /> Aprobar
                </button>
                <button
                  onClick={() => {
                    setRejecting(p)
                    setReason('')
                  }}
                  disabled={savingId === p.id}
                  className="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-rose-600 ring-1 ring-rose-200 transition-colors hover:bg-rose-50 disabled:opacity-50"
                >
                  <X size={16} /> Rechazar
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Visor de documento */}
      <Modal
        open={!!viewer}
        onClose={() => setViewer(null)}
        title={viewer?.label ?? 'Documento'}
        maxWidth="max-w-2xl"
      >
        {viewer && (
          <div className="space-y-3">
            {isPdf(viewer.url) ? (
              <div className="grid h-64 place-items-center rounded-xl bg-slate-50">
                <FileText size={44} className="text-rose-500" />
              </div>
            ) : (
              <img
                src={viewer.url}
                alt={viewer.label}
                className="max-h-[65vh] w-full rounded-xl object-contain"
              />
            )}
            <a
              href={viewer.url}
              target="_blank"
              rel="noreferrer"
              className="btn-outline inline-flex w-full justify-center"
            >
              <ExternalLink size={16} /> Abrir en pestaña nueva
            </a>
          </div>
        )}
      </Modal>

      {/* Confirmar rechazo con motivo */}
      <Modal
        open={!!rejecting}
        onClose={() => setRejecting(null)}
        title="Rechazar solicitud"
      >
        <p className="text-sm text-slate-500">
          Indica el motivo del rechazo. El pasajero lo verá y podrá volver a subir
          su documento.
        </p>
        <textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          rows={3}
          placeholder="Ej: La foto de la cédula está borrosa o incompleta."
          className="mt-3 w-full rounded-xl border border-slate-200 p-3 text-sm focus:border-brand focus:outline-none focus:ring-1 focus:ring-brand"
        />
        <div className="mt-4 flex justify-end gap-2.5">
          <button onClick={() => setRejecting(null)} className="btn-ghost">
            Cancelar
          </button>
          <button
            onClick={confirmReject}
            disabled={savingId === rejecting?.id}
            className="rounded-xl bg-rose-600 px-4 py-2 text-sm font-semibold text-white hover:bg-rose-700 disabled:opacity-50"
          >
            Rechazar solicitud
          </button>
        </div>
      </Modal>
    </div>
  )
}

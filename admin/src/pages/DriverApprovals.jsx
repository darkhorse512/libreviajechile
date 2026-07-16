import { useMemo, useState } from 'react'
import {
  ShieldCheck,
  RefreshCw,
  Car,
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
  { key: 'doc_driver_photo', label: 'Foto del conductor' },
  { key: 'doc_license', label: 'Licencia de conducir' },
  { key: 'doc_vehicle_reg', label: 'Permiso de circulación' },
  { key: 'doc_antecedentes', label: 'Cert. de antecedentes' },
  { key: 'doc_soap', label: 'Seguro Obligatorio (SOAP)' },
  { key: 'doc_car_front', label: 'Auto — delantera' },
  { key: 'doc_car_back', label: 'Auto — trasera' },
]

async function fetchPending() {
  const { data, error } = await supabase
    .from('driver_details')
    .select(
      'id, make, model, year, color, plate, seats, status, submitted_at, ' +
        'doc_driver_photo, doc_license, doc_vehicle_reg, doc_antecedentes, doc_soap, ' +
        'doc_car_front, doc_car_back, ' +
        'profile:profiles(full_name, phone, city, avatar_url, created_at)',
    )
    .eq('status', 'pending')
    .order('submitted_at', { ascending: true, nullsFirst: false })
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
        <div className="grid h-28 w-full place-items-center bg-slate-50">
          <FileText size={30} className="text-rose-500" />
        </div>
      ) : (
        <img src={url} alt={label} className="h-28 w-full object-cover" />
      )}
      <div className="flex items-center justify-between gap-1 px-2.5 py-1.5">
        <span className="truncate text-xs font-medium text-slate-600">{label}</span>
        <ExternalLink size={13} className="shrink-0 text-slate-400" />
      </div>
    </button>
  )
}

export default function DriverApprovals() {
  const { data, loading, error, refetch, setData } = useQuery(fetchPending, [])
  const [savingId, setSavingId] = useState(null)
  const [viewer, setViewer] = useState(null) // { label, url }
  const [rejecting, setRejecting] = useState(null) // driver row
  const [reason, setReason] = useState('')

  const count = useMemo(() => data?.length ?? 0, [data])

  const remove = (id) => setData((prev) => prev.filter((d) => d.id !== id))

  const approve = async (driver) => {
    setSavingId(driver.id)
    const { error: err } = await supabase
      .from('driver_details')
      .update({
        status: 'approved',
        is_verified: true,
        rejection_reason: null,
        reviewed_at: new Date().toISOString(),
      })
      .eq('id', driver.id)
    setSavingId(null)
    if (!err) remove(driver.id)
  }

  const confirmReject = async () => {
    if (!rejecting) return
    const driver = rejecting
    setSavingId(driver.id)
    const { error: err } = await supabase
      .from('driver_details')
      .update({
        status: 'rejected',
        is_verified: false,
        rejection_reason: reason.trim() || null,
        reviewed_at: new Date().toISOString(),
      })
      .eq('id', driver.id)
    setSavingId(null)
    setRejecting(null)
    setReason('')
    if (!err) remove(driver.id)
  }

  return (
    <div className="animate-fade-in">
      <PageHeader
        title="Solicitudes de conductor"
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
          message="No hay conductores pendientes de aprobación."
        />
      ) : (
        <div className="grid gap-4 xl:grid-cols-2">
          {data.map((d) => (
            <Card key={d.id} className="p-5">
              <div className="flex items-start gap-3">
                <Avatar name={d.profile?.full_name} src={d.profile?.avatar_url} size={52} />
                <div className="min-w-0 flex-1">
                  <p className="truncate font-semibold text-slate-800">
                    {d.profile?.full_name || 'Conductor'}
                  </p>
                  <div className="mt-1 flex flex-wrap gap-x-3 gap-y-1 text-xs text-slate-500">
                    <span className="inline-flex items-center gap-1">
                      <MapPin size={12} /> {d.profile?.city || '—'}
                    </span>
                    <span className="inline-flex items-center gap-1">
                      <Phone size={12} /> {d.profile?.phone || '—'}
                    </span>
                  </div>
                </div>
                <Badge className="bg-amber-100 text-amber-700">Pendiente</Badge>
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
                {d.submitted_at && (
                  <p className="mt-2 text-[11px] text-slate-400">
                    Enviado el {dateTime(d.submitted_at)}
                  </p>
                )}
              </div>

              <div className="mt-4 grid grid-cols-2 gap-2.5 sm:grid-cols-4">
                {DOCS.map((doc) => (
                  <DocThumb
                    key={doc.key}
                    label={doc.label}
                    url={d[doc.key]}
                    onView={setViewer}
                  />
                ))}
              </div>

              <div className="mt-4 flex gap-2.5">
                <button
                  onClick={() => approve(d)}
                  disabled={savingId === d.id}
                  className="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-emerald-700 disabled:opacity-50"
                >
                  <Check size={16} /> Aprobar
                </button>
                <button
                  onClick={() => {
                    setRejecting(d)
                    setReason('')
                  }}
                  disabled={savingId === d.id}
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
          Indica el motivo del rechazo. El conductor lo verá y podrá volver a subir
          sus documentos.
        </p>
        <textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          rows={3}
          placeholder="Ej: La foto del permiso de circulación está borrosa."
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

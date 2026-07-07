// Etiquetas y estilos de estados, alineados con el esquema de Supabase.

export const TRIP_STATUS = {
  requested: { label: 'Solicitado', className: 'bg-accent-soft text-accent-dark' },
  accepted: { label: 'Aceptado', className: 'bg-brand-soft text-brand-dark' },
  in_progress: { label: 'En curso', className: 'bg-amber-100 text-amber-700' },
  completed: { label: 'Completado', className: 'bg-emerald-100 text-emerald-700' },
  cancelled: { label: 'Cancelado', className: 'bg-red-100 text-red-600' },
}

export const OFFER_STATUS = {
  pending: { label: 'Pendiente', className: 'bg-amber-100 text-amber-700' },
  accepted: { label: 'Aceptada', className: 'bg-emerald-100 text-emerald-700' },
  rejected: { label: 'Rechazada', className: 'bg-red-100 text-red-600' },
  withdrawn: { label: 'Retirada', className: 'bg-slate-100 text-slate-500' },
}

export const ROLE = {
  passenger: { label: 'Pasajero', className: 'bg-accent-soft text-accent-dark' },
  driver: { label: 'Conductor', className: 'bg-brand-soft text-brand-dark' },
  admin: { label: 'Admin', className: 'bg-navy/10 text-navy' },
}

export function tripStatusMeta(status) {
  return TRIP_STATUS[status] ?? { label: status ?? '—', className: 'bg-slate-100 text-slate-500' }
}

export function offerStatusMeta(status) {
  return OFFER_STATUS[status] ?? { label: status ?? '—', className: 'bg-slate-100 text-slate-500' }
}

export function roleMeta(role) {
  return ROLE[role] ?? { label: role ?? '—', className: 'bg-slate-100 text-slate-500' }
}

import { formatDistanceToNow, format } from 'date-fns'
import { es } from 'date-fns/locale'

/** Formatea un monto en pesos chilenos: 4500 → "$4.500". */
export function clp(amount) {
  if (amount === null || amount === undefined) return '—'
  return new Intl.NumberFormat('es-CL', {
    style: 'currency',
    currency: 'CLP',
    maximumFractionDigits: 0,
  }).format(amount)
}

/** Número con separador de miles chileno. */
export function number(value) {
  if (value === null || value === undefined) return '0'
  return new Intl.NumberFormat('es-CL').format(value)
}

/** Fecha absoluta legible: "7 jul 2026, 14:32". */
export function dateTime(value) {
  if (!value) return '—'
  try {
    return format(new Date(value), "d MMM yyyy, HH:mm", { locale: es })
  } catch {
    return '—'
  }
}

export function dateShort(value) {
  if (!value) return '—'
  try {
    return format(new Date(value), 'd MMM yyyy', { locale: es })
  } catch {
    return '—'
  }
}

/** Tiempo relativo: "hace 3 minutos". */
export function relative(value) {
  if (!value) return '—'
  try {
    return formatDistanceToNow(new Date(value), { addSuffix: true, locale: es })
  } catch {
    return '—'
  }
}

/** Iniciales para avatares. */
export function initials(name) {
  if (!name) return '?'
  const parts = name.trim().split(/\s+/)
  return (parts[0][0] + (parts[1]?.[0] ?? '')).toUpperCase()
}

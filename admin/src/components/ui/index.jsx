import { useEffect } from 'react'
import { initials } from '../../lib/format'
import { Star, Inbox, Loader2, X, Search } from 'lucide-react'

/** Tarjeta contenedora estándar. */
export function Card({ className = '', children, ...props }) {
  return (
    <div className={`card ${className}`} {...props}>
      {children}
    </div>
  )
}

/** Encabezado de página con título, subtítulo y acciones. */
export function PageHeader({ title, subtitle, actions }) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between mb-6">
      <div>
        <h1 className="text-2xl font-bold text-navy tracking-tight">{title}</h1>
        {subtitle && <p className="text-sm text-slate-500 mt-0.5">{subtitle}</p>}
      </div>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
    </div>
  )
}

/** Insignia de estado. */
export function Badge({ children, className = '' }) {
  return (
    <span
      className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-xs font-semibold ${className}`}
    >
      {children}
    </span>
  )
}

/** Avatar con imagen o iniciales. */
export function Avatar({ name, src, size = 40 }) {
  const style = { width: size, height: size }
  if (src) {
    return (
      <img
        src={src}
        alt={name ?? ''}
        style={style}
        className="rounded-full object-cover ring-2 ring-white shadow-sm"
      />
    )
  }
  return (
    <div
      style={style}
      className="rounded-full bg-gradient-to-br from-brand to-brand-dark text-white
        grid place-items-center font-bold ring-2 ring-white shadow-sm"
    >
      <span style={{ fontSize: size * 0.38 }}>{initials(name)}</span>
    </div>
  )
}

/** Estrellas de calificación. */
export function RatingStars({ value = 0, showValue = true, size = 14 }) {
  return (
    <span className="inline-flex items-center gap-1">
      <Star size={size} className="fill-star text-star" />
      <span className="text-sm font-semibold text-slate-700">
        {Number(value ?? 0).toFixed(1)}
      </span>
      {showValue === false && null}
    </span>
  )
}

/** Spinner centrado. */
export function Spinner({ label }) {
  return (
    <div className="flex flex-col items-center justify-center gap-3 py-16 text-slate-400">
      <Loader2 className="animate-spin text-brand" size={28} />
      {label && <span className="text-sm">{label}</span>}
    </div>
  )
}

/** Estado vacío. */
export function EmptyState({ icon: Icon = Inbox, title, message }) {
  return (
    <div className="flex flex-col items-center justify-center gap-2 py-16 text-center">
      <div className="rounded-2xl bg-slate-100 p-4 text-slate-400">
        <Icon size={28} />
      </div>
      <h3 className="text-base font-semibold text-slate-700">{title}</h3>
      {message && <p className="max-w-sm text-sm text-slate-500">{message}</p>}
    </div>
  )
}

/** Campo de búsqueda con icono. */
export function SearchInput({ value, onChange, placeholder = 'Buscar…' }) {
  return (
    <div className="relative">
      <Search
        size={18}
        className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
      />
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="input pl-10"
      />
    </div>
  )
}

/** Modal centrado con fondo oscurecido. */
export function Modal({ open, onClose, title, children, maxWidth = 'max-w-lg' }) {
  useEffect(() => {
    if (!open) return
    const onKey = (e) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', onKey)
    document.body.style.overflow = 'hidden'
    return () => {
      window.removeEventListener('keydown', onKey)
      document.body.style.overflow = ''
    }
  }, [open, onClose])

  if (!open) return null
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      onMouseDown={onClose}
    >
      <div className="absolute inset-0 bg-navy-900/50 backdrop-blur-sm animate-fade-in" />
      <div
        onMouseDown={(e) => e.stopPropagation()}
        className={`relative w-full ${maxWidth} card p-6 animate-fade-in`}
      >
        <div className="flex items-start justify-between mb-4">
          <h2 className="text-lg font-bold text-navy">{title}</h2>
          <button
            onClick={onClose}
            className="btn-ghost -mr-2 -mt-1 rounded-lg p-1.5"
            aria-label="Cerrar"
          >
            <X size={18} />
          </button>
        </div>
        {children}
      </div>
    </div>
  )
}

/** Interruptor accesible. */
export function Toggle({ checked, onChange, disabled, colorOn = 'bg-brand' }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 shrink-0 items-center rounded-full
        transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2
        focus-visible:ring-brand disabled:opacity-50 disabled:pointer-events-none
        ${checked ? colorOn : 'bg-slate-300'}`}
    >
      <span
        className={`inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform
          ${checked ? 'translate-x-6' : 'translate-x-1'}`}
      />
    </button>
  )
}

import { NavLink } from 'react-router-dom'
import {
  LayoutDashboard,
  Users,
  Car,
  ShieldCheck,
  UserCheck,
  Route,
  Star,
  X,
} from 'lucide-react'

const NAV = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/usuarios', label: 'Usuarios', icon: Users },
  { to: '/conductores', label: 'Conductores', icon: Car },
  { to: '/solicitudes', label: 'Verif. conductores', icon: ShieldCheck },
  { to: '/solicitudes-pasajeros', label: 'Verif. pasajeros', icon: UserCheck },
  { to: '/viajes', label: 'Viajes', icon: Route },
  { to: '/calificaciones', label: 'Calificaciones', icon: Star },
]

function Brand() {
  return (
    <div className="flex items-center gap-2.5 px-2">
      <div className="grid h-9 w-9 place-items-center rounded-xl bg-brand shadow-sm">
        <Route size={20} className="text-white" />
      </div>
      <div className="leading-tight">
        <p className="text-sm font-extrabold text-white">Libre Viaje</p>
        <p className="text-[11px] font-medium text-white/60">Panel Admin</p>
      </div>
    </div>
  )
}

export default function Sidebar({ open, onClose }) {
  return (
    <>
      {/* Overlay móvil */}
      {open && (
        <div
          className="fixed inset-0 z-30 bg-navy-900/50 lg:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-40 flex w-64 flex-col bg-navy
          transition-transform duration-300 lg:translate-x-0
          ${open ? 'translate-x-0' : '-translate-x-full'}`}
      >
        <div className="flex h-16 items-center justify-between px-4">
          <Brand />
          <button
            onClick={onClose}
            className="rounded-lg p-1.5 text-white/70 hover:bg-white/10 lg:hidden"
            aria-label="Cerrar menú"
          >
            <X size={18} />
          </button>
        </div>

        <nav className="flex-1 space-y-1 px-3 py-4">
          {NAV.map(({ to, label, icon: Icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              onClick={onClose}
              className={({ isActive }) =>
                `flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors
                ${
                  isActive
                    ? 'bg-brand text-white shadow-sm'
                    : 'text-white/70 hover:bg-white/10 hover:text-white'
                }`
              }
            >
              <Icon size={19} />
              {label}
            </NavLink>
          ))}
        </nav>

        <div className="px-4 py-4 text-[11px] text-white/40">
          © {new Date().getFullYear()} Libre Viaje Chile
        </div>
      </aside>
    </>
  )
}

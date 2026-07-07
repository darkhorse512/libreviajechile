import { useState, useRef, useEffect } from 'react'
import { Menu, LogOut, ChevronDown } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import { Avatar } from './ui'

export default function Topbar({ onMenu }) {
  const { profile, signOut } = useAuth()
  const [open, setOpen] = useState(false)
  const ref = useRef(null)

  useEffect(() => {
    const onClick = (e) => {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false)
    }
    document.addEventListener('mousedown', onClick)
    return () => document.removeEventListener('mousedown', onClick)
  }, [])

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center gap-3 border-b border-slate-200 bg-white/80 px-4 backdrop-blur-md sm:px-6">
      <button
        onClick={onMenu}
        className="rounded-lg p-2 text-slate-500 hover:bg-slate-100 lg:hidden"
        aria-label="Abrir menú"
      >
        <Menu size={20} />
      </button>

      <div className="ml-auto" ref={ref}>
        <button
          onClick={() => setOpen((v) => !v)}
          className="flex items-center gap-2.5 rounded-xl py-1.5 pl-1.5 pr-3 hover:bg-slate-100"
        >
          <Avatar name={profile?.full_name} src={profile?.avatar_url} size={34} />
          <div className="hidden text-left sm:block">
            <p className="text-sm font-semibold leading-tight text-slate-800">
              {profile?.full_name || 'Administrador'}
            </p>
            <p className="text-[11px] text-slate-400">Administrador</p>
          </div>
          <ChevronDown size={16} className="text-slate-400" />
        </button>

        {open && (
          <div className="absolute right-0 mt-2 w-48 rounded-xl border border-slate-200 bg-white p-1 shadow-card-hover animate-fade-in">
            <button
              onClick={signOut}
              className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50"
            >
              <LogOut size={16} />
              Cerrar sesión
            </button>
          </div>
        )}
      </div>
    </header>
  )
}

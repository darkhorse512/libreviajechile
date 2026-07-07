import { useState } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { Route, Lock, Mail, Loader2, ShieldCheck, AlertCircle } from 'lucide-react'
import { useAuth } from '../context/AuthContext'
import { isSupabaseConfigured } from '../lib/supabase'

export default function Login() {
  const { session, isAdmin, loading, signIn } = useAuth()
  const location = useLocation()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  if (!loading && session && isAdmin) {
    const to = location.state?.from?.pathname ?? '/'
    return <Navigate to={to} replace />
  }

  const onSubmit = async (e) => {
    e.preventDefault()
    setSubmitting(true)
    setError(null)
    const { error } = await signIn(email.trim(), password)
    if (error) {
      setError(error)
      setSubmitting(false)
    }
    // En éxito, el guard de arriba redirige automáticamente.
  }

  return (
    <div className="grid min-h-screen lg:grid-cols-2">
      {/* Panel de marca */}
      <div className="relative hidden overflow-hidden bg-navy lg:block">
        <div className="absolute -right-24 -top-24 h-96 w-96 rounded-full bg-brand/20 blur-3xl" />
        <div className="absolute -bottom-24 -left-24 h-96 w-96 rounded-full bg-accent/20 blur-3xl" />
        <div className="relative flex h-full flex-col justify-between p-12 text-white">
          <div className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-2xl bg-brand shadow-lg">
              <Route size={24} className="text-white" />
            </div>
            <div>
              <p className="text-lg font-extrabold leading-tight">Libre Viaje Chile</p>
              <p className="text-sm text-white/60">Panel de administración</p>
            </div>
          </div>

          <div>
            <h2 className="text-4xl font-bold leading-tight">
              Gestiona tu plataforma
              <br />
              <span className="text-brand-light">con total control.</span>
            </h2>
            <p className="mt-4 max-w-md text-white/70">
              Supervisa usuarios, conductores y viajes en tiempo real. Verifica
              conductores, modera cuentas y mide el crecimiento — todo desde un
              solo lugar.
            </p>
          </div>

          <div className="flex items-center gap-2 text-sm text-white/50">
            <ShieldCheck size={16} />
            Acceso restringido a administradores
          </div>
        </div>
      </div>

      {/* Formulario */}
      <div className="flex items-center justify-center bg-slate-50 p-6">
        <div className="w-full max-w-sm">
          <div className="mb-8 flex items-center gap-3 lg:hidden">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-brand">
              <Route size={22} className="text-white" />
            </div>
            <p className="text-lg font-extrabold text-navy">Libre Viaje Admin</p>
          </div>

          <h1 className="text-2xl font-bold text-navy">Iniciar sesión</h1>
          <p className="mt-1 text-sm text-slate-500">
            Ingresa con tu cuenta de administrador.
          </p>

          {!isSupabaseConfigured && (
            <div className="mt-4 flex items-start gap-2 rounded-xl bg-amber-50 p-3 text-sm text-amber-700">
              <AlertCircle size={18} className="mt-0.5 shrink-0" />
              <span>
                Faltan las variables de Supabase. Configura{' '}
                <code className="font-mono">VITE_SUPABASE_URL</code> y{' '}
                <code className="font-mono">VITE_SUPABASE_ANON_KEY</code>.
              </span>
            </div>
          )}

          <form onSubmit={onSubmit} className="mt-6 space-y-4">
            <div>
              <label className="label" htmlFor="email">
                Correo electrónico
              </label>
              <div className="relative">
                <Mail
                  size={18}
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
                />
                <input
                  id="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@libreviajechile.cl"
                  className="input pl-10"
                />
              </div>
            </div>

            <div>
              <label className="label" htmlFor="password">
                Contraseña
              </label>
              <div className="relative">
                <Lock
                  size={18}
                  className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
                />
                <input
                  id="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="input pl-10"
                />
              </div>
            </div>

            {error && (
              <div className="flex items-center gap-2 rounded-xl bg-red-50 p-3 text-sm text-red-600">
                <AlertCircle size={16} className="shrink-0" />
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={submitting}
              className="btn-primary w-full py-3 text-base"
            >
              {submitting ? (
                <Loader2 className="animate-spin" size={20} />
              ) : (
                'Entrar al panel'
              )}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}

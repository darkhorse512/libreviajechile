import { createContext, useContext, useEffect, useState, useCallback } from 'react'
import { supabase } from '../lib/supabase'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [session, setSession] = useState(null)
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)

  const loadProfile = useCallback(async (userId) => {
    if (!userId) {
      setProfile(null)
      return null
    }
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle()
    setProfile(data ?? null)
    return data ?? null
  }, [])

  useEffect(() => {
    let active = true

    supabase.auth.getSession().then(async ({ data }) => {
      if (!active) return
      setSession(data.session)
      await loadProfile(data.session?.user?.id)
      if (active) setLoading(false)
    })

    const { data: sub } = supabase.auth.onAuthStateChange((_event, newSession) => {
      setSession(newSession)
      loadProfile(newSession?.user?.id)
    })

    return () => {
      active = false
      sub.subscription.unsubscribe()
    }
  }, [loadProfile])

  /**
   * Inicia sesión y verifica que el usuario tenga rol de administrador.
   * Si no lo es, cierra la sesión y devuelve un error legible.
   */
  const signIn = useCallback(async (email, password) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) {
      return { error: 'Correo o contraseña incorrectos.' }
    }
    const prof = await loadProfile(data.user.id)
    if (!prof || prof.role !== 'admin') {
      await supabase.auth.signOut()
      setSession(null)
      setProfile(null)
      return { error: 'Esta cuenta no tiene permisos de administrador.' }
    }
    return { error: null }
  }, [loadProfile])

  const signOut = useCallback(async () => {
    await supabase.auth.signOut()
    setSession(null)
    setProfile(null)
  }, [])

  const isAdmin = Boolean(profile && profile.role === 'admin')

  const value = { session, profile, loading, isAdmin, signIn, signOut }
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de <AuthProvider>')
  return ctx
}

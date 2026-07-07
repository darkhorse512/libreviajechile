import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!url || !anonKey) {
  // Mensaje claro en consola si faltan las variables de entorno.
  // eslint-disable-next-line no-console
  console.error(
    'Faltan VITE_SUPABASE_URL o VITE_SUPABASE_ANON_KEY. ' +
      'Crea un archivo .env (ver .env.example) o configúralas en Netlify.',
  )
}

export const supabase = createClient(url ?? '', anonKey ?? '', {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
})

export const isSupabaseConfigured = Boolean(url && anonKey)

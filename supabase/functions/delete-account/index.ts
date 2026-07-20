// =============================================================================
// Edge Function: delete-account
// Elimina de forma permanente la cuenta del usuario AUTENTICADO. Se identifica
// al usuario por su JWT y se borra con la service role key. El borrado del
// usuario de auth.users elimina en cascada su perfil y todos sus datos
// (driver_details, trips, offers, ratings, device_tokens) por las FK
// "on delete cascade".
//
// (SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY se inyectan automáticamente; no
//  requiere secrets adicionales.)
// =============================================================================
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    // --- Identifica al usuario por su JWT -----------------------------------
    const authHeader = req.headers.get('Authorization') ?? ''
    const anon = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    )
    const {
      data: { user },
    } = await anon.auth.getUser()
    if (!user) return new Response('unauthorized', { status: 401 })

    // --- Borra la cuenta con privilegios de servicio ------------------------
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )
    const { error } = await admin.auth.admin.deleteUser(user.id)
    if (error) {
      return new Response(`delete failed: ${error.message}`, { status: 500 })
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(`error: ${e}`, { status: 500 })
  }
})

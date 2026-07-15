// =============================================================================
// Edge Function: upload-image
// Sube una imagen (avatar del usuario o foto del auto) a Cloudflare R2 y
// devuelve su URL pública. Las credenciales de R2 viven como SECRETS del
// proyecto (nunca en la app).
//
// Body JSON: { data: base64, contentType: 'image/jpeg', kind: 'avatar'|'car' }
//
// Secrets requeridos (supabase secrets set ...):
//   R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET,
//   R2_PUBLIC_BASE   (ej: https://pub-XXXX.r2.dev  o tu dominio propio)
// (SUPABASE_URL y SUPABASE_ANON_KEY se inyectan automáticamente.)
// =============================================================================
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { AwsClient } from 'https://esm.sh/aws4fetch@1.0.20'

Deno.serve(async (req) => {
  try {
    // --- Autenticación: identifica al usuario por su JWT ---------------------
    const authHeader = req.headers.get('Authorization') ?? ''
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    )
    const {
      data: { user },
    } = await supabase.auth.getUser()
    if (!user) return new Response('unauthorized', { status: 401 })

    const { data, contentType, kind } = await req.json()
    if (!data || typeof data !== 'string') {
      return new Response('no image data', { status: 400 })
    }
    const ct = typeof contentType === 'string' ? contentType : 'image/jpeg'
    const ext = ct.includes('png') ? 'png' : 'jpg'
    const folder = kind === 'car' ? 'cars' : 'avatars'
    const rand = crypto.randomUUID().slice(0, 8)
    const key = `${folder}/${user.id}/${rand}.${ext}`

    const bytes = Uint8Array.from(atob(data), (c) => c.charCodeAt(0))

    // --- Sube a R2 vía API S3 (firmado con aws4fetch) ------------------------
    const accountId = Deno.env.get('R2_ACCOUNT_ID')!
    const bucket = Deno.env.get('R2_BUCKET')!
    const aws = new AwsClient({
      accessKeyId: Deno.env.get('R2_ACCESS_KEY_ID')!,
      secretAccessKey: Deno.env.get('R2_SECRET_ACCESS_KEY')!,
      region: 'auto',
      service: 's3',
    })
    const objectUrl =
      `https://${accountId}.r2.cloudflarestorage.com/${bucket}/${key}`
    const put = await aws.fetch(objectUrl, {
      method: 'PUT',
      body: bytes,
      headers: { 'Content-Type': ct },
    })
    if (!put.ok) {
      const detail = await put.text()
      return new Response(`upload failed: ${put.status} ${detail}`, {
        status: 500,
      })
    }

    const publicBase = (Deno.env.get('R2_PUBLIC_BASE') ?? '').replace(/\/$/, '')
    return new Response(JSON.stringify({ url: `${publicBase}/${key}` }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(`error: ${e}`, { status: 500 })
  }
})

// =============================================================================
// Edge Function: notify-drivers
// Se dispara con un Database Webhook al INSERTAR un viaje ("trips"). Busca a los
// conductores EN LÍNEA cercanos al origen del viaje y les envía una notificación
// push vía FCM HTTP v1.
//
// Secrets requeridos (supabase secrets set ...):
//   FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY
// (SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY se inyectan automáticamente).
// =============================================================================
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// --- Ciudades de Chile (copia de kChileanCities) -----------------------------
const CITIES: { name: string; region: string; lat: number; lng: number }[] = [
  { name: 'Arica', region: 'Arica y Parinacota', lat: -18.4783, lng: -70.3126 },
  { name: 'Iquique', region: 'Tarapacá', lat: -20.2133, lng: -70.1503 },
  { name: 'Alto Hospicio', region: 'Tarapacá', lat: -20.2508, lng: -70.1108 },
  { name: 'Antofagasta', region: 'Antofagasta', lat: -23.6509, lng: -70.3975 },
  { name: 'Calama', region: 'Antofagasta', lat: -22.4544, lng: -68.9294 },
  { name: 'Copiapó', region: 'Atacama', lat: -27.3668, lng: -70.3323 },
  { name: 'La Serena', region: 'Coquimbo', lat: -29.9027, lng: -71.2519 },
  { name: 'Coquimbo', region: 'Coquimbo', lat: -29.9533, lng: -71.3436 },
  { name: 'Ovalle', region: 'Coquimbo', lat: -30.6011, lng: -71.1998 },
  { name: 'Valparaíso', region: 'Valparaíso', lat: -33.0472, lng: -71.6127 },
  { name: 'Viña del Mar', region: 'Valparaíso', lat: -33.0245, lng: -71.5518 },
  { name: 'Quilpué', region: 'Valparaíso', lat: -33.0472, lng: -71.4419 },
  { name: 'San Antonio', region: 'Valparaíso', lat: -33.5928, lng: -71.6127 },
  { name: 'Santiago', region: 'Metropolitana', lat: -33.4489, lng: -70.6693 },
  { name: 'Maipú', region: 'Metropolitana', lat: -33.5110, lng: -70.7580 },
  { name: 'Puente Alto', region: 'Metropolitana', lat: -33.6117, lng: -70.5756 },
  { name: 'La Florida', region: 'Metropolitana', lat: -33.5225, lng: -70.5989 },
  { name: 'Las Condes', region: 'Metropolitana', lat: -33.4088, lng: -70.5679 },
  { name: 'Providencia', region: 'Metropolitana', lat: -33.4314, lng: -70.6093 },
  { name: 'Rancagua', region: "O'Higgins", lat: -34.1708, lng: -70.7444 },
  { name: 'Talca', region: 'Maule', lat: -35.4264, lng: -71.6554 },
  { name: 'Curicó', region: 'Maule', lat: -34.9854, lng: -71.2394 },
  { name: 'Chillán', region: 'Ñuble', lat: -36.6067, lng: -72.1034 },
  { name: 'Concepción', region: 'Biobío', lat: -36.8270, lng: -73.0503 },
  { name: 'Talcahuano', region: 'Biobío', lat: -36.7249, lng: -73.1169 },
  { name: 'Los Ángeles', region: 'Biobío', lat: -37.4697, lng: -72.3537 },
  { name: 'Temuco', region: 'La Araucanía', lat: -38.7359, lng: -72.5904 },
  { name: 'Valdivia', region: 'Los Ríos', lat: -39.8142, lng: -73.2459 },
  { name: 'Osorno', region: 'Los Lagos', lat: -40.5735, lng: -73.1348 },
  { name: 'Puerto Montt', region: 'Los Lagos', lat: -41.4693, lng: -72.9424 },
  { name: 'Coyhaique', region: 'Aysén', lat: -45.5712, lng: -72.0685 },
  { name: 'Punta Arenas', region: 'Magallanes', lat: -53.1638, lng: -70.9171 },
]

function distanceKm(lat1: number, lng1: number, lat2: number, lng2: number) {
  const R = 6371
  const toRad = (d: number) => (d * Math.PI) / 180
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}

const cityCenter = (name?: string | null) =>
  CITIES.find((c) => c.name === name) ?? null
const regionByCity = (name?: string | null) => cityCenter(name)?.region ?? null

/** Misma lógica que `tripInDriverArea` en la app. */
function tripInArea(
  tripLat: number | null,
  tripLng: number | null,
  tripCity: string,
  refCity: string | null,
  radiusKm = 60,
) {
  const center = cityCenter(refCity)
  if (tripLat != null && tripLng != null && center) {
    return distanceKm(tripLat, tripLng, center.lat, center.lng) <= radiusKm
  }
  const r1 = regionByCity(tripCity)
  const r2 = regionByCity(refCity)
  if (r1 && r2) return r1 === r2
  return (tripCity ?? '').trim().toLowerCase() ===
    (refCity ?? '').trim().toLowerCase()
}

// --- OAuth2 para FCM (service account) --------------------------------------
function b64url(input: string | Uint8Array): string {
  const bytes =
    typeof input === 'string' ? new TextEncoder().encode(input) : input
  let bin = ''
  for (const b of bytes) bin += String.fromCharCode(b)
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '')
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0))
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )
}

async function getAccessToken(): Promise<string> {
  const email = Deno.env.get('FIREBASE_CLIENT_EMAIL')!
  const key = (Deno.env.get('FIREBASE_PRIVATE_KEY') ?? '').replace(/\\n/g, '\n')
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const claim = {
    iss: email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  }
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(claim))}`
  const pk = await importPrivateKey(key)
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    pk,
    new TextEncoder().encode(unsigned),
  )
  const jwt = `${unsigned}.${b64url(new Uint8Array(sig))}`

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=${encodeURIComponent(
      'urn:ietf:params:oauth:grant-type:jwt-bearer',
    )}&assertion=${jwt}`,
  })
  const json = await res.json()
  if (!json.access_token) throw new Error(`OAuth error: ${JSON.stringify(json)}`)
  return json.access_token as string
}

async function sendFcm(
  projectId: string,
  accessToken: string,
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: { priority: 'HIGH', notification: { sound: 'default' } },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  )
  return res.ok
}

// --- Handler -----------------------------------------------------------------
Deno.serve(async (req) => {
  try {
    const payload = await req.json()
    const trip = payload.record ?? payload // soporta webhook o llamada directa
    if (!trip || trip.status !== 'requested') {
      return new Response('ignored', { status: 200 })
    }

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // TODOS los conductores en línea (sin filtro por cercanía): un pasajero
    // puede pedir viaje en cualquier zona del país.
    const { data: drivers } = await admin
      .from('driver_details')
      .select('id')
      .eq('is_online', true)

    const nearbyIds = (drivers ?? []).map((d: any) => d.id)

    if (nearbyIds.length === 0) {
      return new Response('no online drivers', { status: 200 })
    }

    const { data: tokens } = await admin
      .from('device_tokens')
      .select('token')
      .in('user_id', nearbyIds)

    const list = (tokens ?? []).map((t: any) => t.token)
    if (list.length === 0) {
      return new Response('no tokens', { status: 200 })
    }

    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')!
    const accessToken = await getAccessToken()

    const title = '🚗 Nueva solicitud de viaje'
    const body = `${trip.origin_address ?? 'Origen'} → ${trip.destination_address ?? 'Destino'}`
    const data = { tripId: String(trip.id ?? ''), type: 'new_trip' }

    const results = await Promise.all(
      list.map((tok: string) =>
        sendFcm(projectId, accessToken, tok, title, body, data).catch(() => false),
      ),
    )
    const sent = results.filter(Boolean).length

    return new Response(JSON.stringify({ drivers: nearbyIds.length, sent }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(`error: ${e}`, { status: 500 })
  }
})

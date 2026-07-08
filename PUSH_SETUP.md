# Notificaciones push (drivers) — Guía de configuración

Esto habilita que un **conductor reciba una notificación aunque tenga la app
cerrada** cuando un pasajero cercano solicita un viaje.

La app ya trae **todo el código listo** (Flutter + SQL + Edge Function). Solo
faltan los pasos que dependen de tus cuentas de Firebase y Supabase, porque
requieren credenciales que no se pueden generar automáticamente.

> Mientras `PUSH_ENABLED=false` en `.env`, la app funciona normal **sin** push.
> Al terminar estos pasos, lo pones en `true` y reconstruyes.

---

## Arquitectura (cómo funciona)

```
Pasajero crea viaje ──> INSERT en tabla trips
                           │  (Database Webhook)
                           ▼
             Edge Function "notify-drivers"
             · busca conductores EN LÍNEA cercanos (≤60 km del origen)
             · lee sus tokens en device_tokens
             · envía push vía FCM HTTP v1
                           │
                           ▼
              📱 Conductor recibe la notificación
```

---

## Paso 1 — Crear proyecto Firebase y registrar la app Android

1. Ve a <https://console.firebase.google.com> → **Add project**.
2. Dentro del proyecto: **Add app → Android**.
   - **Android package name:** `cl.libreviaje.libre_viaje_chile`
     (debe coincidir con `applicationId`).
3. Descarga el `google-services.json` que te ofrece (lo usará FlutterFire).

## Paso 2 — Conectar Firebase a la app Flutter

Con las CLIs instaladas (`npm i -g firebase-tools`, `dart pub global activate
flutterfire_cli`):

```bash
cd /home/altair/Downloads/Work/Libreviajechile
firebase login
flutterfire configure --project=<TU_PROJECT_ID>
```

Esto **sobrescribe** `lib/firebase_options.dart` con los valores reales y agrega
la config nativa. (En Android también deja el `google-services.json` en
`android/app/`.)

## Paso 3 — Activar push en la app

En `.env`:

```
PUSH_ENABLED=true
```

Reconstruye la app:

```bash
flutter clean && flutter pub get && flutter build apk --release
```

Al iniciar sesión, cada dispositivo guardará su token FCM en `device_tokens`.

---

## Paso 4 — Crear la tabla de tokens en Supabase

En el **SQL Editor** de Supabase ejecuta el archivo `supabase/push.sql`
(crea `device_tokens` + RLS).

## Paso 5 — Generar una service account de Firebase

1. Firebase Console → **Project settings → Service accounts**.
2. **Generate new private key** → descarga el JSON. Contiene
   `project_id`, `client_email` y `private_key`.

## Paso 6 — Desplegar la Edge Function

Con la [CLI de Supabase](https://supabase.com/docs/guides/cli) instalada:

```bash
cd /home/altair/Downloads/Work/Libreviajechile
supabase login
supabase link --project-ref jmngxuohmxyhcyhrbmqb

# Secrets (usa los valores del JSON de la service account):
supabase secrets set FIREBASE_PROJECT_ID="tu-project-id"
supabase secrets set FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxx@tu-proyecto.iam.gserviceaccount.com"
# OJO: la private key debe ir con \n literales o entre comillas conservando saltos.
supabase secrets set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Desplegar (sin verificación de JWT: la invoca el webhook):
supabase functions deploy notify-drivers --no-verify-jwt
```

> `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` los inyecta Supabase
> automáticamente; no los configures a mano.

## Paso 7 — Conectar el Webhook de base de datos

Supabase Dashboard → **Database → Webhooks → Create a new hook**:

- **Table:** `trips`
- **Events:** `INSERT`
- **Type:** *Supabase Edge Functions* → `notify-drivers`
- **Method:** `POST`

Guarda. A partir de ahora, cada viaje nuevo dispara la función.

---

## Probar

1. Conéctate como **conductor** en un dispositivo (queda en línea) y **cierra**
   la app por completo.
2. Desde otra cuenta, crea un viaje como **pasajero** cerca de la ciudad del
   conductor.
3. El conductor debería recibir la notificación **🚗 Nueva solicitud de viaje**.

### Diagnóstico
- **Logs de la función:** `supabase functions logs notify-drivers` — verás
  `{ drivers, sent }`.
- **¿0 drivers?** El conductor no estaba en línea o no está dentro del radio.
- **¿0 sent / error OAuth?** Revisa los tres secrets de Firebase (especialmente
  que `FIREBASE_PRIVATE_KEY` conserve los saltos de línea `\n`).
- **¿No hay tokens?** El dispositivo no guardó el token: confirma
  `PUSH_ENABLED=true`, que otorgaste permiso de notificaciones y que
  `supabase/push.sql` se ejecutó.

---

## Notas
- **iOS** además requiere una APNs Auth Key subida a Firebase (Cloud Messaging)
  y capacidad *Push Notifications* en Xcode. Android funciona con los pasos de
  arriba.
- La app ya muestra un aviso in-app (vibración + banner) cuando llega una
  solicitud **con la app abierta**; las push cubren el caso de **app cerrada**.

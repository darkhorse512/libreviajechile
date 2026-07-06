# Verificación por código de 6 dígitos (Supabase OTP + Resend Edge Function)

La app usa el **OTP nativo de Supabase**: al registrarse, Supabase genera un
código de 6 dígitos, y una **Edge Function** (`send-email`) lo envía por **Resend**
desde `noreply@mail.libreviaje.cl`. El usuario escribe el código en la app y
`verifyOTP` lo valida.

> Con este enfoque **no necesitas configurar SMTP**. Supabase genera y valida el
> código; la función sólo lo entrega vía Resend usando tu API key.

---

## 1) Resend — verificar el dominio del remitente

1. En [resend.com](https://resend.com) → **Domains** → agrega `mail.libreviaje.cl`.
2. Copia los registros DNS (SPF, DKIM, DMARC) en **Cloudflare** y espera a que
   Resend muestre **Verified** ✅. (Sin esto, los correos no se entregan.)

---

## 2) Desplegar la Edge Function `send-email`

Requiere el [Supabase CLI](https://supabase.com/docs/guides/cli).

```bash
cd Libreviajechile

# 1. Vincula tu proyecto (una vez)
supabase login
supabase link --project-ref jmngxuohmxyhcyhrbmqb

# 2. Configura los secretos que usa la función
supabase secrets set RESEND_API_KEY=re_MuqCq4Aw_817aUFdL8MgAW7CivFo7rP8W

# 3. Despliega la función (sin verificación de JWT: la llama el hook, no un usuario)
supabase functions deploy send-email --no-verify-jwt
```

La función está en `supabase/functions/send-email/index.ts`.

---

## 3) Activar el "Send Email Hook" en Supabase

Dashboard → **Authentication → Hooks** → **Send Email Hook** → **Enable**:
- **Hook type:** HTTPS / Edge Function
- **Function:** `send-email`  (URL: `https://jmngxuohmxyhcyhrbmqb.functions.supabase.co/send-email`)
- Supabase genera un **Signing secret** (formato `v1,whsec_...`). Cópialo y guárdalo
  como secreto de la función:

```bash
supabase secrets set SEND_EMAIL_HOOK_SECRET='v1,whsec_XXXXXXXXXXXX'
```

> Al activar el hook, Supabase enruta **todos** los correos de auth a tu función,
> así que no hace falta SMTP personalizado.

---

## 4) Mantener activada la confirmación por correo

Authentication → **Providers → Email** → **"Confirm email" = ON**.
Esto es lo que hace que se pida el código. (El largo por defecto del código es 6
dígitos; se ajusta en Authentication → Settings.)

No necesitas editar la plantilla de correo: el diseño del email lo genera la
propia función (`buildHtml`).

---

## 5) Ejecuta el esquema actualizado

En el **SQL Editor** vuelve a ejecutar `supabase/schema.sql` (idempotente). La
función `handle_new_user` crea el **perfil y el vehículo** del conductor desde la
metadata del registro.

---

## Flujo final en la app
1. El usuario se registra (pasajero o conductor).
2. Supabase genera el código → llama a la Edge Function → **Resend** envía el
   correo desde `noreply@mail.libreviaje.cl`.
3. La app abre **"Verifica tu correo"** → el usuario escribe el código.
4. `verifyOTP` valida → inicia sesión → entra a la app. Botón **"Reenviar código"**
   tras 45 s.

---

## Probar la función localmente (opcional)
```bash
supabase functions serve send-email --no-verify-jwt --env-file supabase/.env.local
```
Con `supabase/.env.local` conteniendo `RESEND_API_KEY` y `SEND_EMAIL_HOOK_SECRET`.

## Alternativa sin Edge Function (SMTP)
Si prefieres no usar la función, puedes configurar SMTP de Resend en
Project Settings → Authentication → SMTP (host `smtp.resend.com`, puerto `465`,
usuario `resend`, contraseña = tu API key) y editar la plantilla "Confirm signup"
para incluir `{{ .Token }}`. El enfoque de Edge Function es el recomendado.

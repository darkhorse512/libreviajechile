// Supabase Edge Function: "Send Email Hook"
// -----------------------------------------------------------------------------
// Supabase llama a esta función cada vez que necesita enviar un correo de auth
// (registro/OTP, recuperación de contraseña, cambio de correo, magic link).
// Supabase GENERA y VALIDA el código de 6 dígitos; aquí sólo lo enviamos por
// Resend desde noreply@mail.libreviaje.cl.
//
// Secrets necesarios (supabase secrets set ...):
//   RESEND_API_KEY            -> tu API key de Resend (re_...)
//   SEND_EMAIL_HOOK_SECRET    -> el secreto que genera el hook en el panel
//                                (formato v1,whsec_...)
// -----------------------------------------------------------------------------

import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";

// El panel entrega el secreto como "v1,whsec_XXXX". standardwebhooks acepta
// "whsec_XXXX", así que quitamos el prefijo "v1,".
const rawSecret = Deno.env.get("SEND_EMAIL_HOOK_SECRET") ?? "";
const hookSecret = rawSecret.startsWith("v1,") ? rawSecret.slice(3) : rawSecret;

const FROM = "Libre Viaje Chile <noreply@mail.libreviaje.cl>";

interface EmailData {
  token: string;
  token_hash: string;
  redirect_to: string;
  email_action_type: string;
  site_url: string;
}

interface HookPayload {
  user: { email: string };
  email_data: EmailData;
}

/** Asunto y texto según el tipo de correo que pide Supabase. */
function contentFor(actionType: string): { subject: string; heading: string; intro: string } {
  switch (actionType) {
    case "recovery":
      return {
        subject: "Código para restablecer tu contraseña",
        heading: "Restablece tu contraseña",
        intro: "Usa este código para restablecer la contraseña de tu cuenta:",
      };
    case "email_change":
      return {
        subject: "Confirma tu nuevo correo",
        heading: "Confirma tu correo",
        intro: "Usa este código para confirmar tu nuevo correo:",
      };
    case "magiclink":
    case "login":
      return {
        subject: "Tu código de acceso",
        heading: "Inicia sesión",
        intro: "Usa este código para ingresar a Libre Viaje Chile:",
      };
    default: // signup / invite
      return {
        subject: "Tu código de verificación · Libre Viaje Chile",
        heading: "Verifica tu correo",
        intro: "¡Bienvenido a bordo! Usa este código para activar tu cuenta:",
      };
  }
}

function buildHtml(token: string, actionType: string): string {
  const { heading, intro } = contentFor(actionType);
  return `<!doctype html>
<html lang="es">
<body style="margin:0;padding:0;background:#f4f7f3;font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f7f3;padding:32px 16px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;background:#ffffff;border-radius:20px;overflow:hidden;border:1px solid #e1e7dd;">
        <tr>
          <td style="background:linear-gradient(135deg,#63CE33,#3FA81C);padding:28px 32px;">
            <span style="color:#ffffff;font-size:22px;font-weight:800;letter-spacing:-0.3px;">Libre Viaje Chile</span>
          </td>
        </tr>
        <tr>
          <td style="padding:32px;">
            <h1 style="margin:0 0 8px;font-size:22px;color:#0e1e14;">${heading}</h1>
            <p style="margin:0 0 24px;font-size:15px;line-height:1.5;color:#566159;">${intro}</p>
            <div style="text-align:center;margin:8px 0 24px;">
              <div style="display:inline-block;background:#eaf8e1;border:1px solid #cfeabf;border-radius:14px;padding:18px 28px;">
                <span style="font-size:34px;font-weight:800;letter-spacing:10px;color:#3c9a1e;">${token}</span>
              </div>
            </div>
            <p style="margin:0;font-size:13px;line-height:1.5;color:#8b968c;">
              Este código vence en 1 hora. Si no solicitaste esto, ignora este correo.
            </p>
          </td>
        </tr>
        <tr>
          <td style="padding:18px 32px;background:#f4f7f3;border-top:1px solid #e1e7dd;">
            <span style="font-size:12px;color:#8b968c;">Viaja libre. Llega lejos. · Libre Viaje Chile</span>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const payload = await req.text();
  const headers = Object.fromEntries(req.headers);

  let data: HookPayload;
  try {
    const wh = new Webhook(hookSecret);
    data = wh.verify(payload, headers) as HookPayload;
  } catch (_err) {
    // Firma inválida → petición no proviene de Supabase.
    return new Response(
      JSON.stringify({ error: { http_code: 401, message: "Firma inválida" } }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    );
  }

  const { user, email_data } = data;
  const { subject } = contentFor(email_data.email_action_type);

  try {
    const resp = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: FROM,
        to: [user.email],
        subject,
        html: buildHtml(email_data.token, email_data.email_action_type),
      }),
    });
    if (!resp.ok) {
      throw new Error(`Resend ${resp.status}: ${await resp.text()}`);
    }
  } catch (err) {
    console.error("Resend error:", err);
    return new Response(
      JSON.stringify({
        error: { http_code: 500, message: `No se pudo enviar el correo: ${err}` },
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  return new Response(JSON.stringify({}), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});

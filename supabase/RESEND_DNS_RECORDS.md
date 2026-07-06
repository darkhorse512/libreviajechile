# DNS para verificar mail.libreviaje.cl en Resend

Agrega estos **3 registros** en Cloudflare (zona `libreviaje.cl`). Escribe el
"Name" tal cual — Cloudflare añade `.libreviaje.cl` automáticamente. Los TXT/MX
**no** se proxean (sin nube naranja; no aplica a TXT/MX).

| # | Tipo | Name (Cloudflare)            | Contenido / Value                                  | Prioridad |
|---|------|------------------------------|----------------------------------------------------|-----------|
| 1 | TXT  | `resend._domainkey.mail`     | `p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCXECLNGh9C4grOipJzYoA1EMIH//Dm/adZ8yIgbHenIoVAEaHc8oMfVC6xmrowBVqG4/DyhJJDPFgsbPWmaN0uiDHaWMHG5+z6Yo0NGq7R+OINDLE7lRNDrDhfv8hg0B2AyulTaqJhV+zniHGefS5rHnnk3z0TdLW+p2EqZM2w7QIDAQAB` | — |
| 2 | MX   | `send.mail`                  | `feedback-smtp.sa-east-1.amazonses.com`            | `10`      |
| 3 | TXT  | `send.mail`                  | `v=spf1 include:amazonses.com ~all`                | — |

Notas:
- El registro 1 (DKIM) es un solo valor largo; pégalo completo.
- Registro 2 es tipo **MX** con prioridad **10**.
- TTL: Auto está bien.

Luego: Resend → Domains → `mail.libreviaje.cl` → **Verify DNS Records**. El estado
debe pasar de `not_started` a `verified` (con Cloudflare suele tardar minutos).

# Libre Viaje Chile · Panel de Administración

Panel web para administrar la plataforma **Libre Viaje Chile**: dashboard con
métricas, gestión de usuarios, verificación de conductores, monitoreo de viajes
(con mapa OpenStreetMap) y calificaciones.

Construido con **React + Vite + Tailwind CSS**, conectado al **mismo backend de
Supabase** que la app móvil. Los mapas usan **OpenStreetMap** (100% gratis, sin
API key). Listo para desplegar en **Netlify**.

---

## 🧱 Stack

- React 18 + Vite 5
- Tailwind CSS 3
- React Router 6
- Supabase JS (auth + datos, respetando RLS)
- Recharts (gráficos del dashboard)
- React-Leaflet + OpenStreetMap (mapa de viajes)
- lucide-react (iconos)

## ✨ Funcionalidades

- **Login solo para admins** — verifica `profiles.role === 'admin'`; cualquier
  otra cuenta es rechazada y se cierra la sesión.
- **Dashboard** — usuarios, viajes, ingresos, conductores en línea, tendencia de
  14 días, viajes por estado y ciudades top.
- **Usuarios** — búsqueda, filtro por rol, banear / reactivar cuentas.
- **Conductores** — verificar / quitar verificación, estado en línea, datos del
  vehículo, rating.
- **Viajes** — filtros por estado y ciudad, búsqueda, detalle con mapa OSM,
  ofertas y calificaciones.
- **Calificaciones** — listado con filtro por estrellas.

---

## 🚀 Desarrollo local

Requisitos: Node 18+ (recomendado 20).

```bash
cd admin
cp .env.example .env      # completa con tus credenciales de Supabase
npm install
npm run dev               # http://localhost:5173
```

Variables de entorno (las **mismas** que usa la app móvil, en *Supabase →
Project Settings → API*):

```
VITE_SUPABASE_URL=https://TU-PROYECTO.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key
```

## 👤 Crear un administrador

El panel solo deja entrar a usuarios con rol `admin`. Registra la cuenta (desde
la app o el dashboard de Supabase) y luego, en el **SQL Editor** de Supabase:

```sql
update public.profiles set role = 'admin' where id = '<uuid-del-usuario>';
```

> Las políticas RLS del esquema ya conceden acceso total a los admins mediante
> la función `is_admin()`, por lo que no se necesitan cambios en la base de
> datos.

---

## ☁️ Despliegue en Netlify

Este proyecto incluye `netlify.toml` con todo configurado (base `admin/`,
`npm run build`, publish `dist`, redirect SPA y Node 20).

### Opción A — Interfaz web
1. *Add new site → Import an existing project* y conecta el repositorio.
2. Netlify detecta `admin/netlify.toml`. Si te pide valores manuales:
   - **Base directory:** `admin`
   - **Build command:** `npm run build`
   - **Publish directory:** `admin/dist`
3. En *Site settings → Environment variables* agrega
   `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY`.
4. *Deploy*.

### Opción B — Netlify CLI
```bash
npm i -g netlify-cli
cd admin
netlify deploy --build --prod
```

---

## 📁 Estructura

```
admin/
├── netlify.toml            # configuración de despliegue
├── src/
│   ├── main.jsx            # entrada; monta AuthProvider + Router
│   ├── App.jsx             # rutas
│   ├── lib/                # supabase, formatos, constantes
│   ├── context/            # AuthContext (login admin)
│   ├── hooks/              # useQuery
│   ├── components/         # Layout, Sidebar, Topbar, TripMap, ui/
│   └── pages/              # Login, Dashboard, Users, Drivers, Trips,
│                           #  TripDetail, Ratings, NotFound
```

## 🔒 Seguridad

- El panel usa la **anon key** (pública). Toda la autorización se aplica en el
  servidor mediante **RLS** de Supabase — la anon key no otorga privilegios por
  sí sola.
- El acceso administrativo depende del rol `admin` en `profiles` y de la función
  `is_admin()` usada en las políticas.

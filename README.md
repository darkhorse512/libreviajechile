# Libre Viaje Chile 🚗

App de transporte de pasajeros para el mercado chileno. El pasajero propone
origen, destino y **el precio que quiere pagar**; los conductores cercanos
**aceptan o envían una contraoferta**, y el pasajero elige al que más le
conviene. Sin comisiones para conductores (MVP). Tarifa mínima: **$1.500 CLP**.

Construida en **Flutter** (Android + iOS), con **Supabase** como backend
(auth + PostgreSQL + realtime). Interfaz en español, con **tema claro y oscuro**.

---

## ✨ Qué incluye esta primera entrega

- **Onboarding** + pantalla de bienvenida con identidad de marca.
- **Registro separado por rol** (flujos distintos para Pasajero y Conductor).
  - Pasajero: datos personales + ciudad.
  - Conductor: asistente de **2 pasos** (datos personales → datos del vehículo).
- **Inicio de sesión** con manejo de errores.
- **Flujo del pasajero**: solicitar viaje (con selector de precio), recibir
  ofertas/contraofertas en tiempo real, aceptar conductor, seguimiento del
  viaje y **calificación**.
- **Flujo del conductor**: interruptor en línea/desconectado, feed de
  solicitudes cercanas, **aceptar precio o contraofertar** (con ETA y mensaje),
  gestionar viaje (iniciar/finalizar) y calificar al pasajero.
- **Perfil** por rol con estadísticas, datos del vehículo y selector de tema.
- **Diseño premium**: sistema de colores, tipografía (Plus Jakarta Sans),
  componentes reutilizables y animaciones sutiles.
- **Esquema completo de Supabase** (tablas, RLS, triggers, función `accept_offer`).
- **Modo demostración**: la app **funciona sin configurar Supabase**, con datos
  de prueba y conductores que responden automáticamente para poder ver el flujo
  completo de ofertas.

---

## 🚀 Puesta en marcha

### Requisitos
- Flutter **3.27 o superior** (probado con 3.44.4 / Dart 3.12). Verifica con
  `flutter --version`.
- Las carpetas nativas `android/` e `ios/` ya están incluidas en el repo, y los
  íconos de la app ya están generados a partir de `assets/icon.png`.

### 1. Instalar dependencias y ejecutar
```bash
cd Libreviajechile
flutter pub get
flutter run
```

Las credenciales de Supabase ya están en `.env`, por lo que la app usa el
backend real. **Antes de registrarte, ejecuta el esquema** (ver sección
Supabase) o el registro fallará.

> Si quieres regenerar los íconos tras cambiar `assets/icon.png`:
> `dart run flutter_launcher_icons`.

---

## 📱 Compilar la app Android

### APK de depuración (para probar en tu teléfono)
```bash
flutter build apk --debug
# -> build/app/outputs/flutter-apk/app-debug.apk
```

### APK de lanzamiento (instalable, más liviano)
```bash
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```
Instálalo en un teléfono con depuración USB activada:
```bash
flutter install            # con el dispositivo conectado
# o copia el .apk al teléfono y ábrelo (permite "instalar apps desconocidas")
```

### App Bundle para Google Play
```bash
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab
```

### Firmar para producción (Play Store)
Por defecto el `release` se firma con la clave de depuración. Para publicar:
```bash
keytool -genkey -v -keystore ~/libreviaje.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias libreviaje
```
Crea `android/key.properties`:
```
storePassword=TU_PASSWORD
keyPassword=TU_PASSWORD
keyAlias=libreviaje
storeFile=/ruta/absoluta/libreviaje.jks
```
Y ajusta `android/app/build.gradle.kts` para leer ese `key.properties` en el
`signingConfigs.release` (ver guía oficial de Flutter: *Signing the app*).

### Requisitos del entorno Android
`flutter doctor` debe mostrar el toolchain de Android en verde. Necesitas:
- **Android Studio** (o el *Android SDK command-line tools*).
- Aceptar licencias: `flutter doctor --android-licenses`.

Con Supabase configurado, la app **requiere Internet** (ya declarado el permiso
`INTERNET` en el manifiesto).

---

## 🔌 Conectar Supabase (producción)

1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En **SQL Editor**, pega y ejecuta el contenido de
   [`supabase/schema.sql`](supabase/schema.sql). Crea tablas, RLS y triggers.
3. En **Settings → API**, copia el `Project URL` y la `anon public key`.
4. Copia `.env.example` a `.env` y completa:
   ```env
   SUPABASE_URL=https://tu-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu-anon-key
   ```
5. En **Authentication → Providers → Email**, para pruebas puedes desactivar
   "Confirm email" y así el registro inicia sesión de inmediato.
6. Vuelve a ejecutar `flutter run`. Al detectar credenciales válidas, la app usa
   Supabase automáticamente (deja de usar el modo demostración).

### Crear un administrador
```sql
update public.profiles set role = 'admin' where id = '<uuid-del-usuario>';
```

---

## 🗂️ Estructura del proyecto

```
lib/
├── main.dart                 # Arranque: dotenv, Supabase, SharedPreferences
├── app.dart                  # MaterialApp.router + temas + localización
├── core/
│   ├── config/               # Env, constantes de negocio
│   ├── constants/            # Ciudades de Chile
│   ├── router/               # GoRouter + guardas por rol
│   ├── theme/                # Colores, tema claro/oscuro, controlador de tema
│   └── utils/                # Formateadores (CLP) y validadores
├── data/
│   ├── models/               # AppUser, Vehicle, Trip, Offer, enums
│   ├── repositories/         # Interfaces + implementación demo y Supabase
│   └── providers.dart        # Providers de Riverpod
├── features/
│   ├── splash / onboarding
│   ├── auth/                 # Bienvenida, rol, login, registros por rol
│   ├── passenger/            # Shell, inicio, solicitar, detalle, viajes
│   ├── driver/               # Shell, solicitudes, oferta, viajes
│   ├── trips/                # Widgets/acciones compartidas + calificación
│   └── profile/              # Perfil (ambos roles)
└── shared/widgets/           # Botones, campos, tarjetas, avatar, etc.
```

## 🧱 Stack técnico
- **Estado**: Riverpod
- **Ruteo**: go_router (con redirección según sesión y rol)
- **Backend**: supabase_flutter (auth, Postgres, realtime)
- **UI**: Material 3, google_fonts, flutter_animate

---

## 🛣️ Próximos pasos sugeridos
- Integrar mapas y geolocalización (OpenStreetMap / `flutter_map`).
- Notificaciones push (Supabase + FCM) para nuevas ofertas/solicitudes.
- Panel de administración (usuarios y viajes).
- Verificación de documentos del conductor.
- Chat en tiempo real entre pasajero y conductor.

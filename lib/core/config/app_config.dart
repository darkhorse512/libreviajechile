/// Constantes de negocio de EligeDrive.
abstract class AppConfig {
  static const String appName = 'EligeDrive';
  static const String tagline = 'Tú eliges el valor.';

  /// Versión visible de la app (debe coincidir con `version:` en pubspec.yaml).
  /// Sirve para confirmar de un vistazo qué build está instalado.
  static const String appVersion = '0.17.0 (build 26)';

  /// Minutos que una solicitud puede estar abierta sin aceptar una oferta
  /// antes de cancelarse automáticamente.
  static const int tripExpiryMinutes = 5;

  /// Tarifa mínima que un pasajero puede ofrecer (CLP).
  static const int minFareClp = 1500;

  /// Incremento sugerido al ajustar el precio.
  static const int fareStepClp = 500;

  /// Máximo razonable para el selector rápido (CLP).
  static const int maxFareClp = 50000;

  /// Plataforma sin comisión para conductores (MVP).
  static const double driverCommission = 0.0;

  /// Largo del código OTP que envía Supabase por correo.
  /// Debe coincidir con "Email OTP Length" en Supabase (por defecto 6; este
  /// proyecto está configurado en 8).
  static const int otpLength = 8;

  // ---- Distribución de solicitudes por geolocalización ----------------------

  /// Radio (km) alrededor del punto de partida dentro del cual se envían las
  /// solicitudes a los conductores. Configurable.
  static const double requestRadiusKm = 15;

  /// Radio (km) para mostrar conductores disponibles en el mapa del pasajero.
  static const double nearbyDriversRadiusKm = 12;

  /// Un conductor se considera "activo/con ubicación reciente" si reportó su
  /// posición hace menos de estos segundos.
  static const int presenceStaleSeconds = 120;

  /// Cada cuántos segundos el conductor en línea reporta su ubicación GPS.
  static const int presenceIntervalSeconds = 15;
}

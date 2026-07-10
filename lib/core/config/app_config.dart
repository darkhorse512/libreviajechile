/// Constantes de negocio de Libre Viaje Chile.
abstract class AppConfig {
  static const String appName = 'Libre Viaje Chile';
  static const String tagline = 'Viaja libre. Llega lejos.';

  /// Versión visible de la app (debe coincidir con `version:` en pubspec.yaml).
  /// Sirve para confirmar de un vistazo qué build está instalado.
  static const String appVersion = '0.6.0 (build 6)';

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
}

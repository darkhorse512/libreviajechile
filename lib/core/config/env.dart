import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso tipado a las variables de entorno (.env).
abstract class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');
  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR-PROJECT');

  /// Activa las notificaciones push. Se pone en `true` solo después de
  /// configurar Firebase (ver PUSH_SETUP.md). Por defecto está desactivado
  /// para que la app compile y funcione sin Firebase.
  static bool get pushEnabled =>
      dotenv.get('PUSH_ENABLED', fallback: 'false').toLowerCase() == 'true';
}

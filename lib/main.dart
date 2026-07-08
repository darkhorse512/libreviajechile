import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/services/push_service.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables de entorno (.env). No falla si el archivo no existe.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Sin .env → la app arranca en modo demostración.
  }

  await initializeDateFormatting('es', null);

  // Inicializa Supabase solo si hay credenciales válidas.
  if (Env.isConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      // La clave puede ser una "publishable key" (sb_publishable_...) o la
      // anon key clásica (JWT). Ambas son válidas como clave pública.
      publishableKey: Env.supabaseAnonKey,
    );

    // Notificaciones push (no-op salvo que PUSH_ENABLED=true).
    await PushService.initialize();
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LibreViajeApp(),
    ),
  );
}

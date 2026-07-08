import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../../firebase_options.dart';

/// Manejador de mensajes en segundo plano. Debe ser una función de nivel
/// superior. El sistema operativo muestra la notificación automáticamente
/// cuando la app está en segundo plano o cerrada, así que no hace falta más.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Intencionalmente vacío: la notificación se despliega sola.
}

/// Servicio de notificaciones push (FCM).
///
/// Está **desactivado por defecto** y solo se inicializa si `PUSH_ENABLED=true`
/// en el `.env` (tras configurar Firebase). Toda la lógica está protegida con
/// try/catch para que un problema de configuración nunca rompa la app.
class PushService {
  PushService._();

  static bool _started = false;

  /// Inicializa Firebase Messaging, pide permiso y registra el token del
  /// dispositivo. No hace nada si las push están desactivadas.
  static Future<void> initialize() async {
    if (_started || !Env.pushEnabled) return;
    _started = true;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      await _syncToken();
      messaging.onTokenRefresh.listen((_) => _syncToken());

      // Guarda/borra el token según el estado de sesión.
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        switch (data.event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.tokenRefreshed:
            _syncToken();
            break;
          case AuthChangeEvent.signedOut:
            _removeToken();
            break;
          default:
            break;
        }
      });
    } catch (e) {
      debugPrint('PushService deshabilitado: $e');
    }
  }

  /// Registra el token FCM del dispositivo para el usuario autenticado.
  static Future<void> _syncToken() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token',
      );
    } catch (e) {
      debugPrint('No se pudo guardar el token push: $e');
    }
  }

  /// Elimina el token al cerrar sesión (para no seguir notificando a ese
  /// dispositivo).
  static Future<void> _removeToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('token', token);
    } catch (_) {
      // Silencioso: no es crítico.
    }
  }
}

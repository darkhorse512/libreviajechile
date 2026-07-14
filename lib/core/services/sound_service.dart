import 'package:audioplayers/audioplayers.dart';

/// Reproduce los sonidos de notificación de la app.
///
/// Los archivos viven en `assets/` (declarados en pubspec). `AssetSource`
/// antepone `assets/` automáticamente, por eso solo se pasa el nombre.
abstract class SoundService {
  static final AudioPlayer _player = AudioPlayer(playerId: 'notif')
    ..setReleaseMode(ReleaseMode.stop);

  static Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset), volume: 1.0);
    } catch (_) {
      // Silencioso: el sonido nunca debe romper el flujo.
    }
  }

  /// Nueva solicitud (conductor) / nueva oferta (pasajero).
  static Future<void> request() => _play('request.aac');

  /// Oferta aceptada (conductor elegido).
  static Future<void> accept() => _play('accept.aac');
}

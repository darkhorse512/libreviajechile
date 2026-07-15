import 'package:audioplayers/audioplayers.dart';

/// Reproduce los sonidos de notificación de la app.
///
/// Usa archivos MP3 en `assets/` (más compatibles que AAC/ADTS en Android).
/// `AssetSource` antepone `assets/` automáticamente.
abstract class SoundService {
  static final AudioPlayer _player = AudioPlayer(playerId: 'notif');
  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (_initialized) return;
    _initialized = true;
    await _player.setReleaseMode(ReleaseMode.stop);
    // Reproduce como sonido de notificación: usa el volumen de notificaciones
    // (normalmente activo) y suena aunque el volumen multimedia esté bajo.
    await _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notification,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  static Future<void> _play(String asset) async {
    try {
      await _ensureInit();
      await _player.stop();
      await _player.setVolume(1.0);
      await _player.play(AssetSource(asset), volume: 1.0);
    } catch (_) {
      // Silencioso: el sonido nunca debe romper el flujo.
    }
  }

  /// Nueva solicitud (conductor) / nueva oferta (pasajero).
  static Future<void> request() => _play('request.mp3');

  /// Oferta aceptada (conductor elegido).
  static Future<void> accept() => _play('accept.mp3');
}

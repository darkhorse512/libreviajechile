import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Acceso a la ubicación GPS del dispositivo (opcional para el usuario).
class LocationService {
  /// Intenta obtener la posición actual. Devuelve `null` si el servicio está
  /// deshabilitado o el permiso fue denegado (el flujo sigue funcionando sin GPS).
  static Future<LatLng?> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}

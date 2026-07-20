import '../../data/models/trip.dart';
import '../config/app_config.dart';
import 'geo_utils.dart';

/// Segundo filtro de distribución de solicitudes: dentro de un radio
/// configurable del conductor. (El primer filtro, por ciudad, se aplica en el
/// servidor.) Los viajes sin coordenadas de origen se incluyen por ciudad.
List<Trip> tripsWithinRadius(List<Trip> trips, double lat, double lng) {
  return trips.where((t) {
    if (t.originLat == null || t.originLng == null) return true;
    return GeoUtils.distanceKm(lat, lng, t.originLat!, t.originLng!) <=
        AppConfig.requestRadiusKm;
  }).toList();
}

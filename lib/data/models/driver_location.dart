/// Ubicación en vivo de un conductor disponible (para el mapa del pasajero).
class DriverLocation {
  const DriverLocation({
    required this.id,
    required this.lat,
    required this.lng,
  });

  final String id;
  final double lat;
  final double lng;

  factory DriverLocation.fromMap(Map<String, dynamic> map) => DriverLocation(
        id: map['id'] as String,
        lat: (map['last_lat'] as num).toDouble(),
        lng: (map['last_lng'] as num).toDouble(),
      );
}

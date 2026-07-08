import 'dart:math' as math;

/// Ciudades/comunas principales de Chile para el selector de ciudad del MVP.
/// Ordenadas de norte a sur por región.
class ChileanCity {
  const ChileanCity({
    required this.name,
    required this.region,
    required this.lat,
    required this.lng,
  });

  final String name;
  final String region;

  /// Centro aproximado de la ciudad. Se usa para centrar el mapa al elegir
  /// origen/destino, evitando pedir la ubicación GPS cuando no es necesaria.
  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is ChileanCity && other.name == name && other.region == region;

  @override
  int get hashCode => Object.hash(name, region);
}

const List<ChileanCity> kChileanCities = [
  ChileanCity(name: 'Arica', region: 'Arica y Parinacota', lat: -18.4783, lng: -70.3126),
  ChileanCity(name: 'Iquique', region: 'Tarapacá', lat: -20.2133, lng: -70.1503),
  ChileanCity(name: 'Alto Hospicio', region: 'Tarapacá', lat: -20.2508, lng: -70.1108),
  ChileanCity(name: 'Antofagasta', region: 'Antofagasta', lat: -23.6509, lng: -70.3975),
  ChileanCity(name: 'Calama', region: 'Antofagasta', lat: -22.4544, lng: -68.9294),
  ChileanCity(name: 'Copiapó', region: 'Atacama', lat: -27.3668, lng: -70.3323),
  ChileanCity(name: 'La Serena', region: 'Coquimbo', lat: -29.9027, lng: -71.2519),
  ChileanCity(name: 'Coquimbo', region: 'Coquimbo', lat: -29.9533, lng: -71.3436),
  ChileanCity(name: 'Ovalle', region: 'Coquimbo', lat: -30.6011, lng: -71.1998),
  ChileanCity(name: 'Valparaíso', region: 'Valparaíso', lat: -33.0472, lng: -71.6127),
  ChileanCity(name: 'Viña del Mar', region: 'Valparaíso', lat: -33.0245, lng: -71.5518),
  ChileanCity(name: 'Quilpué', region: 'Valparaíso', lat: -33.0472, lng: -71.4419),
  ChileanCity(name: 'San Antonio', region: 'Valparaíso', lat: -33.5928, lng: -71.6127),
  ChileanCity(name: 'Santiago', region: 'Metropolitana', lat: -33.4489, lng: -70.6693),
  ChileanCity(name: 'Maipú', region: 'Metropolitana', lat: -33.5110, lng: -70.7580),
  ChileanCity(name: 'Puente Alto', region: 'Metropolitana', lat: -33.6117, lng: -70.5756),
  ChileanCity(name: 'La Florida', region: 'Metropolitana', lat: -33.5225, lng: -70.5989),
  ChileanCity(name: 'Las Condes', region: 'Metropolitana', lat: -33.4088, lng: -70.5679),
  ChileanCity(name: 'Providencia', region: 'Metropolitana', lat: -33.4314, lng: -70.6093),
  ChileanCity(name: 'Rancagua', region: "O'Higgins", lat: -34.1708, lng: -70.7444),
  ChileanCity(name: 'Talca', region: 'Maule', lat: -35.4264, lng: -71.6554),
  ChileanCity(name: 'Curicó', region: 'Maule', lat: -34.9854, lng: -71.2394),
  ChileanCity(name: 'Chillán', region: 'Ñuble', lat: -36.6067, lng: -72.1034),
  ChileanCity(name: 'Concepción', region: 'Biobío', lat: -36.8270, lng: -73.0503),
  ChileanCity(name: 'Talcahuano', region: 'Biobío', lat: -36.7249, lng: -73.1169),
  ChileanCity(name: 'Los Ángeles', region: 'Biobío', lat: -37.4697, lng: -72.3537),
  ChileanCity(name: 'Temuco', region: 'La Araucanía', lat: -38.7359, lng: -72.5904),
  ChileanCity(name: 'Valdivia', region: 'Los Ríos', lat: -39.8142, lng: -73.2459),
  ChileanCity(name: 'Osorno', region: 'Los Lagos', lat: -40.5735, lng: -73.1348),
  ChileanCity(name: 'Puerto Montt', region: 'Los Lagos', lat: -41.4693, lng: -72.9424),
  ChileanCity(name: 'Coyhaique', region: 'Aysén', lat: -45.5712, lng: -72.0685),
  ChileanCity(name: 'Punta Arenas', region: 'Magallanes', lat: -53.1638, lng: -70.9171),
];

/// Busca las coordenadas de una ciudad por nombre. Devuelve el centro de
/// Santiago como respaldo si no se encuentra.
ChileanCity cityByName(String? name) {
  if (name == null) return kChileanCities[13]; // Santiago
  for (final c in kChileanCities) {
    if (c.name == name) return c;
  }
  return kChileanCities[13];
}

/// Ciudad de la lista más cercana a unas coordenadas. Útil para autoseleccionar
/// la ciudad del viaje a partir de la ubicación GPS del pasajero.
ChileanCity nearestCity(double lat, double lng) {
  var best = kChileanCities.first;
  var bestDist = double.infinity;
  for (final c in kChileanCities) {
    final d = distanceKm(lat, lng, c.lat, c.lng);
    if (d < bestDist) {
      bestDist = d;
      best = c;
    }
  }
  return best;
}

/// Región asociada a una ciudad (o null si no está en la lista).
String? regionByCity(String? name) {
  if (name == null) return null;
  for (final c in kChileanCities) {
    if (c.name == name) return c.region;
  }
  return null;
}

String _normCity(String? s) => (s ?? '').trim().toLowerCase();

/// Distancia aproximada en kilómetros entre dos coordenadas (fórmula de
/// Haversine). Suficiente para decidir si un viaje está "cerca" del conductor.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double toRad(double d) => d * math.pi / 180.0;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// Decide si un viaje debe aparecer en el feed de un conductor.
///
/// Prioriza la **cercanía geográfica** (usando el origen del viaje y el punto
/// de referencia del conductor). Si el viaje no tiene coordenadas (datos
/// antiguos), cae a coincidencia por **región** y, en último caso, por nombre
/// de ciudad. Esto evita que un pasajero y un conductor de la misma zona no se
/// encuentren solo por haber elegido comunas distintas.
bool tripInDriverArea({
  double? tripLat,
  double? tripLng,
  required String tripCity,
  required double refLat,
  required double refLng,
  String? refCity,
  double radiusKm = 60,
}) {
  if (tripLat != null && tripLng != null) {
    return distanceKm(refLat, refLng, tripLat, tripLng) <= radiusKm;
  }
  final r1 = regionByCity(tripCity);
  final r2 = regionByCity(refCity);
  if (r1 != null && r2 != null) return r1 == r2;
  return _normCity(tripCity) == _normCity(refCity);
}

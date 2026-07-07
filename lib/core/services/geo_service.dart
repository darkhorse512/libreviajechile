import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Un lugar geolocalizado: coordenadas + una dirección legible.
class GeoPlace {
  const GeoPlace({
    required this.lat,
    required this.lng,
    required this.address,
    this.shortName,
  });

  final double lat;
  final double lng;

  /// Dirección completa para mostrar (línea principal).
  final String address;

  /// Nombre corto opcional (ej. "Costanera Center").
  final String? shortName;

  LatLng get latLng => LatLng(lat, lng);

  GeoPlace copyWith({double? lat, double? lng, String? address}) => GeoPlace(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        address: address ?? this.address,
        shortName: shortName,
      );
}

/// Resultado de una ruta calculada por OSRM.
class GeoRoute {
  const GeoRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  double get distanceKm => distanceMeters / 1000;
  int get durationMinutes => (durationSeconds / 60).round();

  String get distanceLabel => distanceKm < 1
      ? '${distanceMeters.round()} m'
      : '${distanceKm.toStringAsFixed(1)} km';

  String get durationLabel {
    final m = durationMinutes;
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '$h h' : '$h h $rem min';
  }
}

/// Servicio de geocodificación y rutas basado 100% en servicios gratuitos de
/// OpenStreetMap:
///  - Nominatim  → búsqueda de direcciones y geocodificación inversa.
///  - OSRM       → cálculo de ruta (polilínea, distancia y duración).
///
/// No requiere API key ni tarjeta de crédito. Se respeta la política de uso de
/// Nominatim enviando un `User-Agent` identificable y limitando la frecuencia.
class GeoService {
  GeoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _userAgent = 'LibreViajeChile/1.0 (contacto@libreviajechile.cl)';
  static const _nominatim = 'https://nominatim.openstreetmap.org';
  static const _osrm = 'https://router.project-osrm.org';

  // Sesgamos las búsquedas hacia Chile.
  static const _countryCodes = 'cl';

  Map<String, String> get _headers => {
        'User-Agent': _userAgent,
        'Accept': 'application/json',
        'Accept-Language': 'es',
      };

  /// Busca direcciones que coincidan con [query]. Si se entrega [near], los
  /// resultados se priorizan alrededor de ese punto.
  Future<List<GeoPlace>> search(String query, {LatLng? near}) async {
    final q = query.trim();
    if (q.length < 3) return const [];

    final params = {
      'q': q,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '8',
      'countrycodes': _countryCodes,
    };
    if (near != null) {
      // viewbox alrededor del punto (~0.5°) + bounded para acotar resultados.
      const d = 0.6;
      params['viewbox'] =
          '${near.longitude - d},${near.latitude + d},${near.longitude + d},${near.latitude - d}';
    }

    final uri = Uri.parse('$_nominatim/search').replace(queryParameters: params);
    try {
      final res = await _client.get(uri, headers: _headers).timeout(
            const Duration(seconds: 12),
          );
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map(_placeFromNominatim).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Geocodificación inversa: coordenada → dirección legible.
  Future<GeoPlace?> reverse(LatLng point) async {
    final uri = Uri.parse('$_nominatim/reverse').replace(queryParameters: {
      'lat': '${point.latitude}',
      'lon': '${point.longitude}',
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '18',
    });
    try {
      final res = await _client.get(uri, headers: _headers).timeout(
            const Duration(seconds: 12),
          );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['error'] != null) {
        return GeoPlace(
          lat: point.latitude,
          lng: point.longitude,
          address: 'Ubicación seleccionada',
        );
      }
      return _placeFromNominatim(data);
    } catch (_) {
      return GeoPlace(
        lat: point.latitude,
        lng: point.longitude,
        address: 'Ubicación seleccionada',
      );
    }
  }

  /// Calcula la ruta en auto entre dos puntos usando OSRM.
  Future<GeoRoute?> route(LatLng origin, LatLng destination) async {
    final coords =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';
    final uri = Uri.parse('$_osrm/route/v1/driving/$coords').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      },
    );
    try {
      final res = await _client.get(uri, headers: _headers).timeout(
            const Duration(seconds: 12),
          );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return null;
      final r = routes.first as Map<String, dynamic>;
      final geometry = r['geometry'] as Map<String, dynamic>;
      final coordsList = geometry['coordinates'] as List<dynamic>;
      final points = coordsList
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
      return GeoRoute(
        points: points,
        distanceMeters: (r['distance'] as num).toDouble(),
        durationSeconds: (r['duration'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  GeoPlace _placeFromNominatim(dynamic json) {
    final map = json as Map<String, dynamic>;
    final address = map['address'] as Map<String, dynamic>?;
    final display = (map['display_name'] as String?) ?? 'Ubicación';

    // Nombre corto: preferimos el "name" del POI o la calle+número.
    String? short = map['name'] as String?;
    if ((short == null || short.isEmpty) && address != null) {
      final road = address['road'] as String?;
      final number = address['house_number'] as String?;
      if (road != null) short = number != null ? '$road $number' : road;
    }

    return GeoPlace(
      lat: double.parse(map['lat'].toString()),
      lng: double.parse(map['lon'].toString()),
      address: display,
      shortName: (short != null && short.isNotEmpty) ? short : null,
    );
  }
}

final geoServiceProvider = Provider<GeoService>((ref) {
  final service = GeoService();
  ref.onDispose(() => service._client.close());
  return service;
});

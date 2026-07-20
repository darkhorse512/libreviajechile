import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/location_service.dart';
import '../../../data/providers.dart';
import 'car_marker.dart';

/// Mapa de Google en vivo para la pantalla de inicio del pasajero (estilo
/// inDrive): muestra la ubicación actual y los conductores disponibles cercanos
/// en tiempo real, con marcadores de auto personalizados.
class HomeLiveMap extends ConsumerStatefulWidget {
  const HomeLiveMap({super.key});

  @override
  ConsumerState<HomeLiveMap> createState() => _HomeLiveMapState();
}

class _HomeLiveMapState extends ConsumerState<HomeLiveMap> {
  // Temuco por defecto (marca "made in Temuco") hasta obtener el GPS.
  static const _temuco = LatLng(-38.7359, -72.5904);

  GoogleMapController? _controller;
  bool _myLocationEnabled = false;
  LatLng? _me;
  BitmapDescriptor? _carIcon;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();
  }

  Future<void> _loadCarIcon() async {
    final icon = await buildCarMarker();
    if (mounted) setState(() => _carIcon = icon);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    final pos = await LocationService.current();
    if (!mounted) return;
    if (pos == null) return;
    setState(() {
      _myLocationEnabled = true;
      _me = LatLng(pos.latitude, pos.longitude);
    });
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_me!, 15.5),
    );
  }

  Future<void> _recenter() => _goToMyLocation();

  /// Redondea la ubicación (~1 km) para no re-suscribir el stream por cada
  /// pequeño movimiento del pasajero.
  NearbyQuery? get _query {
    final me = _me;
    if (me == null) return null;
    double round(double v) => (v * 100).roundToDouble() / 100;
    return (lat: round(me.latitude), lng: round(me.longitude));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Conductores disponibles cercanos (tiempo real).
    final markers = <Marker>{};
    final query = _query;
    if (query != null && _carIcon != null) {
      final drivers = ref.watch(nearbyDriversProvider(query)).valueOrNull ??
          const [];
      for (final d in drivers) {
        markers.add(Marker(
          markerId: MarkerId('driver_${d.id}'),
          position: LatLng(d.lat, d.lng),
          icon: _carIcon!,
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ));
      }
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(target: _temuco, zoom: 13),
          myLocationEnabled: _myLocationEnabled,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          markers: markers,
          style: isDark ? _darkMapStyle : null,
          onMapCreated: (c) {
            _controller = c;
            _goToMyLocation();
          },
        ),
        // Contador de conductores disponibles cerca.
        if (markers.isNotEmpty)
          Positioned(
            left: 12,
            bottom: 26,
            child: _NearbyBadge(count: markers.length),
          ),
        // Botón "mi ubicación".
        Positioned(
          right: 12,
          bottom: 26,
          child: FloatingActionButton.small(
            heroTag: 'home-map-loc',
            onPressed: _recenter,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}

class _NearbyBadge extends StatelessWidget {
  const _NearbyBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_car_rounded, size: 16),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Estilo oscuro para Google Maps (coherente con el tema nocturno EligeDrive).
const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d2229"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#9aa0a6"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#12151a"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2b313a"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#12151a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3a4150"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9aa0a6"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0f141a"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#181c22"}]}
]
''';

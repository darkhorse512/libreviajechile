import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/location_service.dart';

/// Mapa de Google en vivo para la pantalla de inicio del pasajero (estilo
/// inDrive): muestra la ubicación actual y sirve de "hero" visual.
class HomeLiveMap extends StatefulWidget {
  const HomeLiveMap({super.key});

  @override
  State<HomeLiveMap> createState() => _HomeLiveMapState();
}

class _HomeLiveMapState extends State<HomeLiveMap> {
  // Temuco por defecto (marca "made in Temuco") hasta obtener el GPS.
  static const _temuco = LatLng(-38.7359, -72.5904);

  GoogleMapController? _controller;
  bool _myLocationEnabled = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    final pos = await LocationService.current();
    if (!mounted) return;
    if (pos == null) return;
    // El permiso está concedido → habilita el punto azul y centra la cámara.
    setState(() => _myLocationEnabled = true);
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15.5),
    );
  }

  Future<void> _recenter() => _goToMyLocation();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(target: _temuco, zoom: 13),
          myLocationEnabled: _myLocationEnabled,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          style: isDark ? _darkMapStyle : null,
          onMapCreated: (c) {
            _controller = c;
            _goToMyLocation();
          },
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

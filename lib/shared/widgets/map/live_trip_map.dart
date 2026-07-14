import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'map_common.dart';

/// Mapa de seguimiento en vivo: muestra el punto de partida, el destino y la
/// posición actual del conductor (si está disponible), y ajusta el encuadre.
class LiveTripMap extends StatelessWidget {
  const LiveTripMap({
    super.key,
    required this.origin,
    required this.destination,
    this.driver,
    this.height = 220,
  });

  final LatLng origin;
  final LatLng destination;
  final LatLng? driver;
  final double height;

  @override
  Widget build(BuildContext context) {
    final points = <LatLng>[origin, destination, if (driver != null) driver!];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(48),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            osmTileLayer(),
            PolylineLayer(polylines: [
              Polyline(
                points: [origin, destination],
                strokeWidth: 4,
                color: AppColors.brand.withValues(alpha: 0.6),
              ),
            ]),
            MarkerLayer(markers: [
              Marker(
                point: origin,
                width: 34,
                height: 40,
                alignment: Alignment.topCenter,
                child:
                    const MapPin(color: AppColors.brand, icon: Icons.trip_origin),
              ),
              Marker(
                point: destination,
                width: 34,
                height: 40,
                alignment: Alignment.topCenter,
                child:
                    const MapPin(color: AppColors.danger, icon: Icons.location_on),
              ),
              if (driver != null)
                Marker(
                  point: driver!,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
            ]),
            const OsmAttribution(),
          ],
        ),
      ),
    );
  }
}

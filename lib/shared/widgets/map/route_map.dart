import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/i18n/i18n.dart';
import '../../../core/services/geo_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'map_common.dart';

/// Vista de mapa (no interactiva por defecto) que muestra el trazado
/// origen → destino con la ruta calculada por OSRM, más una insignia con
/// distancia y tiempo estimado.
class RouteMap extends ConsumerStatefulWidget {
  const RouteMap({
    super.key,
    required this.origin,
    required this.destination,
    this.height = 190,
    this.interactive = false,
    this.showBadge = true,
    this.onTap,
  });

  final LatLng origin;
  final LatLng destination;
  final double height;
  final bool interactive;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  ConsumerState<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends ConsumerState<RouteMap> {
  GeoRoute? _route;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final route = await ref
        .read(geoServiceProvider)
        .route(widget.origin, widget.destination);
    if (!mounted) return;
    setState(() {
      _route = route;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = _route?.points ??
        [widget.origin, widget.destination]; // línea recta como respaldo
    final bounds = LatLngBounds.fromPoints([widget.origin, widget.destination]);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(48),
                ),
                interactionOptions: InteractionOptions(
                  flags: widget.interactive
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
                onTap: widget.onTap == null ? null : (_, __) => widget.onTap!(),
              ),
              children: [
                osmTileLayer(),
                PolylineLayer(polylines: [routePolyline(points)]),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.origin,
                      width: 34,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const MapPin(
                          color: AppColors.brand, icon: Icons.trip_origin),
                    ),
                    Marker(
                      point: widget.destination,
                      width: 34,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const MapPin(
                          color: AppColors.danger, icon: Icons.location_on),
                    ),
                  ],
                ),
                const OsmAttribution(),
              ],
            ),
            if (_loading)
              const Positioned(
                top: 10,
                left: 10,
                child: _MiniChip(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (widget.showBadge && _route != null)
              Positioned(
                top: 10,
                left: 10,
                child: _MiniChip(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.route_rounded,
                          size: 14, color: AppColors.brand),
                      const SizedBox(width: 5),
                      Text(
                        '${_route!.distanceLabel} · ${_route!.durationLabel}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.onTap != null)
              const Positioned(
                bottom: 8,
                right: 8,
                child: _MiniChip(
                  child: Icon(Icons.open_in_full_rounded, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vista de ruta a pantalla completa (mapa interactivo).
class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({
    super.key,
    required this.origin,
    required this.destination,
    this.title = 'Ruta del viaje',
  });

  final LatLng origin;
  final LatLng destination;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required LatLng origin,
    required LatLng destination,
    String title = 'Ruta del viaje',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RouteMapScreen(
          origin: origin,
          destination: destination,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(title))),
      body: RouteMap(
        origin: origin,
        destination: destination,
        height: double.infinity,
        interactive: true,
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

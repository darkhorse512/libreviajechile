import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme/app_colors.dart';

/// Identificador enviado en las peticiones de tiles (política de uso de OSM).
const kOsmPackageName = 'cl.libreviajechile.app';

/// Capa de tiles estándar de OpenStreetMap (gratuita, sin API key).
TileLayer osmTileLayer() => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: kOsmPackageName,
      maxZoom: 19,
      // Un color de fondo mientras cargan los tiles evita parpadeos en blanco.
      tileBuilder: (context, tileWidget, tile) => tileWidget,
    );

/// Atribución obligatoria de OpenStreetMap (esquina inferior).
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key, this.alignment = Alignment.bottomRight});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '© OpenStreetMap',
            style: TextStyle(color: Colors.white, fontSize: 9),
          ),
        ),
      ),
    );
  }
}

/// Marcador tipo "gota" para origen/destino.
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.color, this.icon});
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon ?? Icons.circle, size: 15, color: Colors.white),
        ),
        // Pequeña punta hacia el punto exacto.
        Transform.translate(
          offset: const Offset(0, -3),
          child: Container(
            width: 3,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Estilo de polilínea de ruta reutilizable.
Polyline routePolyline(List points) => Polyline(
      points: List.castFrom(points),
      strokeWidth: 5,
      color: AppColors.brand,
      borderColor: Colors.white,
      borderStrokeWidth: 1.5,
    );

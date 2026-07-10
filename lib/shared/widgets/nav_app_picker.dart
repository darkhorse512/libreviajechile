import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/navigation_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'map/route_map.dart';

/// Muestra un selector para abrir la navegación con **Libre Maps** (mapa propio)
/// o **Waze**. El usuario elige cada vez ("preguntar siempre").
///
/// - [origin] / [destination]: extremos de la ruta (para Libre Maps).
/// - [target]: punto al que se debe navegar en Waze (origen o destino según el
///   momento del viaje).
Future<void> showNavAppPicker(
  BuildContext context, {
  required LatLng origin,
  required LatLng destination,
  required LatLng target,
  String routeTitle = 'Ruta del viaje',
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      Widget option({
        required IconData icon,
        required Color color,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.palette.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: context.palette.textMuted),
                ],
              ),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(context.tr('Abrir con'),
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              option(
                icon: Icons.map_rounded,
                color: AppColors.brand,
                title: 'Libre Maps',
                subtitle: context.tr('Ver la ruta en el mapa'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  RouteMapScreen.show(
                    context,
                    origin: origin,
                    destination: destination,
                    title: routeTitle,
                  );
                },
              ),
              option(
                icon: Icons.navigation_rounded,
                color: AppColors.accent,
                title: 'Waze',
                subtitle: context.tr('Navegación paso a paso'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  NavigationService.openWaze(context, target);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

/// Botón "Navegar" reutilizable que abre el selector de app de mapas.
class NavigateButton extends StatelessWidget {
  const NavigateButton({
    super.key,
    required this.origin,
    required this.destination,
    required this.target,
    this.expand = true,
  });

  final LatLng origin;
  final LatLng destination;
  final LatLng target;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showNavAppPicker(
        context,
        origin: origin,
        destination: destination,
        target: target,
      ),
      icon: const Icon(Icons.navigation_rounded, size: 18),
      label: Text(context.tr('Navegar')),
      style: OutlinedButton.styleFrom(
        minimumSize: expand ? const Size.fromHeight(48) : null,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/surface_card.dart';

/// Color asociado a cada estado de viaje.
Color tripStatusColor(TripStatus status) => switch (status) {
      TripStatus.requested => AppColors.info,
      TripStatus.accepted => AppColors.brand,
      TripStatus.inProgress => AppColors.accent,
      TripStatus.completed => AppColors.successDark,
      TripStatus.cancelled => AppColors.danger,
    };

IconData tripStatusIcon(TripStatus status) => switch (status) {
      TripStatus.requested => Icons.wifi_tethering_rounded,
      TripStatus.accepted => Icons.handshake_rounded,
      TripStatus.inProgress => Icons.navigation_rounded,
      TripStatus.completed => Icons.check_circle_rounded,
      TripStatus.cancelled => Icons.cancel_rounded,
    };

/// Etiqueta de estado del viaje.
class TripStatusPill extends StatelessWidget {
  const TripStatusPill({super.key, required this.status});
  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final color = tripStatusColor(status);
    return InfoPill(label: status.label, icon: tripStatusIcon(status), color: color);
  }
}

/// Visualización origen → destino con línea de conexión.
class TripRoute extends StatelessWidget {
  const TripRoute({
    super.key,
    required this.origin,
    required this.destination,
    this.compact = false,
  });

  final String origin;
  final String destination;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final titleStyle = compact
        ? Theme.of(context).textTheme.bodyMedium
        : Theme.of(context).textTheme.titleMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 4),
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.brand, width: 2.4),
              ),
            ),
            Container(
              width: 2,
              height: compact ? 22 : 30,
              margin: const EdgeInsets.symmetric(vertical: 3),
              color: palette.border,
            ),
            const Icon(Icons.location_on_rounded,
                size: 15, color: AppColors.danger),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(context, 'ORIGEN', origin, titleStyle, palette),
              SizedBox(height: compact ? 12 : 20),
              _line(context, 'DESTINO', destination, titleStyle, palette),
            ],
          ),
        ),
      ],
    );
  }

  Widget _line(BuildContext context, String label, String value,
      TextStyle? valueStyle, AppPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textMuted,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(value,
            style: valueStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Muestra un monto en CLP con estilo destacado.
class FareTag extends StatelessWidget {
  const FareTag({super.key, required this.amount, this.large = false, this.label});
  final int amount;
  final bool large;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (label != null)
          Text(label!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.palette.textMuted,
                  )),
        Text(
          Formatters.clp(amount),
          style: (large
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.titleLarge)
              ?.copyWith(
            color: AppColors.price,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

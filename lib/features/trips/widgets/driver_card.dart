import 'package:flutter/material.dart';

import '../../../core/i18n/i18n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/app_user.dart';
import '../../../shared/widgets/surface_card.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Presentación del conductor con su vehículo y calificación.
class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({super.key, required this.driver, this.showVehicle = true});

  final AppUser driver;
  final bool showVehicle;

  @override
  Widget build(BuildContext context) {
    final vehicle = driver.vehicle;
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(name: driver.fullName, imageUrl: driver.avatarUrl, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(driver.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (driver.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 16, color: AppColors.brand),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingStars(
                            rating: driver.ratingAvg, size: 15, showValue: true),
                        const SizedBox(width: 6),
                        Text(
                            context.trp(
                                '· {n} viajes', {'n': '${driver.tripsCount}'}),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.palette.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showVehicle && vehicle != null) ...[
            const Divider(height: 26),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.directions_car_filled_rounded,
                      color: context.palette.textSecondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.displayName,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text('${vehicle.year} · ${vehicle.color}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.palette.textSecondary,
                              )),
                    ],
                  ),
                ),
                _PlateBadge(plate: vehicle.plate),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge({required this.plate});
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        plate.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

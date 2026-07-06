import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_user.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/theme_toggle_button.dart';
import '../../shared/widgets/user_avatar.dart';
import '../trips/widgets/trip_widgets.dart';
import 'offer_sheet.dart';

class DriverRequestsScreen extends ConsumerWidget {
  const DriverRequestsScreen({super.key});

  Future<void> _toggleOnline(WidgetRef ref, AppUser user, bool value) async {
    await ref.read(authRepositoryProvider).setOnline(user.id, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, ${user.fullName.split(' ').first}',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(user.city ?? 'Chile',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                  ],
                ),
              ),
              const ThemeToggleButton(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _OnlineToggle(
            online: user.isOnline,
            onChanged: (v) => _toggleOnline(ref, user, v),
          ),
        ),
        Expanded(
          child: user.isOnline
              ? _RequestsFeed(user: user)
              : const _OfflineState(),
        ),
      ],
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.online, required this.onChanged});
  final bool online;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.success : context.palette.textMuted;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: online
            ? LinearGradient(colors: [
                AppColors.success.withValues(alpha: 0.16),
                AppColors.success.withValues(alpha: 0.04),
              ])
            : null,
        color: online ? null : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: online ? AppColors.success.withValues(alpha: 0.4) : context.palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              online ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(online ? 'Estás en línea' : 'Estás desconectado',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  online
                      ? 'Recibiendo solicitudes cercanas'
                      : 'Conéctate para recibir viajes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch(value: online, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _OfflineState extends StatelessWidget {
  const _OfflineState();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.toggle_off_rounded,
      title: 'Estás desconectado',
      message:
          'Activa el interruptor para empezar a recibir solicitudes de viaje en tu ciudad.',
    );
  }
}

class _RequestsFeed extends ConsumerWidget {
  const _RequestsFeed({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(openTripsProvider(user.city ?? ''));
    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No pudimos cargar las solicitudes',
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'Sin solicitudes por ahora',
            message: 'Cuando un pasajero cercano solicite un viaje, aparecerá aquí al instante.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _RequestCard(trip: trips[i], driver: user)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.08),
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.trip, required this.driver});
  final Trip trip;
  final AppUser driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passenger = trip.passenger;
    return SurfaceCard(
      elevated: true,
      onTap: () => showOfferSheet(context, trip: trip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                  name: passenger?.fullName ?? 'Pasajero',
                  imageUrl: passenger?.avatarUrl,
                  size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passenger?.fullName ?? 'Pasajero',
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis),
                    if (passenger != null && passenger.hasRatings)
                      RatingStars(
                          rating: passenger.ratingAvg, size: 12, showValue: true),
                  ],
                ),
              ),
              Text(Formatters.relative(trip.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.palette.textMuted,
                      )),
            ],
          ),
          const Divider(height: 22),
          TripRoute(
            origin: trip.originAddress,
            destination: trip.destinationAddress,
            compact: true,
          ),
          if (trip.note != null && trip.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.notes_rounded,
                    size: 14, color: context.palette.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(trip.note!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.palette.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.price.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Text('Ofrece',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.palette.textSecondary,
                        )),
                const SizedBox(width: 8),
                Text(Formatters.clp(trip.offeredFare),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.price,
                          fontWeight: FontWeight.w800,
                        )),
                const Spacer(),
                Row(
                  children: [
                    Text('Responder',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.brand,
                            )),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 18, color: AppColors.brand),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

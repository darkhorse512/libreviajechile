import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/surface_card.dart';
import '../trips/widgets/trip_widgets.dart';

class PassengerTripsScreen extends ConsumerWidget {
  const PassengerTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tripsAsync = ref.watch(passengerTripsProvider(user.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(context.tr('Mis viajes'),
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        Expanded(
          child: tripsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: context.tr('No pudimos cargar tus viajes'),
            ),
            data: (trips) {
              if (trips.isEmpty) {
                return EmptyState(
                  icon: Icons.route_rounded,
                  title: context.tr('Aún no tienes viajes'),
                  message: context.tr('Cuando solicites un viaje aparecerá aquí.'),
                  action: PrimaryButton(
                    label: context.tr('Solicitar viaje'),
                    expand: false,
                    onPressed: () => context.push(Routes.requestTrip),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                itemCount: trips.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _TripTile(trip: trips[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => context.push('${Routes.passengerTrip}/${trip.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TripStatusPill(status: trip.status),
              const Spacer(),
              Text(Formatters.relative(trip.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.palette.textMuted,
                      )),
            ],
          ),
          const SizedBox(height: 14),
          TripRoute(
            origin: trip.originAddress,
            destination: trip.destinationAddress,
            compact: true,
          ),
          const Divider(height: 24),
          Row(
            children: [
              if (trip.isOpen && trip.offersCount > 0)
                InfoPill(
                  label: context
                      .trp('{n} ofertas', {'n': '${trip.offersCount}'}),
                  icon: Icons.local_offer_rounded,
                  color: AppColors.price,
                )
              else if (trip.driver != null)
                Row(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 15, color: context.palette.textMuted),
                    const SizedBox(width: 4),
                    Text(trip.driver!.fullName.split(' ').first,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              const Spacer(),
              Text(
                Formatters.clp(trip.displayFare),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.price,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

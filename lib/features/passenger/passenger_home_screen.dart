import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/theme_toggle_button.dart';
import '../../shared/widgets/user_avatar.dart';
import '../trips/widgets/trip_widgets.dart';

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tripsAsync = ref.watch(passengerTripsProvider(user.id));
    final active = tripsAsync.valueOrNull
        ?.where((t) => t.isOpen || t.isActive)
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.md, AppSpacing.lg, 0),
            child: Row(
              children: [
                UserAvatar(name: user.fullName, imageUrl: user.avatarUrl, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Hola,'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.palette.textSecondary,
                              )),
                      Text(
                        user.fullName.split(' ').first,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const ThemeToggleButton(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: _HeroCard(
              onTap: () => context.push(Routes.requestTrip),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ),
        ),
        if (active != null && active.isNotEmpty) ...[
          _SectionTitle(context.tr('Viaje en curso')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
              child: _ActiveTripCard(trip: active.first),
            ),
          ),
        ],
        _SectionTitle(context.tr('¿Cómo funciona?')),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
            child: _HowItWorks(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brand, AppColors.brandLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.4),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.near_me_rounded, color: Colors.white, size: 30),
              const SizedBox(height: 16),
              Text(
                context.tr('¿A dónde\nvamos hoy?'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                    'Propón tu precio y recibe ofertas de conductores cercanos.'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('Solicitar un viaje'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.brand,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.brand, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      elevated: true,
      onTap: () => context.push('${Routes.passengerTrip}/${trip.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TripStatusPill(status: trip.status),
              const Spacer(),
              if (trip.isOpen && trip.offersCount > 0)
                InfoPill(
                  label: context
                      .trp('{n} ofertas', {'n': '${trip.offersCount}'}),
                  icon: Icons.local_offer_rounded,
                  color: AppColors.price,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TripRoute(
            origin: trip.originAddress,
            destination: trip.destinationAddress,
            compact: true,
          ),
          const Divider(height: 28),
          Row(
            children: [
              Icon(Icons.payments_outlined,
                  size: 18, color: context.palette.textSecondary),
              const SizedBox(width: 8),
              Text(context.tr('Tu oferta'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      )),
              const Spacer(),
              Text(
                Formatters.clp(trip.displayFare),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.edit_location_alt_rounded,
        context.tr('Indica tu viaje'),
        context.trp(
            'Origen, destino y el precio que quieres pagar (mínimo {min}).',
            {'min': Formatters.clp(AppConfig.minFareClp)})
      ),
      (
        Icons.local_offer_rounded,
        context.tr('Recibe ofertas'),
        context.tr('Los conductores aceptan tu precio o te envían una contraoferta.')
      ),
      (
        Icons.verified_rounded,
        context.tr('Elige y viaja'),
        context.tr('Compara calificaciones y vehículos, y confirma tu conductor ideal.')
      ),
    ];
    return SurfaceCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(steps[i].$1, color: AppColors.brand, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[i].$2,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(steps[i].$3,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.palette.textSecondary,
                              )),
                    ],
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1) const Divider(height: 28),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.md),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}

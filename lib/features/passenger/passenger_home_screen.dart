import 'package:flutter/material.dart';
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
import '../../shared/widgets/user_avatar.dart';
import '../trips/widgets/trip_widgets.dart';
import 'widgets/home_live_map.dart';

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tripsAsync = ref.watch(passengerTripsProvider(user.id));
    final activeList =
        tripsAsync.valueOrNull?.where((t) => t.isOpen || t.isActive).toList();
    final active = (activeList != null && activeList.isNotEmpty)
        ? activeList.first
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = constraints.maxHeight * 0.46;
        return Stack(
          children: [
            // ---- Mapa de Google en vivo (hero) --------------------------
            SizedBox(
              height: mapHeight,
              width: double.infinity,
              child: const HomeLiveMap(),
            ),
            // ---- Panel inferior (sobre el mapa) -------------------------
            Positioned(
              left: 0,
              right: 0,
              top: mapHeight - 26,
              bottom: 0,
              child: _HomePanel(active: active),
            ),
            // ---- Saludo flotante sobre el mapa --------------------------
            Positioned(
              top: 8,
              left: AppSpacing.xl,
              child: _GreetingChip(
                name: user.fullName.split(' ').first,
                avatarUrl: user.avatarUrl,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GreetingChip extends StatelessWidget {
  const _GreetingChip({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(name: name, imageUrl: avatarUrl, size: 30),
          const SizedBox(width: 8),
          Text('${context.tr('Hola,')} $name',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({required this.active});
  final Trip? active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, 12, AppSpacing.xl, AppSpacing.xl),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: context.palette.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SearchCta(onTap: () => context.push(Routes.requestTrip)),
          if (active != null) ...[
            const SizedBox(height: 22),
            _PanelTitle(context.tr('Viaje en curso')),
            const SizedBox(height: 12),
            _ActiveTripCard(trip: active!),
          ],
          const SizedBox(height: 22),
          _PanelTitle(context.tr('¿Cómo funciona?')),
          const SizedBox(height: 12),
          const _HowItWorks(),
        ],
      ),
    );
  }
}

/// Barra de búsqueda tipo "¿A dónde vas?" (estilo inDrive) que abre el flujo
/// de solicitud de viaje.
class _SearchCta extends StatelessWidget {
  const _SearchCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('¿A dónde vas?'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: context.palette.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
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

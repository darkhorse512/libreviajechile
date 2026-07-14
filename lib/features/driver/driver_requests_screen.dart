import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/chilean_cities.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../../data/models/offer.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/map/route_map.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../trips/trip_controller.dart';
import '../trips/widgets/trip_widgets.dart';
import 'offer_sheet.dart';

class DriverRequestsScreen extends ConsumerWidget {
  const DriverRequestsScreen({super.key});

  Future<void> _setOnline(
      BuildContext context, WidgetRef ref, AppUser user, bool value) async {
    final notifier = ref.read(currentUserProvider.notifier);
    // Actualización optimista: la UI refleja el cambio al instante.
    notifier.update(user.copyWith(isOnline: value));
    try {
      await ref.read(authRepositoryProvider).setOnline(user.id, value);
      if (context.mounted) {
        value
            ? AppFeedback.success(context,
                context.tr('Estás en línea. Empezarás a recibir solicitudes.'))
            : AppFeedback.info(context, context.tr('Te desconectaste.'));
      }
    } catch (_) {
      // Revierte si falla y avisa al usuario.
      notifier.update(user.copyWith(isOnline: !value));
      if (context.mounted) {
        AppFeedback.error(context,
            context.tr('No pudimos actualizar tu estado. Revisa tu conexión.'));
      }
    }
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
                    Text(
                        context.trp('Hola, {name}',
                            {'name': user.fullName.split(' ').first}),
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(user.city ?? 'Chile',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                  ],
                ),
              ),
              // Espacio reservado para los controles flotantes (tema/idioma).
              const SizedBox(width: 100),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _OnlineToggle(
            online: user.isOnline,
            onChanged: (v) => _setOnline(context, ref, user, v),
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
    return GestureDetector(
      onTap: () => onChanged(!online),
      child: AnimatedContainer(
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
                Text(
                    online
                        ? context.tr('Estás en línea')
                        : context.tr('Estás desconectado'),
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  online
                      ? context.tr('Recibiendo solicitudes cercanas')
                      : context.tr('Ponte en línea para recibir solicitudes'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          // El tap se maneja en toda la tarjeta; el switch es indicador visual.
          IgnorePointer(child: Switch(value: online, onChanged: onChanged)),
        ],
      ),
      ),
    );
  }
}

class _OfflineState extends StatelessWidget {
  const _OfflineState();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.toggle_off_rounded,
      title: context.tr('Estás desconectado'),
      message: context.tr(
          'Activa el interruptor para empezar a recibir solicitudes de viaje en tu ciudad.'),
    );
  }
}

class _RequestsFeed extends ConsumerWidget {
  const _RequestsFeed({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = cityByName(user.city);
    final area =
        DriverArea(city: user.city, lat: city.lat, lng: city.lng);

    // La notificación de "nueva solicitud" (sonido + banner) la maneja
    // DriverNotifications a nivel de shell, para que funcione en todas las
    // pestañas del conductor.
    final tripsAsync = ref.watch(openTripsProvider(area));
    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: context.tr('No pudimos cargar las solicitudes'),
      ),
      data: (trips) {
        if (trips.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_rounded,
            title: context.tr('Sin solicitudes por ahora'),
            message: context.tr(
                'Cuando un pasajero cercano solicite un viaje, aparecerá aquí al instante.'),
          );
        }
        // Ofertas pendientes del conductor, indexadas por viaje.
        final myOffers = {
          for (final o in ref.watch(driverOffersProvider(user.id)).valueOrNull ??
              const <Offer>[])
            if (o.status == OfferStatus.pending) o.tripId: o,
        };
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              _RequestCard(trip: trips[i], myOffer: myOffers[trips[i].id])
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08),
        );
      },
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.trip, this.myOffer});
  final Trip trip;
  final Offer? myOffer;

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    await ref.read(tripActionsProvider).withdrawOffer(myOffer!.id);
    if (context.mounted) AppFeedback.info(context, context.tr('Oferta retirada'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passenger = trip.passenger;
    final offered = myOffer != null;
    return SurfaceCard(
      elevated: true,
      onTap: offered ? null : () => showOfferSheet(context, trip: trip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                  name: passenger?.fullName ?? context.tr('Pasajero'),
                  imageUrl: passenger?.avatarUrl,
                  size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passenger?.fullName ?? context.tr('Pasajero'),
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
          if (trip.hasRoute) ...[
            const SizedBox(height: 12),
            RouteMap(
              origin: LatLng(trip.originLat!, trip.originLng!),
              destination: LatLng(trip.destinationLat!, trip.destinationLng!),
              height: 140,
              onTap: offered ? null : () => showOfferSheet(context, trip: trip),
            ),
          ],
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
                Text(context.tr('Ofrece'),
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
                if (!offered)
                  Row(
                    children: [
                      Text(context.tr('Responder'),
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
          if (offered) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InfoPill(
                    label:
                        '${context.tr('Ofertaste')} ${Formatters.clp(myOffer!.amount)} · ${context.tr('pendiente')}',
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _withdraw(context, ref),
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  label: Text(context.tr('Retirar')),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/contact.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/offer.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/map/route_map.dart';
import '../../shared/widgets/nav_app_picker.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../trips/rate_sheet.dart';
import '../trips/trip_controller.dart';
import '../trips/widgets/driver_card.dart';
import '../trips/widgets/trip_widgets.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  Future<void> _accept(
      BuildContext context, WidgetRef ref, Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('Confirmar conductor')),
        content: Text(
          context.trp(
            'Aceptarás a {name} por {amount}. Se rechazarán las demás ofertas.',
            {
              'name': offer.driver?.fullName ?? context.tr('este conductor'),
              'amount': Formatters.clp(offer.amount),
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Cancelar'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('Confirmar'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(tripActionsProvider).acceptOffer(tripId, offer.id);
      if (context.mounted) {
        AppFeedback.success(
            context, context.tr('¡Conductor confirmado! Buen viaje 🚗'));
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.error(context, context.tr('No se pudo aceptar la oferta'));
      }
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('Cancelar viaje')),
        content:
            Text(context.tr('¿Seguro que quieres cancelar esta solicitud?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('No'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Sí, cancelar')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(tripActionsProvider).cancelTrip(tripId);
    if (context.mounted) AppFeedback.info(context, context.tr('Viaje cancelado'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Tu viaje')),
        actions: [
          if (tripAsync.valueOrNull?.isOpen ?? false)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: context.tr('Cancelar viaje'),
              onPressed: () => _cancel(context, ref),
            ),
          const AppTopControls(),
          const SizedBox(width: 4),
        ],
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: context.tr('No pudimos cargar el viaje'),
        ),
        data: (trip) {
          if (trip == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: context.tr('Viaje no encontrado'),
            );
          }
          return _TripBody(
            trip: trip,
            onAccept: (o) => _accept(context, ref, o),
          );
        },
      ),
    );
  }
}

class _TripBody extends ConsumerWidget {
  const _TripBody({required this.trip, required this.onAccept});
  final Trip trip;
  final ValueChanged<Offer> onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _StatusBanner(trip: trip),
        const SizedBox(height: 16),
        if (trip.hasRoute) ...[
          RouteMap(
            origin: LatLng(trip.originLat!, trip.originLng!),
            destination: LatLng(trip.destinationLat!, trip.destinationLng!),
            onTap: () => RouteMapScreen.show(
              context,
              origin: LatLng(trip.originLat!, trip.originLng!),
              destination: LatLng(trip.destinationLat!, trip.destinationLng!),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TripRoute(
                origin: trip.originAddress,
                destination: trip.destinationAddress,
              ),
              const Divider(height: 28),
              Row(
                children: [
                  InfoPill(
                    label: trip.city,
                    icon: Icons.location_city_rounded,
                    color: context.palette.textSecondary,
                    background: context.palette.surfaceAlt,
                  ),
                  const SizedBox(width: 8),
                  InfoPill(
                    label:
                        '${trip.passengers} ${trip.passengers == 1 ? context.tr('pasajero') : context.tr('pasajeros')}',
                    icon: Icons.people_alt_rounded,
                    color: context.palette.textSecondary,
                    background: context.palette.surfaceAlt,
                  ),
                  const Spacer(),
                  FareTag(
                      amount: trip.displayFare,
                      label: trip.finalFare != null
                          ? context.tr('Acordado')
                          : context.tr('Tu oferta')),
                ],
              ),
              if (trip.note != null && trip.note!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes_rounded,
                          size: 16, color: context.palette.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(trip.note!,
                              style: Theme.of(context).textTheme.bodySmall)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (trip.isOpen) _OffersSection(trip: trip, onAccept: onAccept),
        if (trip.isActive) _AssignedSection(trip: trip),
        if (trip.status == TripStatus.completed) _CompletedSection(trip: trip),
        if (trip.status == TripStatus.cancelled)
          EmptyState(
            icon: Icons.cancel_rounded,
            title: context.tr('Viaje cancelado'),
            message: context.tr('Esta solicitud fue cancelada.'),
          ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final color = tripStatusColor(trip.status);
    final message = switch (trip.status) {
      TripStatus.requested => context.tr(
          'Estamos avisando a los conductores cercanos. Las ofertas aparecerán aquí.'),
      TripStatus.accepted =>
        context.tr('Tu conductor va en camino al punto de partida.'),
      TripStatus.inProgress => context.tr('Disfruta tu viaje. Llegarás pronto.'),
      TripStatus.completed => context.tr('Viaje finalizado. ¡Gracias por viajar!'),
      TripStatus.cancelled => context.tr('Este viaje fue cancelado.'),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (trip.status == TripStatus.requested)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(tripStatusIcon(trip.status), color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr(trip.status.label),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                        )),
                Text(message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OffersSection extends ConsumerWidget {
  const _OffersSection({required this.trip, required this.onAccept});
  final Trip trip;
  final ValueChanged<Offer> onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(tripOffersProvider(trip.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.tr('Ofertas recibidas'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            offersAsync.maybeWhen(
              data: (offers) => offers.isEmpty
                  ? const SizedBox.shrink()
                  : InfoPill(label: '${offers.length}', color: AppColors.price),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        offersAsync.when(
          loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator()),
          ),
          error: (_, __) =>
              Text(context.tr('No se pudieron cargar las ofertas')),
          data: (offers) {
            if (offers.isEmpty) {
              return SurfaceCard(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        context.tr('Esperando ofertas de conductores…'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final offer in offers) ...[
                  _OfferCard(
                    offer: offer,
                    yourFare: trip.offeredFare,
                    onAccept: () => onAccept(offer),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.yourFare,
    required this.onAccept,
  });

  final Offer offer;
  final int yourFare;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final driver = offer.driver;
    final diff = offer.amount - yourFare;
    return SurfaceCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                  name: driver?.fullName ?? context.tr('Conductor'),
                  imageUrl: driver?.avatarUrl,
                  size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(driver?.fullName ?? context.tr('Conductor'),
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (driver?.isVerified ?? false) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 15, color: AppColors.brand),
                        ],
                      ],
                    ),
                    if (driver != null)
                      RatingStars(
                          rating: driver.ratingAvg, size: 13, showValue: true),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.clp(offer.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.price,
                            fontWeight: FontWeight.w800,
                          )),
                  if (offer.isCounter)
                    Text(
                      diff > 0
                          ? '+${Formatters.clp(diff)}'
                          : Formatters.clp(diff),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  else
                    Text(context.tr('Aceptó tu precio'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            )),
                ],
              ),
            ],
          ),
          if (driver?.vehicle != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.directions_car_filled_rounded,
                    size: 16, color: context.palette.textMuted),
                const SizedBox(width: 6),
                Text(driver!.vehicle!.summary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        )),
                const Spacer(),
                if (offer.etaMinutes != null)
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14, color: context.palette.textMuted),
                      const SizedBox(width: 4),
                      Text(
                          context.trp(
                              '{n} min', {'n': '${offer.etaMinutes}'}),
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
              ],
            ),
          ],
          if (offer.message != null && offer.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.palette.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text('“${offer.message!}”',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ),
          ],
          const SizedBox(height: 14),
          PrimaryButton(
            label: '${context.tr('Aceptar por')} ${Formatters.clp(offer.amount)}',
            icon: Icons.check_rounded,
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}

class _AssignedSection extends StatelessWidget {
  const _AssignedSection({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final driver = trip.driver;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('Tu conductor'),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (driver != null) DriverInfoCard(driver: driver),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Contact.call(context, driver?.phone),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: Text(context.tr('Llamar')),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Contact.whatsapp(context, driver?.phone,
                    message:
                        context.tr('Hola! Soy tu pasajero de Libre Viaje Chile.')),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('WhatsApp'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
            ),
          ],
        ),
        if (trip.hasRoute) ...[
          const SizedBox(height: 12),
          NavigateButton(
            origin: LatLng(trip.originLat!, trip.originLng!),
            destination: LatLng(trip.destinationLat!, trip.destinationLng!),
            target: LatLng(trip.destinationLat!, trip.destinationLng!),
          ),
        ],
      ],
    );
  }
}

class _CompletedSection extends ConsumerWidget {
  const _CompletedSection({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SurfaceCard(
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 48),
              const SizedBox(height: 12),
              Text(context.tr('Viaje completado'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${context.tr('Pagaste')} ${Formatters.clp(trip.displayFare)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      )),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!trip.passengerRated && trip.driver != null)
          PrimaryButton(
            label: context.tr('Calificar a tu conductor'),
            icon: Icons.star_rounded,
            onPressed: () => showRateSheet(
              context,
              tripId: trip.id,
              personName: trip.driver!.fullName,
              personAvatar: trip.driver!.avatarUrl,
              roleLabel: context.tr('conductor'),
            ),
          )
        else
          InfoPill(
            label: context.tr('¡Gracias por tu calificación!'),
            icon: Icons.check_rounded,
            color: AppColors.success,
          ),
      ],
    );
  }
}

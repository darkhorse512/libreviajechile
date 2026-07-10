import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/contact.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/nav_app_picker.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../trips/rate_sheet.dart';
import '../trips/trip_controller.dart';
import '../trips/widgets/trip_widgets.dart';

class DriverTripsScreen extends ConsumerWidget {
  const DriverTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tripsAsync = ref.watch(driverTripsProvider(user.id));

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
              final active = trips.where((t) => t.isActive).toList();
              final history = trips
                  .where((t) =>
                      t.status == TripStatus.completed ||
                      t.status == TripStatus.cancelled)
                  .toList();
              if (trips.isEmpty) {
                return EmptyState(
                  icon: Icons.route_rounded,
                  title: context.tr('Aún no tienes viajes'),
                  message: context.tr(
                      'Acepta solicitudes desde la pestaña Solicitudes para comenzar.'),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
                children: [
                  if (active.isNotEmpty) ...[
                    _Label(context.tr('En curso')),
                    for (final t in active) ...[
                      _ActiveDriverTrip(trip: t),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                  ],
                  if (history.isNotEmpty) ...[
                    _Label(context.tr('Historial')),
                    for (final t in history) ...[
                      _HistoryTile(trip: t),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActiveDriverTrip extends ConsumerWidget {
  const _ActiveDriverTrip({required this.trip});
  final Trip trip;

  Future<void> _advance(BuildContext context, WidgetRef ref) async {
    final next = trip.status == TripStatus.accepted
        ? TripStatus.inProgress
        : TripStatus.completed;
    await ref.read(tripActionsProvider).updateStatus(trip.id, next);
    if (context.mounted) {
      AppFeedback.success(
        context,
        next == TripStatus.inProgress
            ? context.tr('Viaje iniciado')
            : context.tr('Viaje finalizado'),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passenger = trip.passenger;
    return SurfaceCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TripStatusPill(status: trip.status),
              const Spacer(),
              Text(Formatters.clp(trip.displayFare),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.price,
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              UserAvatar(
                  name: passenger?.fullName ?? context.tr('Pasajero'),
                  imageUrl: passenger?.avatarUrl,
                  size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Text(passenger?.fullName ?? context.tr('Pasajero'),
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              IconButton(
                tooltip: 'WhatsApp',
                onPressed: () => Contact.whatsapp(context, passenger?.phone,
                    message: context.tr(
                        'Hola! Soy tu conductor de Libre Viaje Chile.')),
                icon: const Icon(Icons.chat_rounded, color: AppColors.success),
              ),
              IconButton(
                tooltip: context.tr('Llamar'),
                onPressed: () => Contact.call(context, passenger?.phone),
                icon: const Icon(Icons.call_rounded, color: AppColors.accent),
              ),
            ],
          ),
          const Divider(height: 20),
          TripRoute(
            origin: trip.originAddress,
            destination: trip.destinationAddress,
            compact: true,
          ),
          const SizedBox(height: 16),
          if (trip.hasRoute) ...[
            NavigateButton(
              origin: LatLng(trip.originLat!, trip.originLng!),
              destination: LatLng(trip.destinationLat!, trip.destinationLng!),
              // Antes de iniciar: navega al punto de partida (recoger al
              // pasajero). En viaje: navega al destino.
              target: trip.status == TripStatus.accepted
                  ? LatLng(trip.originLat!, trip.originLng!)
                  : LatLng(trip.destinationLat!, trip.destinationLng!),
            ),
            const SizedBox(height: 10),
          ],
          PrimaryButton(
            label: trip.status == TripStatus.accepted
                ? context.tr('Iniciar viaje')
                : context.tr('Finalizar viaje'),
            icon: trip.status == TripStatus.accepted
                ? Icons.play_arrow_rounded
                : Icons.flag_rounded,
            gradient: false,
            onPressed: () => _advance(context, ref),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final completed = trip.status == TripStatus.completed;
    return SurfaceCard(
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
          const SizedBox(height: 12),
          TripRoute(
            origin: trip.originAddress,
            destination: trip.destinationAddress,
            compact: true,
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(trip.passenger?.fullName ?? context.tr('Pasajero'),
                  style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(Formatters.clp(trip.displayFare),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.price,
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
          if (completed && !trip.driverRated && trip.passenger != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => showRateSheet(
                context,
                tripId: trip.id,
                personName: trip.passenger!.fullName,
                personAvatar: trip.passenger!.avatarUrl,
                roleLabel: context.tr('pasajero'),
              ),
              icon: const Icon(Icons.star_rounded, size: 18, color: AppColors.star),
              label: Text(context.tr('Calificar pasajero')),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.palette.textMuted,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              )),
    );
  }
}

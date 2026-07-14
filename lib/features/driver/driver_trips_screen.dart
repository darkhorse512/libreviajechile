import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/services/geo_service.dart';
import '../../core/services/location_service.dart';
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

class _ActiveDriverTrip extends ConsumerStatefulWidget {
  const _ActiveDriverTrip({required this.trip});
  final Trip trip;

  @override
  ConsumerState<_ActiveDriverTrip> createState() => _ActiveDriverTripState();
}

class _ActiveDriverTripState extends ConsumerState<_ActiveDriverTrip> {
  Timer? _locTimer;
  GeoRoute? _legA; // conductor → punto de partida (recoger)
  GeoRoute? _legB; // punto de partida → destino

  Trip get trip => widget.trip;
  bool get _tracking =>
      trip.status == TripStatus.accepted || trip.status == TripStatus.inProgress;

  @override
  void initState() {
    super.initState();
    _computeLegB();
    _pushLocation();
    _locTimer =
        Timer.periodic(const Duration(seconds: 8), (_) => _pushLocation());
  }

  @override
  void dispose() {
    _locTimer?.cancel();
    super.dispose();
  }

  Future<void> _computeLegB() async {
    if (!trip.hasRoute) return;
    final r = await ref.read(geoServiceProvider).route(
          LatLng(trip.originLat!, trip.originLng!),
          LatLng(trip.destinationLat!, trip.destinationLng!),
        );
    if (mounted) setState(() => _legB = r);
  }

  Future<void> _pushLocation() async {
    if (!_tracking) return;
    final pos = await LocationService.current();
    if (pos == null || !mounted) return;
    // Comparte ubicación en vivo con el pasajero.
    ref
        .read(tripActionsProvider)
        .updateDriverLocation(trip.id, pos.latitude, pos.longitude);
    // Distancia/tiempo hasta el punto de partida (tramo A).
    if (trip.originLat != null) {
      final r = await ref.read(geoServiceProvider).route(
            LatLng(pos.latitude, pos.longitude),
            LatLng(trip.originLat!, trip.originLng!),
          );
      if (mounted) setState(() => _legA = r);
    }
  }

  Future<void> _advance() async {
    final next = trip.status == TripStatus.accepted
        ? TripStatus.inProgress
        : TripStatus.completed;
    await ref.read(tripActionsProvider).updateStatus(trip.id, next);
    if (mounted) {
      AppFeedback.success(
        context,
        next == TripStatus.inProgress
            ? context.tr('Viaje iniciado')
            : context.tr('Viaje finalizado'),
      );
    }
  }

  Future<void> _onWay() async {
    await ref.read(tripActionsProvider).setOnWay(trip.id);
    if (mounted) AppFeedback.info(context, context.tr('El pasajero fue avisado.'));
  }

  Future<void> _arrived() async {
    await ref.read(tripActionsProvider).setArrived(trip.id);
    if (mounted) AppFeedback.info(context, context.tr('El pasajero fue avisado.'));
  }

  @override
  Widget build(BuildContext context) {
    final passenger = trip.passenger;
    final accepted = trip.status == TripStatus.accepted;
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
                    message: context.tr('Hola! Soy tu conductor de EligeDrive.')),
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
          const SizedBox(height: 12),
          // Distancias tramo A (recoger) y tramo B (al destino).
          Row(
            children: [
              Expanded(
                child: _LegChip(
                  label: context.tr('A · Recoger'),
                  route: _legA,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LegChip(
                  label: context.tr('B · Destino'),
                  route: _legB,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (trip.hasRoute) ...[
            NavigateButton(
              origin: LatLng(trip.originLat!, trip.originLng!),
              destination: LatLng(trip.destinationLat!, trip.destinationLng!),
              target: accepted
                  ? LatLng(trip.originLat!, trip.originLng!)
                  : LatLng(trip.destinationLat!, trip.destinationLng!),
            ),
            const SizedBox(height: 10),
          ],
          // Máquina de estados: Voy en camino → Llegué → Iniciar → Finalizar.
          if (accepted && !trip.driverOnWay)
            PrimaryButton(
              label: context.tr('Voy en camino'),
              icon: Icons.directions_car_rounded,
              onPressed: _onWay,
            )
          else if (accepted && trip.driverArrivedAt == null)
            PrimaryButton(
              label: context.tr('Llegué'),
              icon: Icons.where_to_vote_rounded,
              onPressed: _arrived,
            )
          else if (accepted) ...[
            _WaitCountdown(arrivedAt: trip.driverArrivedAt!),
            const SizedBox(height: 10),
            PrimaryButton(
              label: context.tr('Iniciar viaje'),
              icon: Icons.play_arrow_rounded,
              gradient: false,
              onPressed: _advance,
            ),
          ] else
            PrimaryButton(
              label: context.tr('Finalizar viaje'),
              icon: Icons.flag_rounded,
              gradient: false,
              onPressed: _advance,
            ),
        ],
      ),
    );
  }
}

/// Muestra la distancia/tiempo de un tramo (A o B).
class _LegChip extends StatelessWidget {
  const _LegChip({required this.label, required this.route, required this.color});
  final String label;
  final GeoRoute? route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 2),
          Text(
            route == null
                ? '—'
                : '${route!.distanceLabel} · ${route!.durationLabel}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Cuenta regresiva de espera (5 min) tras "Llegué".
class _WaitCountdown extends StatefulWidget {
  const _WaitCountdown({required this.arrivedAt});
  final DateTime arrivedAt;

  @override
  State<_WaitCountdown> createState() => _WaitCountdownState();
}

class _WaitCountdownState extends State<_WaitCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ends = widget.arrivedAt
        .add(const Duration(minutes: AppConfig.tripExpiryMinutes));
    final remaining = ends.difference(DateTime.now());
    final done = remaining <= Duration.zero;
    final mm = remaining.inMinutes.remainder(60).clamp(0, 59).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).clamp(0, 59).toString().padLeft(2, '0');
    final color = done ? AppColors.danger : AppColors.price;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              done
                  ? context.tr('Tiempo de espera agotado. Puedes iniciar o cancelar.')
                  : context.trp('Esperando al pasajero · {time}',
                      {'time': '$mm:$ss'}),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.palette.textSecondary),
            ),
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

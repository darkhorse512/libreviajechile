import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/chilean_cities.dart';
import '../../core/i18n/i18n.dart';
import '../../core/services/sound_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/offer.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets/app_notification.dart';

/// Escucha eventos del conductor y dispara notificaciones con sonido:
///  - Nueva solicitud cercana  → request.aac
///  - Su oferta fue aceptada   → accept.aac
///
/// Se monta en el shell del conductor (siempre presente mientras usa la app).
class DriverNotifications extends ConsumerWidget {
  const DriverNotifications({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user != null && user.isOnline) {
      final city = cityByName(user.city);
      final area = DriverArea(city: user.city, lat: city.lat, lng: city.lng);
      ref.listen<AsyncValue<List<Trip>>>(openTripsProvider(area), (prev, next) {
        final prevIds = prev?.valueOrNull?.map((t) => t.id).toSet();
        if (prevIds == null) return; // primera carga: sin notificar
        final fresh = (next.valueOrNull ?? const <Trip>[])
            .where((t) => !prevIds.contains(t.id))
            .toList();
        if (fresh.isEmpty) return;
        final t = fresh.first;
        SoundService.request();
        AppNotify.show(
          context,
          icon: Icons.notifications_active_rounded,
          accent: AppColors.brand,
          title: context.tr('Nueva solicitud de viaje'),
          message: '${t.originAddress} → ${t.destinationAddress}',
        );
      });
    }

    if (user != null) {
      ref.listen<AsyncValue<List<Offer>>>(driverOffersProvider(user.id),
          (prev, next) {
        final prevAccepted = prev?.valueOrNull
            ?.where((o) => o.status == OfferStatus.accepted)
            .map((o) => o.id)
            .toSet();
        if (prevAccepted == null) return; // primera carga
        final justAccepted = (next.valueOrNull ?? const <Offer>[])
            .where((o) =>
                o.status == OfferStatus.accepted && !prevAccepted.contains(o.id))
            .toList();
        if (justAccepted.isEmpty) return;
        SoundService.accept();
        AppNotify.show(
          context,
          icon: Icons.verified_rounded,
          accent: AppColors.success,
          title: context.tr('¡Tu oferta fue aceptada!'),
          message: context.tr('El pasajero te eligió. ¡Prepárate para el viaje!'),
        );
      });
    }

    return child;
  }
}

/// Escucha eventos del pasajero y notifica con sonido cuando recibe una nueva
/// oferta de un conductor (request.aac). Se monta en el shell del pasajero.
class PassengerNotifications extends ConsumerWidget {
  const PassengerNotifications({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final trips = user == null
        ? const <Trip>[]
        : (ref.watch(passengerTripsProvider(user.id)).valueOrNull ??
            const <Trip>[]);

    // Cambios de estado del conductor (va en camino / llegó).
    if (user != null) {
      ref.listen<AsyncValue<List<Trip>>>(passengerTripsProvider(user.id),
          (prev, next) {
        final before = {
          for (final t in (prev?.valueOrNull ?? const <Trip>[])) t.id: t
        };
        if (prev?.valueOrNull == null) return; // primera carga
        for (final t in (next.valueOrNull ?? const <Trip>[])) {
          final was = before[t.id];
          if (was == null) continue;
          if (!was.driverOnWay &&
              t.driverOnWay &&
              t.driverArrivedAt == null) {
            SoundService.request();
            AppNotify.show(
              context,
              icon: Icons.directions_car_rounded,
              accent: AppColors.brand,
              title: context.tr('Tu conductor va en camino'),
              message: context.tr('Está yendo a tu punto de partida.'),
            );
          }
          if (was.driverArrivedAt == null && t.driverArrivedAt != null) {
            SoundService.request();
            AppNotify.show(
              context,
              icon: Icons.where_to_vote_rounded,
              accent: AppColors.success,
              title: context.tr('¡Tu conductor llegó!'),
              message: context.tr('Te está esperando en el punto de partida.'),
            );
          }
        }
      });
    }

    Trip? openTrip;
    for (final t in trips) {
      if (t.isOpen) {
        openTrip = t;
        break;
      }
    }

    if (openTrip != null) {
      ref.listen<AsyncValue<List<Offer>>>(tripOffersProvider(openTrip.id),
          (prev, next) {
        final prevIds = prev?.valueOrNull?.map((o) => o.id).toSet();
        if (prevIds == null) return; // primera carga
        final fresh = (next.valueOrNull ?? const <Offer>[])
            .where((o) =>
                !prevIds.contains(o.id) && o.status == OfferStatus.pending)
            .toList();
        if (fresh.isEmpty) return;
        final o = fresh.first;
        final who = o.driver?.fullName;
        SoundService.request();
        AppNotify.show(
          context,
          icon: Icons.local_offer_rounded,
          accent: AppColors.price,
          title: context.tr('Nueva oferta recibida'),
          message: who != null
              ? '$who · ${Formatters.clp(o.amount)}'
              : Formatters.clp(o.amount),
        );
      });
    }

    return child;
  }
}

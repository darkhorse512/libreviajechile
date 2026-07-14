import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';
import '../../data/models/offer.dart';
import '../../data/models/trip.dart';
import '../../data/providers.dart';

/// Acciones sobre viajes/ofertas. Se obtiene con `ref.read(tripActionsProvider)`.
class TripActions {
  TripActions(this._ref);
  final Ref _ref;

  Future<Trip> createTrip({
    required String city,
    required String originAddress,
    required String destinationAddress,
    required int offeredFare,
    double? originLat,
    double? originLng,
    double? destinationLat,
    double? destinationLng,
    String? note,
    int passengers = 1,
  }) {
    final user = _ref.read(currentUserProvider);
    return _ref.read(tripRepositoryProvider).createTrip(
          passengerId: user!.id,
          city: city,
          originAddress: originAddress,
          destinationAddress: destinationAddress,
          offeredFare: offeredFare,
          originLat: originLat,
          originLng: originLng,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          note: note,
          passengers: passengers,
        );
  }

  Future<Offer> sendOffer({
    required String tripId,
    required int amount,
    required OfferKind kind,
    String? message,
    int? etaMinutes,
  }) {
    final user = _ref.read(currentUserProvider);
    return _ref.read(tripRepositoryProvider).sendOffer(
          tripId: tripId,
          driverId: user!.id,
          amount: amount,
          kind: kind,
          message: message,
          etaMinutes: etaMinutes,
        );
  }

  Future<void> acceptOffer(String tripId, String offerId) =>
      _ref.read(tripRepositoryProvider).acceptOffer(tripId: tripId, offerId: offerId);

  Future<void> withdrawOffer(String offerId) =>
      _ref.read(tripRepositoryProvider).withdrawOffer(offerId);

  Future<void> updateStatus(String tripId, TripStatus status) =>
      _ref.read(tripRepositoryProvider).updateTripStatus(tripId, status);

  Future<void> setOnWay(String tripId) =>
      _ref.read(tripRepositoryProvider).setDriverOnWay(tripId);

  Future<void> setArrived(String tripId) =>
      _ref.read(tripRepositoryProvider).setDriverArrived(tripId);

  Future<void> updateDriverLocation(String tripId, double lat, double lng) =>
      _ref.read(tripRepositoryProvider).updateDriverLocation(tripId, lat, lng);

  Future<void> cancelTrip(String tripId) =>
      _ref.read(tripRepositoryProvider).cancelTrip(tripId);

  Future<void> rate({
    required String tripId,
    required int stars,
    String? comment,
  }) {
    final user = _ref.read(currentUserProvider);
    return _ref.read(tripRepositoryProvider).rate(
          tripId: tripId,
          raterId: user!.id,
          stars: stars,
          comment: comment,
        );
  }
}

final tripActionsProvider = Provider<TripActions>((ref) => TripActions(ref));

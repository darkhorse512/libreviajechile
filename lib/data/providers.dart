import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/env.dart';
import 'models/app_user.dart';
import 'models/offer.dart';
import 'models/trip.dart';
import 'repositories/demo_repositories.dart';
import 'repositories/repositories.dart';
import 'repositories/supabase_repositories.dart';

/// `true` cuando NO hay credenciales Supabase válidas → se usa el backend demo.
final isDemoModeProvider = Provider<bool>((_) => !Env.isConfigured);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(isDemoModeProvider)) return DemoAuthRepository();
  return SupabaseAuthRepository(Supabase.instance.client);
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  if (ref.watch(isDemoModeProvider)) return DemoTripRepository();
  return SupabaseTripRepository(Supabase.instance.client);
});

/// Usuario autenticado actual (o null). Fuente de verdad para el router.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authState();
});

/// Usuario actual. Se alimenta del stream de auth, pero también puede
/// actualizarse localmente (p. ej. al editar el perfil) para reflejar los
/// cambios al instante sin reiniciar la sesión.
class CurrentUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => ref.watch(authStateProvider).valueOrNull;

  void update(AppUser user) => state = user;
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AppUser?>(CurrentUserNotifier.new);

// ----- Streams de dominio parametrizados -----

final openTripsProvider =
    StreamProvider.family<List<Trip>, DriverArea>((ref, area) {
  return ref.watch(tripRepositoryProvider).watchOpenTrips(area);
});

final passengerTripsProvider =
    StreamProvider.family<List<Trip>, String>((ref, passengerId) {
  return ref.watch(tripRepositoryProvider).watchPassengerTrips(passengerId);
});

final driverTripsProvider =
    StreamProvider.family<List<Trip>, String>((ref, driverId) {
  return ref.watch(tripRepositoryProvider).watchDriverTrips(driverId);
});

final tripProvider = StreamProvider.family<Trip?, String>((ref, tripId) {
  return ref.watch(tripRepositoryProvider).watchTrip(tripId);
});

final tripOffersProvider =
    StreamProvider.family<List<Offer>, String>((ref, tripId) {
  return ref.watch(tripRepositoryProvider).watchOffers(tripId);
});

/// Ofertas hechas por un conductor (para marcar viajes ya ofertados).
final driverOffersProvider =
    StreamProvider.family<List<Offer>, String>((ref, driverId) {
  return ref.watch(tripRepositoryProvider).watchDriverOffers(driverId);
});

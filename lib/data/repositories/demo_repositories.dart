import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/offer.dart';
import '../models/rating.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';
import 'demo_backend.dart';
import 'repositories.dart';

class DemoAuthRepository implements AuthRepository {
  final _db = DemoBackend.instance;
  int _seq = 0;
  String _id() => 'u-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  @override
  Stream<AppUser?> authState() async* {
    // Emite el estado inicial (null) para que el router no quede cargando.
    yield _db.currentUser;
    yield* _db.authStream;
  }

  @override
  AppUser? get currentUser => _db.currentUser;

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      _db.signIn(email, password);

  @override
  Future<RegisterResult> registerPassenger({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? city,
  }) async {
    final user = AppUser(
      id: _id(),
      role: UserRole.passenger,
      fullName: fullName,
      email: email,
      phone: phone,
      city: city,
      createdAt: DateTime.now(),
    );
    await _db.register(user, password);
    // En modo demostración el acceso es inmediato (sin código).
    return RegisterResult(needsVerification: false, email: email);
  }

  @override
  Future<RegisterResult> registerDriver({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String password,
    required Vehicle vehicle,
  }) async {
    final user = AppUser(
      id: _id(),
      role: UserRole.driver,
      fullName: fullName,
      email: email,
      phone: phone,
      city: city,
      vehicle: vehicle,
      isVerified: false,
      isOnline: false,
      createdAt: DateTime.now(),
    );
    await _db.register(user, password);
    return RegisterResult(needsVerification: false, email: email);
  }

  @override
  Future<AppUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    // En demo no hay verificación real; devolvemos el usuario actual.
    return _db.currentUser!;
  }

  @override
  Future<void> resendOtp({required String email}) async {}

  @override
  Future<void> resetPassword({required String email}) async {}

  @override
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> signOut() => _db.signOut();

  @override
  Future<AppUser> updateProfile(AppUser user) => _db.updateUser(user);

  @override
  Future<void> setOnline(String driverId, bool online) =>
      _db.setOnline(driverId, online);
}

class DemoTripRepository implements TripRepository {
  final _db = DemoBackend.instance;
  int _seq = 0;
  String _id(String p) => '$p-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  @override
  Stream<List<Trip>> watchOpenTrips(DriverArea area) => _db.openTrips(area);

  @override
  Stream<List<Trip>> watchPassengerTrips(String passengerId) =>
      _db.passengerTrips(passengerId);

  @override
  Stream<List<Trip>> watchDriverTrips(String driverId) =>
      _db.driverTrips(driverId);

  @override
  Stream<Trip?> watchTrip(String tripId) => _db.trip(tripId);

  @override
  Stream<List<Offer>> watchOffers(String tripId) => _db.tripOffers(tripId);

  @override
  Stream<List<Offer>> watchDriverOffers(String driverId) =>
      _db.driverOffers(driverId);

  @override
  Future<void> withdrawOffer(String offerId) => _db.withdrawOffer(offerId);

  @override
  Future<Trip> createTrip({
    required String passengerId,
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
    final trip = Trip(
      id: _id('trip'),
      passengerId: passengerId,
      city: city,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      offeredFare: offeredFare,
      status: TripStatus.requested,
      createdAt: DateTime.now(),
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      note: note,
      passengers: passengers,
    );
    return _db.createTrip(trip);
  }

  @override
  Future<Offer> sendOffer({
    required String tripId,
    required String driverId,
    required int amount,
    required OfferKind kind,
    String? message,
    int? etaMinutes,
  }) {
    final offer = Offer(
      id: _id('offer'),
      tripId: tripId,
      driverId: driverId,
      amount: amount,
      kind: kind,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
      message: message,
      etaMinutes: etaMinutes,
    );
    return _db.sendOffer(offer);
  }

  @override
  Future<void> acceptOffer({required String tripId, required String offerId}) =>
      _db.acceptOffer(tripId, offerId);

  @override
  Future<void> updateTripStatus(String tripId, TripStatus status) =>
      _db.updateStatus(tripId, status);

  @override
  Future<void> setDriverOnWay(String tripId) => _db.setDriverOnWay(tripId);

  @override
  Future<void> setDriverArrived(String tripId) => _db.setDriverArrived(tripId);

  @override
  Future<void> updateDriverLocation(String tripId, double lat, double lng) =>
      _db.updateDriverLocation(tripId, lat, lng);

  @override
  Future<void> cancelTrip(String tripId) => _db.cancelTrip(tripId);

  @override
  Future<void> rate({
    required String tripId,
    required String raterId,
    required int stars,
    String? comment,
  }) =>
      _db.rate(tripId, raterId, stars);

  @override
  Future<List<Rating>> userRatings(String userId) async => const [];
}

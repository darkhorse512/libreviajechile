import 'dart:async';
import 'dart:math';

import '../../core/constants/chilean_cities.dart';
import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/offer.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';
import 'repositories.dart';

/// Backend en memoria para ejecutar la app sin configurar Supabase.
/// Simula tiempo real (streams) e incluso genera ofertas de conductores
/// automáticamente cuando un pasajero publica un viaje, para poder demostrar
/// el flujo completo de ofertas/contraofertas.
class DemoBackend {
  DemoBackend._() {
    _seed();
  }
  static final DemoBackend instance = DemoBackend._();

  final _rnd = Random();
  int _seq = 0;
  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  final Map<String, AppUser> users = {};
  final Map<String, String> _passwords = {}; // email -> password
  final Map<String, String> _emailToId = {};
  final List<Trip> trips = [];
  final List<Offer> offers = [];

  AppUser? currentUser;

  final _authCtrl = StreamController<AppUser?>.broadcast();
  final _tripsCtrl = StreamController<void>.broadcast();
  final _offersCtrl = StreamController<void>.broadcast();

  Stream<AppUser?> get authStream => _authCtrl.stream;

  void _pingTrips() => _tripsCtrl.add(null);
  void _pingOffers() => _offersCtrl.add(null);

  // ---------------------------------------------------------------------------
  // Semilla de datos de demostración.
  // ---------------------------------------------------------------------------
  void _seed() {
    final drivers = [
      _driver('María González', 'Toyota', 'Yaris', 2021, 'Blanco', 'JKLM45',
          4.9, 320, 'Santiago'),
      _driver('Cristóbal Rojas', 'Hyundai', 'Accent', 2020, 'Gris', 'BFGT12',
          4.8, 210, 'Santiago'),
      _driver('Valentina Muñoz', 'Kia', 'Rio', 2022, 'Rojo', 'KDLR83', 4.7,
          145, 'Santiago'),
      _driver('Ignacio Fuentes', 'Nissan', 'Versa', 2019, 'Negro', 'HGTR56',
          4.6, 98, 'Santiago'),
    ];
    for (final d in drivers) {
      users[d.id] = d;
    }

    // Un par de viajes abiertos para que un conductor vea el feed de inmediato.
    final demoPassenger = AppUser(
      id: _id('demo-pax'),
      role: UserRole.passenger,
      fullName: 'Camila Torres',
      email: 'camila@demo.cl',
      phone: '+56 9 1234 5678',
      city: 'Santiago',
      ratingAvg: 4.9,
      ratingCount: 41,
      tripsCount: 52,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    );
    users[demoPassenger.id] = demoPassenger;

    trips.addAll([
      Trip(
        id: _id('trip'),
        passengerId: demoPassenger.id,
        city: 'Santiago',
        originAddress: 'Metro Los Héroes, Santiago Centro',
        originLat: -33.4442,
        originLng: -70.6558,
        destinationAddress: 'Costanera Center, Providencia',
        destinationLat: -33.4176,
        destinationLng: -70.6069,
        offeredFare: 4500,
        status: TripStatus.requested,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        note: 'Llevo una maleta pequeña.',
        passenger: demoPassenger,
      ),
      Trip(
        id: _id('trip'),
        passengerId: demoPassenger.id,
        city: 'Santiago',
        originAddress: 'Plaza Ñuñoa',
        originLat: -33.4560,
        originLng: -70.5980,
        destinationAddress: 'Aeropuerto SCL',
        destinationLat: -33.3898,
        destinationLng: -70.7944,
        offeredFare: 12000,
        status: TripStatus.requested,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        passenger: demoPassenger,
      ),
    ]);
  }

  AppUser _driver(String name, String make, String model, int year,
      String color, String plate, double rating, int trips, String city) {
    return AppUser(
      id: _id('drv'),
      role: UserRole.driver,
      fullName: name,
      email: '${name.split(' ').first.toLowerCase()}@demo.cl',
      phone: '+56 9 ${1000 + _rnd.nextInt(8999)} ${1000 + _rnd.nextInt(8999)}',
      city: city,
      ratingAvg: rating,
      ratingCount: trips,
      tripsCount: trips,
      isVerified: true,
      isOnline: true,
      createdAt: DateTime.now().subtract(Duration(days: 60 + _rnd.nextInt(600))),
      vehicle: Vehicle(
          make: make, model: model, year: year, color: color, plate: plate),
    );
  }

  // ---------------------------------------------------------------------------
  // Auth.
  // ---------------------------------------------------------------------------
  Future<AppUser> signIn(String email, String password) async {
    await _delay();
    final id = _emailToId[email.toLowerCase()];
    if (id == null || _passwords[email.toLowerCase()] != password) {
      throw AuthException('Correo o contraseña incorrectos');
    }
    currentUser = users[id];
    _authCtrl.add(currentUser);
    return currentUser!;
  }

  Future<AppUser> register(AppUser user, String password) async {
    await _delay();
    final email = user.email.toLowerCase();
    if (_emailToId.containsKey(email)) {
      throw AuthException('Ya existe una cuenta con este correo');
    }
    users[user.id] = user;
    _emailToId[email] = user.id;
    _passwords[email] = password;
    currentUser = user;
    _authCtrl.add(currentUser);
    return user;
  }

  Future<void> signOut() async {
    currentUser = null;
    _authCtrl.add(null);
  }

  Future<AppUser> updateUser(AppUser user) async {
    users[user.id] = user;
    if (currentUser?.id == user.id) {
      currentUser = user;
      _authCtrl.add(user);
    }
    return user;
  }

  Future<void> setOnline(String driverId, bool online) async {
    final u = users[driverId];
    if (u != null) await updateUser(u.copyWith(isOnline: online));
  }

  // ---------------------------------------------------------------------------
  // Viajes / ofertas.
  // ---------------------------------------------------------------------------
  Trip _hydrate(Trip t) {
    return t.copyWith(
      passenger: users[t.passengerId],
      driver: t.driverId != null ? users[t.driverId] : null,
      offersCount: offers.where((o) => o.tripId == t.id).length,
    );
  }

  Stream<List<Trip>> openTrips(DriverArea area) {
    List<Trip> compute() => trips
        .where((t) =>
            t.status == TripStatus.requested &&
            tripInDriverArea(
              tripLat: t.originLat,
              tripLng: t.originLng,
              tripCity: t.city,
              refLat: area.lat,
              refLng: area.lng,
              refCity: area.city,
            ))
        .map(_hydrate)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _tripsCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Stream<List<Trip>> passengerTrips(String passengerId) {
    List<Trip> compute() => trips
        .where((t) => t.passengerId == passengerId)
        .map(_hydrate)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _tripsCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Stream<List<Trip>> driverTrips(String driverId) {
    List<Trip> compute() => trips
        .where((t) => t.driverId == driverId)
        .map(_hydrate)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _tripsCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Stream<Trip?> trip(String tripId) {
    Trip? compute() {
      final match = trips.where((t) => t.id == tripId);
      return match.isEmpty ? null : _hydrate(match.first);
    }

    return _tripsCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Stream<List<Offer>> tripOffers(String tripId) {
    List<Offer> compute() => offers
        .where((o) =>
            o.tripId == tripId &&
            (o.status == OfferStatus.pending ||
                o.status == OfferStatus.accepted))
        .map((o) => o.copyWith(driver: users[o.driverId]))
        .toList()
      ..sort((a, b) => a.amount.compareTo(b.amount));
    return _offersCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Stream<List<Offer>> driverOffers(String driverId) {
    List<Offer> compute() => offers
        .where((o) => o.driverId == driverId)
        .map((o) => o.copyWith(driver: users[o.driverId]))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _offersCtrl.stream.map((_) => compute()).startWithValue(compute());
  }

  Future<void> withdrawOffer(String offerId) async {
    final i = offers.indexWhere((o) => o.id == offerId);
    if (i < 0) return;
    offers[i] = offers[i].copyWith(status: OfferStatus.withdrawn);
    _pingOffers();
    _pingTrips();
  }

  Future<Trip> createTrip(Trip t) async {
    await _delay();
    trips.add(t);
    _pingTrips();
    _simulateDriverOffers(t); // da vida a la demo
    return t;
  }

  Future<Offer> sendOffer(Offer o) async {
    await _delay(short: true);
    offers.add(o);
    _pingOffers();
    _pingTrips();
    return o;
  }

  Future<void> acceptOffer(String tripId, String offerId) async {
    await _delay();
    final ti = trips.indexWhere((t) => t.id == tripId);
    final oi = offers.indexWhere((o) => o.id == offerId);
    if (ti < 0 || oi < 0) return;
    final offer = offers[oi];
    offers[oi] = offer.copyWith(status: OfferStatus.accepted);
    // Rechaza el resto.
    for (var i = 0; i < offers.length; i++) {
      if (offers[i].tripId == tripId && offers[i].id != offerId) {
        offers[i] = offers[i].copyWith(status: OfferStatus.rejected);
      }
    }
    trips[ti] = trips[ti].copyWith(
      status: TripStatus.accepted,
      driverId: offer.driverId,
      finalFare: offer.amount,
      acceptedOfferId: offerId,
    );
    _pingTrips();
    _pingOffers();
  }

  Future<void> updateStatus(String tripId, TripStatus status) async {
    final i = trips.indexWhere((t) => t.id == tripId);
    if (i < 0) return;
    trips[i] = trips[i].copyWith(status: status);
    _pingTrips();
  }

  Future<void> setDriverOnWay(String tripId) async {
    final i = trips.indexWhere((t) => t.id == tripId);
    if (i < 0) return;
    trips[i] = trips[i].copyWith(driverOnWay: true);
    _pingTrips();
  }

  Future<void> setDriverArrived(String tripId) async {
    final i = trips.indexWhere((t) => t.id == tripId);
    if (i < 0) return;
    trips[i] = trips[i].copyWith(driverArrivedAt: DateTime.now());
    _pingTrips();
  }

  Future<void> updateDriverLocation(String tripId, double lat, double lng) async {
    final i = trips.indexWhere((t) => t.id == tripId);
    if (i < 0) return;
    trips[i] = trips[i].copyWith(driverLat: lat, driverLng: lng);
    _pingTrips();
  }

  Future<void> cancelTrip(String tripId) => updateStatus(tripId, TripStatus.cancelled);

  Future<void> rate(String tripId, String raterId, int stars) async {
    final i = trips.indexWhere((t) => t.id == tripId);
    if (i < 0) return;
    final trip = trips[i];
    final isPassenger = trip.passengerId == raterId;
    // Actualiza el agregado del calificado.
    final rateeId = isPassenger ? trip.driverId : trip.passengerId;
    if (rateeId != null) {
      final u = users[rateeId];
      if (u != null) {
        final newCount = u.ratingCount + 1;
        final newAvg =
            ((u.ratingAvg * u.ratingCount) + stars) / newCount;
        users[rateeId] = u.copyWith(ratingAvg: newAvg, ratingCount: newCount);
      }
    }
    trips[i] = trip.copyWith(
      passengerRated: isPassenger ? true : trip.passengerRated,
      driverRated: isPassenger ? trip.driverRated : true,
    );
    _pingTrips();
  }

  /// Simula que 2-3 conductores cercanos responden con ofertas y contraofertas.
  void _simulateDriverOffers(Trip t) {
    final drivers =
        users.values.where((u) => u.isDriver && u.city == t.city).toList();
    if (drivers.isEmpty) return;
    drivers.shuffle(_rnd);
    final count = min(3, drivers.length);
    for (var i = 0; i < count; i++) {
      final driver = drivers[i];
      final counter = _rnd.nextBool();
      final delay = Duration(seconds: 2 + i * 3 + _rnd.nextInt(3));
      Future.delayed(delay, () {
        // Evita ofertar si el viaje ya no está abierto.
        final current = trips.where((x) => x.id == t.id);
        if (current.isEmpty || current.first.status != TripStatus.requested) {
          return;
        }
        final bump = 500 * (1 + _rnd.nextInt(3));
        offers.add(Offer(
          id: _id('offer'),
          tripId: t.id,
          driverId: driver.id,
          amount: counter ? t.offeredFare + bump : t.offeredFare,
          kind: counter ? OfferKind.counter : OfferKind.accept,
          status: OfferStatus.pending,
          createdAt: DateTime.now(),
          etaMinutes: 3 + _rnd.nextInt(9),
          message: counter
              ? 'Con el tráfico actual te dejo en $bump más. ¿Te parece?'
              : 'Voy en camino, llego enseguida.',
        ));
        _pingOffers();
        _pingTrips();
      });
    }
  }

  Future<void> _delay({bool short = false}) =>
      Future.delayed(Duration(milliseconds: short ? 250 : 500));
}

/// Utilidad: emite un valor inicial inmediato antes de los eventos del stream.
extension _StartWith<T> on Stream<T> {
  Stream<T> startWithValue(T initial) async* {
    yield initial;
    yield* this;
  }
}

import 'dart:async';

// Ocultamos la AuthException de gotrue para usar la nuestra (repositories.dart).
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../core/config/app_config.dart';
import '../../core/utils/geo_utils.dart';
import '../models/app_user.dart';
import '../models/driver_location.dart';
import '../models/enums.dart';
import '../models/offer.dart';
import '../models/payment_method.dart';
import '../models/rating.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';
import 'repositories.dart';

/// Implementación real contra Supabase (auth + Postgres + realtime).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  AppUser? get currentUser => _cached;
  AppUser? _cached;

  @override
  Stream<AppUser?> authState() async* {
    // Emite el estado inicial.
    yield await _resolveUser(_auth.currentUser);
    await for (final data in _auth.onAuthStateChange) {
      yield await _resolveUser(data.session?.user);
    }
  }

  Future<AppUser?> _resolveUser(User? authUser) async {
    if (authUser == null) {
      _cached = null;
      return null;
    }
    try {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();
      if (profile == null) {
        _cached = null;
        return null;
      }
      Vehicle? vehicle;
      Map<String, dynamic>? driver;
      if (UserRole.fromString(profile['role'] as String?) == UserRole.driver) {
        driver = await _client
            .from('driver_details')
            .select()
            .eq('id', authUser.id)
            .maybeSingle();
        if (driver != null) vehicle = Vehicle.fromMap(driver);
      }
      final merged = {
        ...profile,
        // El estado de verificación (KYC) del conductor vive en driver_details;
        // el del pasajero, en profiles. Se normaliza a 'status'/'rejection_reason'
        // para que AppUser.fromMap lo lea igual en ambos casos.
        if (driver != null) ...{
          'is_online': driver['is_online'],
          'is_verified': driver['is_verified'],
          'status': driver['status'],
          'rejection_reason': driver['rejection_reason'],
        } else ...{
          'status': profile['verification_status'],
          'rejection_reason': profile['verification_rejection_reason'],
        },
        'email': authUser.email,
      };
      _cached = AppUser.fromMap(merged, vehicle: vehicle);
      return _cached;
    } catch (_) {
      return _cached;
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signInWithPassword(email: email, password: password);
      final user = await _resolveUser(res.user);
      if (user == null) throw AuthException('No se pudo cargar el perfil');
      return user;
    } on AuthApiException catch (e) {
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<RegisterResult> registerPassenger({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? city,
  }) {
    return _register(
      role: UserRole.passenger,
      fullName: fullName,
      email: email,
      phone: phone,
      city: city,
      password: password,
    );
  }

  @override
  Future<RegisterResult> registerDriver({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String password,
    required Vehicle vehicle,
  }) {
    return _register(
      role: UserRole.driver,
      fullName: fullName,
      email: email,
      phone: phone,
      city: city,
      password: password,
      vehicle: vehicle,
    );
  }

  Future<RegisterResult> _register({
    required UserRole role,
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? city,
    Vehicle? vehicle,
  }) async {
    try {
      // Todos los datos viajan como metadata: el trigger handle_new_user crea
      // el perfil (y el vehículo si es conductor) al registrarse el usuario,
      // sin necesidad de sesión. Tras verificar el código de 6 dígitos, el
      // usuario ya queda con su perfil completo.
      final data = <String, dynamic>{
        'full_name': fullName,
        'role': role.name,
        'phone': phone,
        'city': city,
      };
      if (role == UserRole.driver && vehicle != null) {
        data.addAll({
          'make': vehicle.make,
          'model': vehicle.model,
          'year': vehicle.year,
          'color': vehicle.color,
          'plate': vehicle.plate.toUpperCase(),
          'seats': vehicle.seats,
        });
      }

      final res = await _auth.signUp(email: email, password: password, data: data);
      if (res.user == null) {
        throw AuthException('No se pudo crear la cuenta');
      }

      // Si Supabase entrega sesión inmediata (confirmación desactivada), no se
      // requiere verificación por código.
      return RegisterResult(needsVerification: res.session == null, email: email);
    } on AuthApiException catch (e) {
      throw AuthException(_translate(e.message));
    } on PostgrestException catch (e) {
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<AppUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final res = await _auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: token.trim(),
      );
      final user = await _resolveUser(res.user ?? _auth.currentUser);
      if (user == null) throw AuthException('No se pudo cargar el perfil');
      return user;
    } on AuthApiException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('expired')) throw AuthException('El código expiró. Solicita uno nuevo.');
      if (m.contains('invalid') || m.contains('token')) {
        throw AuthException('Código incorrecto. Revísalo e inténtalo de nuevo.');
      }
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email);
    } on AuthApiException catch (e) {
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());
    } on AuthApiException catch (e) {
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim(),
        token: token.trim(),
      );
    } on AuthApiException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('expired')) {
        throw AuthException('El código expiró. Solicita uno nuevo.');
      }
      if (m.contains('invalid') || m.contains('token')) {
        throw AuthException('Código incorrecto. Revísalo e inténtalo de nuevo.');
      }
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      throw AuthException(_translate(e.message));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteAccount() async {
    // La Edge Function borra el usuario de auth.users (cascada a todos sus
    // datos). Lanza FunctionException si falla.
    await _client.functions.invoke('delete-account');
    // La sesión ya no es válida; cierra localmente y limpia la caché.
    try {
      await _auth.signOut();
    } catch (_) {}
    _cached = null;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    await _client.from('profiles').update({
      'full_name': user.fullName,
      'phone': user.phone,
      'city': user.city,
      'avatar_url': user.avatarUrl,
    }).eq('id', user.id);
    if (user.isDriver && user.vehicle != null) {
      await _client
          .from('driver_details')
          .upsert({'id': user.id, ...user.vehicle!.toMap()});
    }
    _cached = user;
    return user;
  }

  @override
  Future<void> setOnline(String driverId, bool online) async {
    await _client
        .from('driver_details')
        .update({'is_online': online}).eq('id', driverId);
    // Mantén el usuario cacheado en sincronía con el cambio.
    if (_cached != null && _cached!.id == driverId) {
      _cached = _cached!.copyWith(isOnline: online);
    }
  }

  @override
  Future<AppUser> setDriverDocuments(
    String driverId,
    Map<String, String> docs, {
    String? avatarUrl,
  }) async {
    // Guarda las URLs de los documentos y (re)envía a revisión: status pending.
    await _client.from('driver_details').update({
      ...docs,
      'status': 'pending',
      'rejection_reason': null,
      'submitted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', driverId);
    // La foto del conductor también es su avatar público.
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await _client
          .from('profiles')
          .update({'avatar_url': avatarUrl}).eq('id', driverId);
    }
    final user = await _resolveUser(_auth.currentUser);
    if (user == null) throw AuthException('No se pudo actualizar el perfil');
    return user;
  }

  @override
  Future<AppUser> setPassengerDocuments(
      String userId, Map<String, String> docs) async {
    await _client.from('profiles').update({
      ...docs,
      'verification_status': 'pending',
      'verification_rejection_reason': null,
      'verification_submitted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', userId);
    final user = await _resolveUser(_auth.currentUser);
    if (user == null) throw AuthException('No se pudo actualizar el perfil');
    return user;
  }

  @override
  Future<AppUser?> reloadUser() => _resolveUser(_auth.currentUser);

  @override
  Future<void> updateDriverPresence(
      String driverId, double lat, double lng) async {
    await _client.from('driver_details').update({
      'last_lat': lat,
      'last_lng': lng,
      'last_seen': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', driverId);
  }

  String _translate(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login')) return 'Correo o contraseña incorrectos';
    if (m.contains('email not confirmed') || m.contains('not confirmed')) {
      return 'Debes confirmar tu correo antes de ingresar. Revisa tu bandeja '
          'de entrada (o desactiva “Confirm email” en Supabase para pruebas).';
    }
    if (m.contains('already registered') || m.contains('already exists') ||
        m.contains('duplicate')) {
      return 'Ya existe una cuenta con este correo';
    }
    if (m.contains('rate limit') || m.contains('over_email')) {
      return 'Se alcanzó el límite de correos de Supabase. Espera unos minutos '
          'o desactiva la confirmación por correo para pruebas.';
    }
    if (m.contains('does not exist') || m.contains('relation')) {
      return 'Falta ejecutar el esquema en Supabase (supabase/schema.sql).';
    }
    if (m.contains('row-level security') || m.contains('violates')) {
      return 'Permisos insuficientes. Verifica las políticas RLS del esquema.';
    }
    if (m.contains('password')) return 'La contraseña no cumple los requisitos';
    return 'No pudimos completar la operación. Intenta nuevamente.';
  }
}

class SupabaseTripRepository implements TripRepository {
  SupabaseTripRepository(this._client);
  final SupabaseClient _client;

  Future<AppUser?> _fetchUser(String id) async {
    final p = await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (p == null) return null;
    Vehicle? v;
    if (UserRole.fromString(p['role'] as String?) == UserRole.driver) {
      final d = await _client
          .from('driver_details')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (d != null) v = Vehicle.fromMap(d);
    }
    return AppUser.fromMap(p, vehicle: v);
  }

  Future<List<Trip>> _hydrateTrips(List<Map<String, dynamic>> rows) async {
    final users = <String, AppUser?>{};
    final result = <Trip>[];
    for (final row in rows) {
      final trip = Trip.fromMap(row);
      users[trip.passengerId] ??= await _fetchUser(trip.passengerId);
      AppUser? driver;
      if (trip.driverId != null) {
        users[trip.driverId!] ??= await _fetchUser(trip.driverId!);
        driver = users[trip.driverId!];
      }
      result.add(trip.copyWith(
        passenger: users[trip.passengerId],
        driver: driver,
      ));
    }
    return result;
  }

  /// Stream resiliente para datos "en vivo".
  ///
  /// Combina tres fuentes para que la app funcione siempre:
  ///  1. Un **fetch inicial** inmediato → la UI nunca se queda cargando.
  ///  2. **Realtime** de Supabase → actualizaciones instantáneas (si está
  ///     habilitado en el proyecto).
  ///  3. Un **sondeo periódico** de respaldo → garantiza que los cambios
  ///     lleguen en pocos segundos aunque Realtime no esté configurado.
  Stream<T> _live<T>({
    required Future<T> Function() fetch,
    required String table,
    Duration poll = const Duration(seconds: 5),
  }) {
    late final StreamController<T> controller;
    Timer? timer;
    RealtimeChannel? channel;
    var closed = false;
    var hasData = false;
    var inFlight = false;

    Future<void> emit() async {
      if (closed || inFlight) return;
      inFlight = true;
      try {
        final data = await fetch();
        if (!closed) {
          controller.add(data);
          hasData = true;
        }
      } catch (e, st) {
        // Solo propaga el error si aún no hay datos; si ya mostramos algo,
        // conservamos el último estado bueno y reintentamos en el próximo ciclo.
        if (!closed && !hasData) controller.addError(e, st);
      } finally {
        inFlight = false;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        emit(); // 1) fetch inicial
        timer = Timer.periodic(poll, (_) => emit()); // 3) respaldo
        // 2) realtime → refetch al detectar cualquier cambio en la tabla.
        channel = _client
            .channel('rt:$table:${identityHashCode(controller)}')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: table,
              callback: (_) => emit(),
            )
            .subscribe();
      },
      onCancel: () async {
        closed = true;
        timer?.cancel();
        final ch = channel;
        if (ch != null) await _client.removeChannel(ch);
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<Trip>> watchOpenTrips(DriverArea area) {
    // Primer filtro (servidor): solo solicitudes de la MISMA ciudad del
    // conductor. No se envían solicitudes de otras ciudades. El segundo filtro
    // (radio geográfico desde la ubicación en vivo del conductor) se aplica en
    // el cliente, en el feed y en las notificaciones.
    return _live<List<Trip>>(
      table: 'trips',
      fetch: () async {
        var query =
            _client.from('trips').select().eq('status', 'requested');
        if (area.city != null && area.city!.isNotEmpty) {
          query = query.eq('city', area.city!);
        }
        final rows = await query.order('created_at');
        return _hydrateTrips(rows);
      },
    );
  }

  @override
  Stream<List<DriverLocation>> watchNearbyDrivers({
    required double lat,
    required double lng,
    required double radiusKm,
  }) {
    return _live<List<DriverLocation>>(
      table: 'driver_details',
      poll: const Duration(seconds: 6),
      fetch: () async {
        final staleCutoff = DateTime.now()
            .toUtc()
            .subtract(const Duration(seconds: AppConfig.presenceStaleSeconds))
            .toIso8601String();
        final rows = await _client
            .from('driver_details')
            .select('id, last_lat, last_lng, last_seen, status')
            .eq('is_online', true)
            .eq('status', 'approved')
            .not('last_lat', 'is', null)
            .gte('last_seen', staleCutoff);
        return (rows as List)
            .map((r) => DriverLocation.fromMap(r as Map<String, dynamic>))
            .where((d) =>
                GeoUtils.distanceKm(lat, lng, d.lat, d.lng) <= radiusKm)
            .toList();
      },
    );
  }

  @override
  Stream<List<Trip>> watchPassengerTrips(String passengerId) {
    return _live<List<Trip>>(
      table: 'trips',
      fetch: () async {
        final rows = await _client
            .from('trips')
            .select()
            .eq('passenger_id', passengerId)
            .order('created_at', ascending: false);
        return _hydrateTrips(rows);
      },
    );
  }

  @override
  Stream<List<Trip>> watchDriverTrips(String driverId) {
    return _live<List<Trip>>(
      table: 'trips',
      fetch: () async {
        final rows = await _client
            .from('trips')
            .select()
            .eq('driver_id', driverId)
            .order('created_at', ascending: false);
        return _hydrateTrips(rows);
      },
    );
  }

  @override
  Stream<Trip?> watchTrip(String tripId) {
    return _live<Trip?>(
      table: 'trips',
      poll: const Duration(seconds: 4),
      fetch: () async {
        final row = await _client
            .from('trips')
            .select()
            .eq('id', tripId)
            .maybeSingle();
        if (row == null) return null;
        final list = await _hydrateTrips([row]);
        return list.isEmpty ? null : list.first;
      },
    );
  }

  @override
  Stream<List<Offer>> watchOffers(String tripId) {
    return _live<List<Offer>>(
      table: 'offers',
      poll: const Duration(seconds: 4),
      fetch: () async {
        final rows = await _client
            .from('offers')
            .select()
            .eq('trip_id', tripId)
            .order('amount');
        final result = <Offer>[];
        final users = <String, AppUser?>{};
        for (final row in rows) {
          final offer = Offer.fromMap(row);
          if (offer.status == OfferStatus.rejected ||
              offer.status == OfferStatus.withdrawn) {
            continue;
          }
          users[offer.driverId] ??= await _fetchUser(offer.driverId);
          result.add(offer.copyWith(driver: users[offer.driverId]));
        }
        return result;
      },
    );
  }

  @override
  Stream<List<Offer>> watchDriverOffers(String driverId) {
    return _live<List<Offer>>(
      table: 'offers',
      fetch: () async {
        final rows = await _client
            .from('offers')
            .select()
            .eq('driver_id', driverId)
            .order('created_at', ascending: false);
        return rows.map(Offer.fromMap).toList();
      },
    );
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    await _client
        .from('offers')
        .update({'status': 'withdrawn'}).eq('id', offerId);
  }

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
    PaymentMethod paymentMethod = PaymentMethod.efectivo,
  }) async {
    final row = await _client
        .from('trips')
        .insert({
          'passenger_id': passengerId,
          'city': city,
          'origin_address': originAddress,
          'origin_lat': originLat,
          'origin_lng': originLng,
          'destination_address': destinationAddress,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'offered_fare': offeredFare,
          'note': note,
          'passengers': passengers,
          'payment_method': paymentMethod.value,
          'status': 'requested',
        })
        .select()
        .single();
    return Trip.fromMap(row);
  }

  @override
  Future<Offer> sendOffer({
    required String tripId,
    required String driverId,
    required int amount,
    required OfferKind kind,
    String? message,
    int? etaMinutes,
  }) async {
    final row = await _client
        .from('offers')
        .insert({
          'trip_id': tripId,
          'driver_id': driverId,
          'amount': amount,
          'kind': kind.value,
          'message': message,
          'eta_minutes': etaMinutes,
          'status': 'pending',
        })
        .select()
        .single();
    return Offer.fromMap(row);
  }

  @override
  Future<void> acceptOffer({
    required String tripId,
    required String offerId,
  }) async {
    // Ejecuta la lógica transaccional en la base (función RPC).
    await _client.rpc('accept_offer', params: {
      'p_trip_id': tripId,
      'p_offer_id': offerId,
    });
  }

  @override
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    await _client
        .from('trips')
        .update({'status': status.value}).eq('id', tripId);
  }

  @override
  Future<void> setDriverOnWay(String tripId) async {
    await _client
        .from('trips')
        .update({'driver_on_way': true}).eq('id', tripId);
  }

  @override
  Future<void> setDriverArrived(String tripId) async {
    await _client.from('trips').update({
      'driver_arrived_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', tripId);
  }

  @override
  Future<void> updateDriverLocation(String tripId, double lat, double lng) async {
    await _client
        .from('trips')
        .update({'driver_lat': lat, 'driver_lng': lng}).eq('id', tripId);
  }

  @override
  Future<void> cancelTrip(String tripId) =>
      updateTripStatus(tripId, TripStatus.cancelled);

  @override
  Future<void> rate({
    required String tripId,
    required String raterId,
    required int stars,
    String? comment,
  }) async {
    await _client.from('ratings').insert({
      'trip_id': tripId,
      'rater_id': raterId,
      'stars': stars,
      'comment': comment,
    });
  }

  @override
  Future<AppUser?> userProfile(String userId) => _fetchUser(userId);

  @override
  Future<List<Rating>> userRatings(String userId) async {
    final rows = await _client
        .from('ratings')
        .select('*, rater:profiles!rater_id(*)')
        .eq('ratee_id', userId)
        .order('created_at', ascending: false);
    final list = <Rating>[];
    for (final row in (rows as List)) {
      final map = row as Map<String, dynamic>;
      final r = map['rater'];
      final rater = r is Map<String, dynamic> ? AppUser.fromMap(r) : null;
      list.add(Rating.fromMap(map, rater: rater));
    }
    return list;
  }
}

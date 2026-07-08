import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/offer.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Resultado de un registro. Si [needsVerification] es true, se debe pedir al
/// usuario el código de 6 dígitos enviado a su correo antes de continuar.
class RegisterResult {
  const RegisterResult({required this.needsVerification, required this.email});
  final bool needsVerification;
  final String email;
}

/// Contrato de autenticación y perfil de usuario.
abstract class AuthRepository {
  /// Emite el usuario autenticado actual (o null al cerrar sesión).
  Stream<AppUser?> authState();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  /// Registra un pasajero. La ciudad es opcional: el pasajero puede pedir
  /// viajes en cualquier ciudad y la elige al momento de solicitar el viaje.
  Future<RegisterResult> registerPassenger({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? city,
  });

  Future<RegisterResult> registerDriver({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String password,
    required Vehicle vehicle,
  });

  /// Verifica el código de 6 dígitos enviado por correo tras el registro.
  Future<AppUser> verifyEmailOtp({required String email, required String token});

  /// Reenvía el código de verificación al correo indicado.
  Future<void> resendOtp({required String email});

  Future<void> signOut();

  Future<AppUser> updateProfile(AppUser user);

  Future<void> setOnline(String driverId, bool online);
}

/// Contrato de viajes, ofertas y calificaciones.
abstract class TripRepository {
  /// Viajes abiertos en una ciudad (feed del conductor).
  Stream<List<Trip>> watchOpenTrips(String city);

  /// Viajes creados por un pasajero.
  Stream<List<Trip>> watchPassengerTrips(String passengerId);

  /// Viajes en los que participa un conductor (aceptados / en curso / histórico).
  Stream<List<Trip>> watchDriverTrips(String driverId);

  /// Un viaje puntual con sus datos embebidos.
  Stream<Trip?> watchTrip(String tripId);

  /// Ofertas de un viaje (vista del pasajero).
  Stream<List<Offer>> watchOffers(String tripId);

  /// Ofertas realizadas por un conductor (para saber en qué viajes ya ofertó).
  Stream<List<Offer>> watchDriverOffers(String driverId);

  /// Retira una oferta pendiente del conductor.
  Future<void> withdrawOffer(String offerId);

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
    int passengers,
  });

  Future<Offer> sendOffer({
    required String tripId,
    required String driverId,
    required int amount,
    required OfferKind kind,
    String? message,
    int? etaMinutes,
  });

  Future<void> acceptOffer({required String tripId, required String offerId});

  Future<void> updateTripStatus(String tripId, TripStatus status);

  Future<void> cancelTrip(String tripId);

  Future<void> rate({
    required String tripId,
    required String raterId,
    required int stars,
    String? comment,
  });
}

import '../models/app_user.dart';
import '../models/enums.dart';
import '../models/offer.dart';
import '../models/rating.dart';
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

  /// Envía un correo de recuperación de contraseña.
  Future<void> resetPassword({required String email});

  Future<void> signOut();

  Future<AppUser> updateProfile(AppUser user);

  Future<void> setOnline(String driverId, bool online);
}

/// Punto de referencia de un conductor para buscar viajes cercanos: su ciudad
/// (para respaldo por región) y las coordenadas del centro de esa ciudad.
class DriverArea {
  const DriverArea({this.city, required this.lat, required this.lng});
  final String? city;
  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is DriverArea &&
      other.city == city &&
      other.lat == lat &&
      other.lng == lng;

  @override
  int get hashCode => Object.hash(city, lat, lng);
}

/// Contrato de viajes, ofertas y calificaciones.
abstract class TripRepository {
  /// Viajes abiertos cercanos al conductor (feed del conductor).
  Stream<List<Trip>> watchOpenTrips(DriverArea area);

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

  /// El conductor marca que va en camino a recoger al pasajero.
  Future<void> setDriverOnWay(String tripId);

  /// El conductor marca que llegó al punto de partida.
  Future<void> setDriverArrived(String tripId);

  /// Actualiza la ubicación en vivo del conductor durante el viaje.
  Future<void> updateDriverLocation(String tripId, double lat, double lng);

  Future<void> cancelTrip(String tripId);

  Future<void> rate({
    required String tripId,
    required String raterId,
    required int stars,
    String? comment,
  });

  /// Calificaciones recibidas por un usuario (historial de reseñas).
  Future<List<Rating>> userRatings(String userId);
}

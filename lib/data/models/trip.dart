import 'app_user.dart';
import 'enums.dart';

/// Solicitud de viaje creada por un pasajero.
class Trip {
  const Trip({
    required this.id,
    required this.passengerId,
    required this.city,
    required this.originAddress,
    required this.destinationAddress,
    required this.offeredFare,
    required this.status,
    required this.createdAt,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.note,
    this.passengers = 1,
    this.driverId,
    this.finalFare,
    this.acceptedOfferId,
    this.passenger,
    this.driver,
    this.offersCount = 0,
    this.passengerRated = false,
    this.driverRated = false,
  });

  final String id;
  final String passengerId;
  final String city;
  final String originAddress;
  final String destinationAddress;
  final int offeredFare;
  final TripStatus status;
  final DateTime createdAt;

  /// Coordenadas opcionales de origen/destino (para mostrar mapa y ruta).
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;

  final String? note;
  final int passengers;
  final String? driverId;
  final int? finalFare;
  final String? acceptedOfferId;

  // Datos embebidos opcionales (join).
  final AppUser? passenger;
  final AppUser? driver;
  final int offersCount;
  final bool passengerRated;
  final bool driverRated;

  int get displayFare => finalFare ?? offeredFare;

  /// Verdadero si el viaje tiene coordenadas de origen y destino para mostrar
  /// el mapa de la ruta.
  bool get hasRoute =>
      originLat != null &&
      originLng != null &&
      destinationLat != null &&
      destinationLng != null;

  bool get isActive =>
      status == TripStatus.accepted || status == TripStatus.inProgress;
  bool get isOpen => status == TripStatus.requested;

  Trip copyWith({
    TripStatus? status,
    String? driverId,
    int? finalFare,
    String? acceptedOfferId,
    AppUser? driver,
    AppUser? passenger,
    int? offersCount,
    bool? passengerRated,
    bool? driverRated,
  }) {
    return Trip(
      id: id,
      passengerId: passengerId,
      city: city,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      offeredFare: offeredFare,
      status: status ?? this.status,
      createdAt: createdAt,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      note: note,
      passengers: passengers,
      driverId: driverId ?? this.driverId,
      finalFare: finalFare ?? this.finalFare,
      acceptedOfferId: acceptedOfferId ?? this.acceptedOfferId,
      passenger: passenger ?? this.passenger,
      driver: driver ?? this.driver,
      offersCount: offersCount ?? this.offersCount,
      passengerRated: passengerRated ?? this.passengerRated,
      driverRated: driverRated ?? this.driverRated,
    );
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] as String,
      passengerId: map['passenger_id'] as String,
      city: (map['city'] as String?) ?? '',
      originAddress: (map['origin_address'] as String?) ?? '',
      destinationAddress: (map['destination_address'] as String?) ?? '',
      offeredFare: (map['offered_fare'] as num?)?.toInt() ?? 0,
      status: TripStatus.fromString(map['status'] as String?),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      originLat: (map['origin_lat'] as num?)?.toDouble(),
      originLng: (map['origin_lng'] as num?)?.toDouble(),
      destinationLat: (map['destination_lat'] as num?)?.toDouble(),
      destinationLng: (map['destination_lng'] as num?)?.toDouble(),
      note: map['note'] as String?,
      passengers: (map['passengers'] as num?)?.toInt() ?? 1,
      driverId: map['driver_id'] as String?,
      finalFare: (map['final_fare'] as num?)?.toInt(),
      acceptedOfferId: map['accepted_offer_id'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() => {
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
        'status': status.value,
      };
}

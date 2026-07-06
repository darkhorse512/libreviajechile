import 'app_user.dart';
import 'enums.dart';

/// Oferta o contraoferta enviada por un conductor sobre un viaje.
class Offer {
  const Offer({
    required this.id,
    required this.tripId,
    required this.driverId,
    required this.amount,
    required this.kind,
    required this.status,
    required this.createdAt,
    this.message,
    this.driver,
    this.etaMinutes,
  });

  final String id;
  final String tripId;
  final String driverId;
  final int amount;
  final OfferKind kind;
  final OfferStatus status;
  final DateTime createdAt;
  final String? message;
  final AppUser? driver;
  final int? etaMinutes;

  bool get isCounter => kind == OfferKind.counter;

  Offer copyWith({OfferStatus? status, AppUser? driver}) {
    return Offer(
      id: id,
      tripId: tripId,
      driverId: driverId,
      amount: amount,
      kind: kind,
      status: status ?? this.status,
      createdAt: createdAt,
      message: message,
      driver: driver ?? this.driver,
      etaMinutes: etaMinutes,
    );
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      driverId: map['driver_id'] as String,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      kind: OfferKind.fromString(map['kind'] as String?),
      status: OfferStatus.fromString(map['status'] as String?),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      message: map['message'] as String?,
      etaMinutes: (map['eta_minutes'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'trip_id': tripId,
        'driver_id': driverId,
        'amount': amount,
        'kind': kind.value,
        'message': message,
        'eta_minutes': etaMinutes,
        'status': status.value,
      };
}

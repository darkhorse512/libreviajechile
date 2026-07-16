import 'enums.dart';
import 'vehicle.dart';

/// Usuario de la app (perfil unificado pasajero/conductor).
class AppUser {
  const AppUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
    this.city,
    this.avatarUrl,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.tripsCount = 0,
    this.createdAt,
    this.vehicle,
    this.isOnline = false,
    this.isVerified = false,
    this.verificationStatus = DriverVerificationStatus.approved,
    this.rejectionReason,
  });

  final String id;
  final UserRole role;
  final String fullName;
  final String email;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final double ratingAvg;
  final int ratingCount;
  final int tripsCount;
  final DateTime? createdAt;

  // Solo para conductores.
  final Vehicle? vehicle;
  final bool isOnline;
  final bool isVerified;

  /// Estado de verificación (solo conductores). Los pasajeros se consideran
  /// "aprobados" por defecto (no aplica).
  final DriverVerificationStatus verificationStatus;
  final String? rejectionReason;

  bool get isDriver => role == UserRole.driver;
  bool get hasRatings => ratingCount > 0;

  /// Un conductor aprobado puede ponerse en línea y aceptar viajes.
  bool get isApprovedDriver =>
      !isDriver || verificationStatus == DriverVerificationStatus.approved;

  /// El conductor ya envió sus documentos y espera revisión.
  bool get hasSubmittedDocuments {
    final v = vehicle;
    return v != null &&
        v.docDriverPhoto != null &&
        v.docLicense != null &&
        v.docVehicleReg != null &&
        v.docAntecedentes != null &&
        v.docSoap != null &&
        v.docCarFront != null &&
        v.docCarBack != null;
  }

  AppUser copyWith({
    UserRole? role,
    String? fullName,
    String? phone,
    String? city,
    String? avatarUrl,
    double? ratingAvg,
    int? ratingCount,
    int? tripsCount,
    Vehicle? vehicle,
    bool? isOnline,
    bool? isVerified,
    DriverVerificationStatus? verificationStatus,
    String? rejectionReason,
  }) {
    return AppUser(
      id: id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      tripsCount: tripsCount ?? this.tripsCount,
      createdAt: createdAt,
      vehicle: vehicle ?? this.vehicle,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {Vehicle? vehicle}) {
    return AppUser(
      id: map['id'] as String,
      role: UserRole.fromString(map['role'] as String?),
      fullName: (map['full_name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      ratingAvg: (map['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
      tripsCount: (map['trips_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      isOnline: (map['is_online'] as bool?) ?? false,
      isVerified: (map['is_verified'] as bool?) ?? false,
      verificationStatus:
          DriverVerificationStatus.fromString(map['status'] as String?),
      rejectionReason: map['rejection_reason'] as String?,
      vehicle: vehicle,
    );
  }

  Map<String, dynamic> toProfileMap() => {
        'id': id,
        'role': role.name,
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'avatar_url': avatarUrl,
      };
}

/// Rol del usuario en la plataforma.
enum UserRole {
  passenger,
  driver,
  admin;

  static UserRole fromString(String? value) => switch (value) {
        'driver' => UserRole.driver,
        'admin' => UserRole.admin,
        _ => UserRole.passenger,
      };

  String get label => switch (this) {
        UserRole.passenger => 'Pasajero',
        UserRole.driver => 'Conductor',
        UserRole.admin => 'Administrador',
      };
}

/// Estado del ciclo de vida de un viaje.
enum TripStatus {
  requested, // publicado, esperando ofertas
  accepted, // el pasajero aceptó una oferta
  inProgress, // viaje en curso
  completed, // finalizado
  cancelled; // cancelado

  static TripStatus fromString(String? value) => switch (value) {
        'accepted' => TripStatus.accepted,
        'in_progress' => TripStatus.inProgress,
        'completed' => TripStatus.completed,
        'cancelled' => TripStatus.cancelled,
        _ => TripStatus.requested,
      };

  String get value => switch (this) {
        TripStatus.requested => 'requested',
        TripStatus.accepted => 'accepted',
        TripStatus.inProgress => 'in_progress',
        TripStatus.completed => 'completed',
        TripStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        TripStatus.requested => 'Buscando conductor',
        TripStatus.accepted => 'Conductor asignado',
        TripStatus.inProgress => 'En viaje',
        TripStatus.completed => 'Completado',
        TripStatus.cancelled => 'Cancelado',
      };
}

/// Tipo de oferta enviada por un conductor.
enum OfferKind {
  accept, // acepta el precio propuesto por el pasajero
  counter; // propone un precio distinto (contraoferta)

  static OfferKind fromString(String? value) =>
      value == 'counter' ? OfferKind.counter : OfferKind.accept;

  String get value => this == OfferKind.counter ? 'counter' : 'accept';
}

/// Estado de una oferta.
enum OfferStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  static OfferStatus fromString(String? value) => switch (value) {
        'accepted' => OfferStatus.accepted,
        'rejected' => OfferStatus.rejected,
        'withdrawn' => OfferStatus.withdrawn,
        _ => OfferStatus.pending,
      };

  String get value => name;
}

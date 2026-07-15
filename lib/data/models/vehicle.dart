/// Datos del vehículo de un conductor.
class Vehicle {
  const Vehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
    this.seats = 4,
    this.carPhotos = const [],
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plate;
  final int seats;

  /// URLs de fotos del auto (para que el pasajero lo reconozca).
  final List<String> carPhotos;

  String get displayName => '$make $model';
  String get summary => '$make $model · $year · $color';

  Vehicle copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    String? plate,
    int? seats,
    List<String>? carPhotos,
  }) {
    return Vehicle(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      seats: seats ?? this.seats,
      carPhotos: carPhotos ?? this.carPhotos,
    );
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      make: (map['make'] as String?) ?? '',
      model: (map['model'] as String?) ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      color: (map['color'] as String?) ?? '',
      plate: (map['plate'] as String?) ?? '',
      seats: (map['seats'] as num?)?.toInt() ?? 4,
      carPhotos: (map['car_photos'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'plate': plate.toUpperCase(),
        'seats': seats,
        'car_photos': carPhotos,
      };
}

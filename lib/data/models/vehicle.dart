/// Datos del vehículo de un conductor.
class Vehicle {
  const Vehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
    this.seats = 4,
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plate;
  final int seats;

  String get displayName => '$make $model';
  String get summary => '$make $model · $year · $color';

  Vehicle copyWith({
    String? make,
    String? model,
    int? year,
    String? color,
    String? plate,
    int? seats,
  }) {
    return Vehicle(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      seats: seats ?? this.seats,
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
    );
  }

  Map<String, dynamic> toMap() => {
        'make': make,
        'model': model,
        'year': year,
        'color': color,
        'plate': plate.toUpperCase(),
        'seats': seats,
      };
}

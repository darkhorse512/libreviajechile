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
    this.docDriverPhoto,
    this.docLicense,
    this.docVehicleReg,
    this.docAntecedentes,
    this.docSoap,
    this.docCarFront,
    this.docCarBack,
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plate;
  final int seats;

  /// URLs de fotos del auto (para que el pasajero lo reconozca).
  final List<String> carPhotos;

  // Documentos de verificación (imagen o PDF en R2). Solo visibles para el
  // conductor y el panel de administración.
  final String? docDriverPhoto; // foto del conductor (también avatar)
  final String? docLicense; // licencia de conducir
  final String? docVehicleReg; // permiso de circulación
  final String? docAntecedentes; // certificado de antecedentes
  final String? docSoap; // seguro obligatorio (SOAP)
  final String? docCarFront; // foto del auto — delantera
  final String? docCarBack; // foto del auto — trasera

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
    String? docDriverPhoto,
    String? docLicense,
    String? docVehicleReg,
    String? docAntecedentes,
    String? docSoap,
    String? docCarFront,
    String? docCarBack,
  }) {
    return Vehicle(
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      seats: seats ?? this.seats,
      carPhotos: carPhotos ?? this.carPhotos,
      docDriverPhoto: docDriverPhoto ?? this.docDriverPhoto,
      docLicense: docLicense ?? this.docLicense,
      docVehicleReg: docVehicleReg ?? this.docVehicleReg,
      docAntecedentes: docAntecedentes ?? this.docAntecedentes,
      docSoap: docSoap ?? this.docSoap,
      docCarFront: docCarFront ?? this.docCarFront,
      docCarBack: docCarBack ?? this.docCarBack,
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
      docDriverPhoto: map['doc_driver_photo'] as String?,
      docLicense: map['doc_license'] as String?,
      docVehicleReg: map['doc_vehicle_reg'] as String?,
      docAntecedentes: map['doc_antecedentes'] as String?,
      docSoap: map['doc_soap'] as String?,
      docCarFront: map['doc_car_front'] as String?,
      docCarBack: map['doc_car_back'] as String?,
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

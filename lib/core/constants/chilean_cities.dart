/// Ciudades/comunas principales de Chile para el selector de ciudad del MVP.
/// Ordenadas de norte a sur por región.
class ChileanCity {
  const ChileanCity({required this.name, required this.region});

  final String name;
  final String region;

  @override
  bool operator ==(Object other) =>
      other is ChileanCity && other.name == name && other.region == region;

  @override
  int get hashCode => Object.hash(name, region);
}

const List<ChileanCity> kChileanCities = [
  ChileanCity(name: 'Arica', region: 'Arica y Parinacota'),
  ChileanCity(name: 'Iquique', region: 'Tarapacá'),
  ChileanCity(name: 'Alto Hospicio', region: 'Tarapacá'),
  ChileanCity(name: 'Antofagasta', region: 'Antofagasta'),
  ChileanCity(name: 'Calama', region: 'Antofagasta'),
  ChileanCity(name: 'Copiapó', region: 'Atacama'),
  ChileanCity(name: 'La Serena', region: 'Coquimbo'),
  ChileanCity(name: 'Coquimbo', region: 'Coquimbo'),
  ChileanCity(name: 'Ovalle', region: 'Coquimbo'),
  ChileanCity(name: 'Valparaíso', region: 'Valparaíso'),
  ChileanCity(name: 'Viña del Mar', region: 'Valparaíso'),
  ChileanCity(name: 'Quilpué', region: 'Valparaíso'),
  ChileanCity(name: 'San Antonio', region: 'Valparaíso'),
  ChileanCity(name: 'Santiago', region: 'Metropolitana'),
  ChileanCity(name: 'Maipú', region: 'Metropolitana'),
  ChileanCity(name: 'Puente Alto', region: 'Metropolitana'),
  ChileanCity(name: 'La Florida', region: 'Metropolitana'),
  ChileanCity(name: 'Las Condes', region: 'Metropolitana'),
  ChileanCity(name: 'Providencia', region: 'Metropolitana'),
  ChileanCity(name: 'Rancagua', region: "O'Higgins"),
  ChileanCity(name: 'Talca', region: 'Maule'),
  ChileanCity(name: 'Curicó', region: 'Maule'),
  ChileanCity(name: 'Chillán', region: 'Ñuble'),
  ChileanCity(name: 'Concepción', region: 'Biobío'),
  ChileanCity(name: 'Talcahuano', region: 'Biobío'),
  ChileanCity(name: 'Los Ángeles', region: 'Biobío'),
  ChileanCity(name: 'Temuco', region: 'La Araucanía'),
  ChileanCity(name: 'Valdivia', region: 'Los Ríos'),
  ChileanCity(name: 'Osorno', region: 'Los Lagos'),
  ChileanCity(name: 'Puerto Montt', region: 'Los Lagos'),
  ChileanCity(name: 'Coyhaique', region: 'Aysén'),
  ChileanCity(name: 'Punta Arenas', region: 'Magallanes'),
];

import 'package:flutter/widgets.dart';

import 'gen/auth_i18n.dart';
import 'gen/common_i18n.dart';
import 'gen/driver_i18n.dart';
import 'gen/passenger_i18n.dart';
import 'gen/profile_trips_i18n.dart';

/// Mapa combinado de traducciones al INGLÉS. La clave es el texto en español.
final Map<String, String> _en = {
  ...commonEn,
  ...authEn,
  ...passengerEn,
  ...driverEn,
  ...profileTripsEn,
};

/// Mapa combinado de traducciones al PORTUGUÉS (Brasil).
final Map<String, String> _pt = {
  ...commonPt,
  ...authPt,
  ...passengerPt,
  ...driverPt,
  ...profileTripsPt,
};

/// Idioma activo, para código SIN BuildContext (validadores, formateadores).
/// Se mantiene sincronizado desde `app.dart` al resolver el locale.
String gLanguageCode = 'es';

/// Traducción sin contexto (usa [gLanguageCode]).
String trg(String es) => translate(es, gLanguageCode);

/// Traducción sin contexto con marcadores `{x}`.
String trgp(String es, Map<String, String> args) {
  var out = trg(es);
  args.forEach((key, value) => out = out.replaceAll('{$key}', value));
  return out;
}

/// Traducción por clave-española. Si no hay traducción para el idioma activo,
/// devuelve el texto original en español (nunca rompe la UI).
String translate(String es, String languageCode) {
  switch (languageCode) {
    case 'en':
      return _en[es] ?? es;
    case 'pt':
      return _pt[es] ?? es;
    default:
      return es;
  }
}

/// Uso: `context.tr('Solicitar viaje')`.
///
/// Para textos con valores dinámicos usa marcadores `{x}` y [trp]:
///   `context.trp('{n} pasajeros', {'n': '3'})`.
extension Tr on BuildContext {
  String tr(String es) =>
      translate(es, Localizations.localeOf(this).languageCode);

  String trp(String es, Map<String, String> args) {
    var out = tr(es);
    args.forEach((key, value) => out = out.replaceAll('{$key}', value));
    return out;
  }
}

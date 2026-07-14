import 'package:intl/intl.dart';

import '../i18n/i18n.dart';

/// Formateadores para la localización chilena (CLP, fechas, etc.).
abstract class Formatters {
  static final NumberFormat _plain = NumberFormat.decimalPattern('es_CL');

  /// 15000 -> "$15.000" (en Chile el signo peso va ANTES, sin espacio).
  static String clp(num value) => '\$${_plain.format(value)}';

  /// 15000 -> "15.000" (sin símbolo)
  static String clpPlain(num value) => _plain.format(value);

  /// "hace 3 min", "hace 2 h", "ayer"
  static String relative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return trg('recién');
    if (diff.inMinutes < 60) {
      return trgp('hace {n} min', {'n': '${diff.inMinutes}'});
    }
    if (diff.inHours < 24) return trgp('hace {n} h', {'n': '${diff.inHours}'});
    if (diff.inDays == 1) return trg('ayer');
    if (diff.inDays < 7) return trgp('hace {n} días', {'n': '${diff.inDays}'});
    return DateFormat('d MMM', gLanguageCode).format(time);
  }

  static String date(DateTime time) => DateFormat('d MMM y', 'es').format(time);
  static String time(DateTime time) => DateFormat('HH:mm', 'es').format(time);

  /// Iniciales para avatares: "Juan Pérez" -> "JP"
  static String initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

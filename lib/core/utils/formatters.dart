import 'package:intl/intl.dart';

/// Formateadores para la localización chilena (CLP, fechas, etc.).
abstract class Formatters {
  static final NumberFormat _clp =
      NumberFormat.currency(locale: 'es_CL', symbol: r'$', decimalDigits: 0);

  /// 15000 -> "$15.000"
  static String clp(num value) => _clp.format(value);

  /// 15000 -> "15.000" (sin símbolo)
  static String clpPlain(num value) =>
      NumberFormat.decimalPattern('es_CL').format(value);

  /// "hace 3 min", "hace 2 h", "ayer"
  static String relative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'recién';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'ayer';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';
    return DateFormat('d MMM', 'es').format(time);
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

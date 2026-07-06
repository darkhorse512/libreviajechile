/// Validadores de formularios (mensajes en español).
abstract class Validators {
  static String? required(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo';
    }
    final re = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(value.trim())) return 'Correo no válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu nombre';
    if (value.trim().length < 2) return 'Nombre demasiado corto';
    return null;
  }

  /// Teléfono chileno flexible: +56 9 XXXX XXXX o formatos similares.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa tu teléfono';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Teléfono no válido';
    return null;
  }

  /// Patente chilena: formato antiguo (AB1234) o nuevo (BBBB12).
  static String? plate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa la patente';
    final v = value.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    final re = RegExp(r'^([A-Z]{2}\d{4}|[A-Z]{4}\d{2})$');
    if (!re.hasMatch(v)) return 'Patente no válida (ej: BBBB12)';
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el año';
    final year = int.tryParse(value.trim());
    final now = DateTime.now().year;
    if (year == null || year < 1990 || year > now + 1) {
      return 'Año no válido';
    }
    return null;
  }
}

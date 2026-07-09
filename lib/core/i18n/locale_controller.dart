import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_controller.dart' show sharedPreferencesProvider;
import 'app_language.dart';

/// Controla el idioma de la app y lo persiste.
///
/// Estado `null` = seguir el idioma del dispositivo (según la ubicación/región
/// del sistema). Un valor concreto = idioma elegido manualmente por el usuario.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._prefs) : super(_load(_prefs));

  static const _key = 'app_locale';
  final SharedPreferences _prefs;

  static Locale? _load(SharedPreferences prefs) {
    final lang = AppLanguageX.fromCode(prefs.getString(_key));
    return lang?.locale; // null → automático (idioma del dispositivo)
  }

  /// Idioma elegido manualmente, o `null` si se sigue el del dispositivo.
  AppLanguage? get selected =>
      state == null ? null : AppLanguageX.fromCode(state!.languageCode);

  /// Cambia el idioma. `null` vuelve al automático (dispositivo).
  Future<void> setLanguage(AppLanguage? lang) async {
    if (lang == null) {
      state = null;
      await _prefs.remove(_key);
    } else {
      state = lang.locale;
      await _prefs.setString(_key, lang.code);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});

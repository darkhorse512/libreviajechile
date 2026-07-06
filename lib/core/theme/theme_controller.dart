import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider global de `SharedPreferences` (se sobreescribe en `main`).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences no inicializado'),
);

/// Controla el modo de tema (claro / oscuro / sistema) y lo persiste.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController(this._prefs) : super(_load(_prefs));

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    switch (prefs.getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }

  /// Alterna entre claro y oscuro (usado por el botón de la barra superior).
  Future<void> toggle(Brightness current) async {
    await set(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeMode>((ref) {
  return ThemeController(ref.watch(sharedPreferencesProvider));
});

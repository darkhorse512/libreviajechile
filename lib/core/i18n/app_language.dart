import 'package:flutter/widgets.dart';

/// Idiomas soportados por la app.
enum AppLanguage { es, en, pt }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.es => 'es',
        AppLanguage.en => 'en',
        AppLanguage.pt => 'pt',
      };

  Locale get locale => Locale(code);

  /// Nombre en su propio idioma (para el selector).
  String get nativeName => switch (this) {
        AppLanguage.es => 'Español',
        AppLanguage.en => 'English',
        AppLanguage.pt => 'Português (Brasil)',
      };

  /// Bandera representativa.
  String get flag => switch (this) {
        AppLanguage.es => '🇨🇱',
        AppLanguage.en => '🇺🇸',
        AppLanguage.pt => '🇧🇷',
      };

  static AppLanguage? fromCode(String? code) => switch (code) {
        'es' => AppLanguage.es,
        'en' => AppLanguage.en,
        'pt' => AppLanguage.pt,
        _ => null,
      };
}

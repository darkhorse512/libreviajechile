import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/i18n/i18n.dart';
import 'core/i18n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class LibreViajeApp extends ConsumerWidget {
  const LibreViajeApp({super.key});

  static const supportedLocales = [Locale('es'), Locale('en'), Locale('pt')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);
    // `null` = seguir el idioma del dispositivo (según su región).
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      supportedLocales: supportedLocales,
      // Cuando el idioma es automático, usa el del dispositivo si está entre los
      // soportados; si no, español por defecto.
      localeResolutionCallback: (deviceLocale, supported) {
        Locale resolved = const Locale('es');
        if (deviceLocale != null) {
          for (final l in supported) {
            if (l.languageCode == deviceLocale.languageCode) {
              resolved = l;
              break;
            }
          }
        }
        // Mantén el idioma global para código sin contexto.
        gLanguageCode = resolved.languageCode;
        return resolved;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

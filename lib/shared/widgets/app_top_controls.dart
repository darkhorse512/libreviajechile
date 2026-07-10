import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_controller.dart';
import 'language_picker.dart';

/// Controles rápidos de tema e idioma, pensados para la esquina superior
/// derecha de todas las pantallas.
///
/// - `floating: false` → dos [IconButton] planos (para `AppBar.actions`).
/// - `floating: true`  → una "píldora" con fondo para superponer sobre el
///   contenido (mapas, degradados) manteniendo el contraste.
class AppTopControls extends ConsumerWidget {
  const AppTopControls({super.key, this.floating = false});

  final bool floating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: isDark ? context.tr('Modo claro') : context.tr('Modo oscuro'),
          visualDensity: VisualDensity.compact,
          onPressed: () =>
              ref.read(themeControllerProvider.notifier).toggle(brightness),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 22,
          ),
        ),
        IconButton(
          tooltip: context.tr('Idioma'),
          visualDensity: VisualDensity.compact,
          onPressed: () => showLanguagePicker(context),
          icon: const Icon(Icons.language_rounded, size: 22),
        ),
      ],
    );

    if (!floating) return buttons;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: buttons,
    );
  }
}

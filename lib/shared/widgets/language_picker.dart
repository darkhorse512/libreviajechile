import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/app_language.dart';
import '../../core/i18n/i18n.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Abre el selector de idioma (hoja inferior).
Future<void> showLanguagePicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(localeControllerProvider.notifier).selected;

    Widget option({
      required String flag,
      required String title,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          )),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.brand, size: 22),
              ],
            ),
          ),
        ),
      );
    }

    void choose(AppLanguage? lang) {
      ref.read(localeControllerProvider.notifier).setLanguage(lang);
      Navigator.of(context).pop();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.palette.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.tr('Selecciona un idioma'),
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            option(
              flag: '🌐',
              title: context.tr('Automático (dispositivo)'),
              isSelected: selected == null,
              onTap: () => choose(null),
            ),
            for (final lang in AppLanguage.values)
              option(
                flag: lang.flag,
                title: lang.nativeName,
                isSelected: selected == lang,
                onTap: () => choose(lang),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

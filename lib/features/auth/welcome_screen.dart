import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/brand_background.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/theme_toggle_button.dart';

/// Pantalla de bienvenida: punto de entrada al flujo de autenticación.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(isDemoModeProvider);
    return Scaffold(
      body: BrandBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: ThemeToggleButton(),
                ),
                const Spacer(flex: 2),
                const AppLogoMark(size: 96)
                    .animate()
                    .scale(curve: Curves.easeOutBack, duration: 500.ms)
                    .fadeIn(),
                const SizedBox(height: 28),
                Text(
                  context.tr('Bienvenido a bordo'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                      'Tú pones el precio, tú eliges el viaje.\nMoverte por Chile nunca fue tan libre.'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),
                const Spacer(flex: 3),
                PrimaryButton(
                  label: context.tr('Crear cuenta'),
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => context.push(Routes.roleSelection),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.3),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: context.tr('Ya tengo cuenta'),
                  onPressed: () => context.push(Routes.login),
                ).animate().fadeIn(delay: 550.ms),
                if (isDemo) ...[
                  const SizedBox(height: 20),
                  _DemoBadge(),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.price.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.price.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science_rounded, size: 16, color: AppColors.price),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.tr('Modo demostración · datos de prueba'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.price,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

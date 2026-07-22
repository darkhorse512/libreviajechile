import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/contact.dart';

/// Un número de emergencia de Chile.
class _Emergency {
  const _Emergency(this.label, this.number, {this.icon, this.badge});
  final String label;
  final String number;
  final IconData? icon;
  final String? badge; // texto en el recuadro (p. ej. "PDI")
}

const _numbers = <_Emergency>[
  _Emergency('Ambulancia (SAMU)', '131',
      icon: Icons.medical_services_rounded),
  _Emergency('Bomberos', '132', icon: Icons.local_fire_department_rounded),
  _Emergency('Carabineros', '133', icon: Icons.local_police_rounded),
  _Emergency('PDI', '134', badge: 'PDI'),
  _Emergency('Fono Familia / Carabineros', '149',
      icon: Icons.groups_rounded),
];

/// Página de Números de Emergencia (Chile) para conductores EligeDriver.
///
/// Se muestra siempre con estética oscura de alta visibilidad (como el afiche
/// de seguridad), independientemente del tema de la app. Cada tarjeta llama al
/// número correspondiente.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        title: Text(context.tr('Números de emergencia')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 4, AppSpacing.xl, AppSpacing.xl),
          children: [
            // ---- Encabezado ------------------------------------------------
            Center(
              child: Column(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.brand.withValues(alpha: 0.5),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brand.withValues(alpha: 0.35),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emergency_rounded,
                        color: AppColors.brand, size: 38),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('Números de Emergencia'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                      children: [
                        TextSpan(text: '${context.tr('Chile')} · '),
                        const TextSpan(
                            text: 'Conductores ',
                            style:
                                TextStyle(color: AppColors.darkTextPrimary)),
                        const TextSpan(
                            text: 'EligeDriver',
                            style: TextStyle(color: AppColors.brand)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---- Tarjetas de números --------------------------------------
            for (final e in _numbers) ...[
              _EmergencyCard(e: e),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 8),
            const _EmergencyTips(),
            const SizedBox(height: 16),
            const _SafetyFooter(),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.e});
  final _Emergency e;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Contact.call(context, e.number),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              // Recuadro de ícono (lima con contenido oscuro).
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: e.badge != null
                    ? Text(e.badge!,
                        style: const TextStyle(
                          color: AppColors.onBrand,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ))
                    : Icon(e.icon, color: AppColors.onBrand, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  e.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 38,
                color: AppColors.darkBorder,
              ),
              const SizedBox(width: 14),
              Text(
                e.number,
                style: const TextStyle(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.call_rounded,
                  color: AppColors.brand, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyTips extends StatelessWidget {
  const _EmergencyTips();

  @override
  Widget build(BuildContext context) {
    final tips = [
      context.tr('Detente en un lugar seguro'),
      context.tr('Comparte tu ubicación'),
      context.tr('Llama al número correspondiente'),
      context.tr('Mantén la calma'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.brand, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('Si tienes una emergencia:'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.brand,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final t in tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: AppColors.brand, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.darkTextSecondary,
                                    height: 1.3,
                                  )),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.brand.withValues(alpha: 0.6), width: 2),
            ),
            child: const Icon(Icons.phone_in_talk_rounded,
                color: AppColors.brand, size: 30),
          ),
        ],
      ),
    );
  }
}

class _SafetyFooter extends StatelessWidget {
  const _SafetyFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_rounded,
              color: AppColors.brand, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                children: [
                  TextSpan(
                      text: '${context.tr('Tu seguridad es prioridad en')} '),
                  const TextSpan(
                    text: 'EligeDriver.',
                    style: TextStyle(
                        color: AppColors.brand, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

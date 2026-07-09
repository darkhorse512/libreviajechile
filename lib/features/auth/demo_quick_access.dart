import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/vehicle.dart';
import '../../shared/widgets/app_feedback.dart';
import 'auth_controller.dart';

/// Accesos rápidos que sólo aparecen en modo demostración: crean al vuelo una
/// cuenta de pasajero o conductor para explorar la app sin registrarse.
class DemoQuickAccess extends ConsumerWidget {
  const DemoQuickAccess({super.key});

  Future<void> _enterAsPassenger(BuildContext context, WidgetRef ref) async {
    final n = DateTime.now().millisecondsSinceEpoch % 100000;
    final result = await ref.read(authFormControllerProvider.notifier).registerPassenger(
          fullName: 'Pasajero Demo',
          email: 'pasajero$n@demo.cl',
          phone: '+56 9 1111 2222',
          city: 'Santiago',
          password: 'demo1234',
        );
    if (result == null && context.mounted) {
      AppFeedback.error(context, context.tr('No se pudo iniciar la demo'));
    }
  }

  Future<void> _enterAsDriver(BuildContext context, WidgetRef ref) async {
    final n = DateTime.now().millisecondsSinceEpoch % 100000;
    final result = await ref.read(authFormControllerProvider.notifier).registerDriver(
          fullName: 'Conductor Demo',
          email: 'conductor$n@demo.cl',
          phone: '+56 9 3333 4444',
          city: 'Santiago',
          password: 'demo1234',
          vehicle: const Vehicle(
            make: 'Toyota',
            model: 'Corolla',
            year: 2022,
            color: 'Plateado',
            plate: 'DEMO12',
          ),
        );
    if (result == null && context.mounted) {
      AppFeedback.error(context, context.tr('No se pudo iniciar la demo'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded,
                  size: 18, color: AppColors.price),
              const SizedBox(width: 8),
              Text(context.tr('Explorar sin registro'),
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
                'Modo demostración con datos de prueba. Ideal para revisar la interfaz.'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.palette.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _enterAsPassenger(context, ref),
                  icon: const Icon(Icons.person_rounded, size: 18),
                  label: Text(context.tr('Pasajero')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _enterAsDriver(context, ref),
                  icon: const Icon(Icons.directions_car_rounded, size: 18),
                  label: Text(context.tr('Conductor')),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

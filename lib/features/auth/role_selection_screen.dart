import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/surface_card.dart';

/// Elección del rol: pasajero o conductor. Cada uno inicia su propio flujo.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cómo quieres usar\nLibre Viaje Chile?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige tu perfil para crear tu cuenta. Podrás cambiarlo más adelante.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.palette.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              _RoleCard(
                icon: Icons.airline_seat_recline_normal_rounded,
                color: AppColors.brand,
                title: 'Soy Pasajero',
                subtitle:
                    'Solicita viajes, propone tu precio y elige al conductor ideal.',
                bullets: const [
                  'Ofrece el precio que quieras pagar',
                  'Recibe ofertas y contraofertas',
                  'Califica cada viaje',
                ],
                onTap: () => context.push(Routes.registerPassenger),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.directions_car_filled_rounded,
                color: AppColors.accent,
                title: 'Soy Conductor',
                subtitle:
                    'Recibe solicitudes cercanas y genera ingresos sin comisiones.',
                bullets: const [
                  'Sin comisiones (0%)',
                  'Acepta o envía tu contraoferta',
                  'Tú decides cuándo conectarte',
                ],
                onTap: () => context.push(Routes.registerDriver),
              ).animate().fadeIn(delay: 120.ms, duration: 400.ms).slideY(begin: 0.15),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go(Routes.login),
                  child: const Text('Ya tengo una cuenta · Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      elevated: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: color, size: 22),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                ),
                const SizedBox(height: 14),
                ...bullets.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(b,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

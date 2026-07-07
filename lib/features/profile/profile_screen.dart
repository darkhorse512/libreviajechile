import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres cerrar tu sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final themeMode = ref.watch(themeControllerProvider);
    final isDriver = user.role == UserRole.driver;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
      children: [
        Text('Perfil', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SurfaceCard(
          elevated: true,
          child: Column(
            children: [
              UserAvatar(name: user.fullName, imageUrl: user.avatarUrl, size: 84),
              const SizedBox(height: 14),
              Text(user.fullName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.palette.textSecondary,
                      )),
              const SizedBox(height: 10),
              InfoPill(
                label: user.role.label,
                icon: isDriver
                    ? Icons.directions_car_rounded
                    : Icons.person_rounded,
                color: isDriver ? AppColors.accent : AppColors.brand,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Stat(
                    value: user.hasRatings
                        ? user.ratingAvg.toStringAsFixed(1)
                        : '—',
                    label: 'Calificación',
                    icon: Icons.star_rounded,
                    color: AppColors.star,
                  ),
                  _divider(context),
                  _Stat(
                    value: '${user.tripsCount}',
                    label: 'Viajes',
                    icon: Icons.route_rounded,
                    color: AppColors.brand,
                  ),
                  _divider(context),
                  _Stat(
                    value: '${user.ratingCount}',
                    label: 'Reseñas',
                    icon: Icons.reviews_rounded,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isDriver && user.vehicle != null) ...[
          const SizedBox(height: 20),
          const _SectionLabel('Mi vehículo'),
          SurfaceCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.directions_car_filled_rounded,
                      color: AppColors.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.vehicle!.displayName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                          '${user.vehicle!.year} · ${user.vehicle!.color} · ${user.vehicle!.plate}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.palette.textSecondary,
                              )),
                    ],
                  ),
                ),
                if (user.isVerified)
                  const Icon(Icons.verified_rounded, color: AppColors.brand),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const _SectionLabel('Apariencia'),
        SurfaceCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _ThemeOption(
                mode: ThemeMode.system,
                current: themeMode,
                icon: Icons.brightness_auto_rounded,
                label: 'Automático (sistema)',
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.system),
              ),
              _ThemeOption(
                mode: ThemeMode.light,
                current: themeMode,
                icon: Icons.light_mode_rounded,
                label: 'Claro',
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.light),
              ),
              _ThemeOption(
                mode: ThemeMode.dark,
                current: themeMode,
                icon: Icons.dark_mode_rounded,
                label: 'Oscuro',
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.dark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Cuenta'),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _MenuTile(
                icon: Icons.edit_outlined,
                label: 'Editar perfil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user)),
                ),
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                label: 'Ayuda y soporte',
                onTap: () => AppFeedback.info(context, 'Disponible próximamente'),
              ),
              _MenuTile(
                icon: Icons.shield_outlined,
                label: 'Privacidad y términos',
                onTap: () => AppFeedback.info(context, 'Disponible próximamente'),
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                label: 'Cerrar sesión',
                color: AppColors.danger,
                onTap: () => _signOut(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text('Libre Viaje Chile · v0.1.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.palette.textMuted,
                  )),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: context.palette.border,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.palette.textMuted,
                  )),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final ThemeMode mode;
  final ThemeMode current;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected ? AppColors.brand : context.palette.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        )),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.brand, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? context.palette.textSecondary),
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: context.palette.textMuted),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.palette.textMuted,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              )),
    );
  }
}

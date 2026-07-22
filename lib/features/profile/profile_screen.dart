import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/app_language.dart';
import '../../core/i18n/i18n.dart';
import '../../core/i18n/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../shared/widgets/language_picker.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../legal/driver_terms_screen.dart';
import '../legal/privacy_screen.dart';
import '../legal/support_screen.dart';
import '../legal/terms_screen.dart';
import '../safety/emergency_screen.dart';
import 'edit_profile_screen.dart';
import 'ratings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('Cerrar sesión')),
        content: Text(context.tr('¿Quieres cerrar tu sesión?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Cerrar sesión')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    if (ref.read(isDemoModeProvider)) {
      AppFeedback.info(
          context, context.tr('No disponible en el modo demostración.'));
      return;
    }
    // 1) Confirmación destructiva explícita.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.danger, size: 34),
        title: Text(context.tr('Eliminar cuenta')),
        content: Text(
          context.tr(
              'Esta acción es permanente. Se eliminarán tu perfil, tu historial de viajes y todos tus datos. No podrás deshacerla.'),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('Cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('Eliminar cuenta')),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // 2) Progreso bloqueante mientras se elimina.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      // El stream de auth emite null → el router redirige al inicio de sesión.
    } catch (_) {
      if (context.mounted) {
        Navigator.pop(context); // cierra el progreso
        AppFeedback.error(
            context,
            context.tr(
                'No se pudo eliminar la cuenta. Intenta nuevamente.'));
      }
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
    // Rating/reseñas frescos (se actualizan cuando alguien te califica).
    final stats = ref.watch(userProfileProvider(user.id)).valueOrNull ?? user;
    ref.watch(localeControllerProvider); // reconstruye al cambiar idioma
    final language = ref.read(localeControllerProvider.notifier).selected;
    final languageLabel =
        language?.nativeName ?? context.tr('Automático (dispositivo)');

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
      children: [
        Text(context.tr('Perfil'),
            style: Theme.of(context).textTheme.headlineSmall),
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
                label: context.tr(user.role.label),
                icon: isDriver
                    ? Icons.directions_car_rounded
                    : Icons.person_rounded,
                color: isDriver ? AppColors.accent : AppColors.brand,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Stat(
                    value: stats.hasRatings
                        ? stats.ratingAvg.toStringAsFixed(1)
                        : '—',
                    label: context.tr('Calificación'),
                    icon: Icons.star_rounded,
                    color: AppColors.star,
                  ),
                  _divider(context),
                  _Stat(
                    value: '${stats.tripsCount}',
                    label: context.tr('Viajes'),
                    icon: Icons.route_rounded,
                    color: AppColors.brand,
                  ),
                  _divider(context),
                  _Stat(
                    value: '${stats.ratingCount}',
                    label: context.tr('Reseñas'),
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
          _SectionLabel(context.tr('Mi vehículo')),
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
        _SectionLabel(context.tr('Apariencia')),
        SurfaceCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _ThemeOption(
                mode: ThemeMode.system,
                current: themeMode,
                icon: Icons.brightness_auto_rounded,
                label: context.tr('Automático (sistema)'),
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.system),
              ),
              _ThemeOption(
                mode: ThemeMode.light,
                current: themeMode,
                icon: Icons.light_mode_rounded,
                label: context.tr('Claro'),
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.light),
              ),
              _ThemeOption(
                mode: ThemeMode.dark,
                current: themeMode,
                icon: Icons.dark_mode_rounded,
                label: context.tr('Oscuro'),
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .set(ThemeMode.dark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel(context.tr('Idioma')),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            onTap: () => showLanguagePicker(context),
            leading: Text(
              language?.flag ?? '🌐',
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(context.tr('Idioma'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(languageLabel),
            trailing: Icon(Icons.chevron_right_rounded,
                color: context.palette.textMuted),
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel(context.tr('Cuenta')),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              _MenuTile(
                icon: Icons.edit_outlined,
                label: context.tr('Editar perfil'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user)),
                ),
              ),
              _MenuTile(
                icon: Icons.star_outline_rounded,
                label: context.tr('Mis calificaciones'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RatingsScreen()),
                ),
              ),
              _MenuTile(
                icon: Icons.emergency_rounded,
                label: context.tr('Números de emergencia'),
                color: AppColors.danger,
                onTap: () => EmergencyScreen.show(context),
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                label: context.tr('Ayuda y soporte'),
                onTap: () => SupportScreen.show(context),
              ),
              _MenuTile(
                icon: Icons.shield_outlined,
                label: context.tr('Términos y Condiciones'),
                onTap: () => TermsScreen.show(context),
              ),
              _MenuTile(
                icon: Icons.privacy_tip_outlined,
                label: context.tr('Política de Privacidad'),
                onTap: () => PrivacyScreen.show(context),
              ),
              if (isDriver)
                _MenuTile(
                  icon: Icons.assignment_ind_outlined,
                  label: context.tr('Condiciones para conductores'),
                  onTap: () => DriverTermsScreen.show(context),
                ),
              _MenuTile(
                icon: Icons.logout_rounded,
                label: context.tr('Cerrar sesión'),
                color: AppColors.danger,
                onTap: () => _signOut(context, ref),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SectionLabel(context.tr('Zona de peligro')),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _MenuTile(
            icon: Icons.delete_forever_rounded,
            label: context.tr('Eliminar cuenta'),
            color: AppColors.danger,
            onTap: () => _deleteAccount(context, ref),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text('EligeDrive · v${AppConfig.appVersion}',
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

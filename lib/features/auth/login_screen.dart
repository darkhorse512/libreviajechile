import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/brand_background.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';
import 'demo_quick_access.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authFormControllerProvider.notifier)
        .signIn(_email.text.trim(), _password.text);
    // La redirección la maneja el router al cambiar el estado de sesión.
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Recuperar contraseña')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr(
                'Te enviaremos un enlace a tu correo para restablecer tu contraseña.')),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'tucorreo@ejemplo.cl',
                prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('Cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(context.tr('Enviar')),
          ),
        ],
      ),
    );
    if (email == null || email.isEmpty) return;
    try {
      await ref.read(authRepositoryProvider).resetPassword(email: email);
      if (mounted) {
        AppFeedback.success(context,
            context.tr('Te enviamos un correo para recuperar tu contraseña.'));
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context,
            context.tr('No se pudo enviar el correo de recuperación.'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormControllerProvider);
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      appBar: AppBar(actions: const [AppTopControls(), SizedBox(width: 4)]),
      body: BrandBackground(
        intensity: 0.7,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const AppLogoMark(size: 64),
                  const SizedBox(height: 24),
                  Text(context.tr('Hola de nuevo 👋'),
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('Ingresa para continuar tu viaje.'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: context.tr('Correo electrónico'),
                    hint: 'tucorreo@ejemplo.cl',
                    controller: _email,
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: context.tr('Contraseña'),
                    hint: '••••••••',
                    controller: _password,
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.password,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(context.tr('¿Olvidaste tu contraseña?')),
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorBanner(message: state.error!),
                  ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: context.tr('Ingresar'),
                    loading: state.loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(context.tr('¿No tienes cuenta?'),
                            style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.go(Routes.roleSelection),
                          child: Text(context.tr('Regístrate')),
                        ),
                      ],
                    ),
                  ),
                  if (isDemo) const DemoQuickAccess(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

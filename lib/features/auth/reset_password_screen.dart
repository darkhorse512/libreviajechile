import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/otp_boxes.dart';
import '../../shared/widgets/primary_button.dart';

/// Flujo de recuperación de contraseña:
///  Paso 1: ingresar el código de {n} dígitos enviado al correo.
///  Paso 2: definir la nueva contraseña.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0 = código, 1 = nueva contraseña
  bool _loading = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _codeFocus.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _codeFocus.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 45);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else if (mounted) {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_code.text.length < AppConfig.otpLength) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).verifyRecoveryOtp(
            email: widget.email,
            token: _code.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _step = 1; // código correcto → nueva contraseña
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _code.clear();
      });
      _codeFocus.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    try {
      await ref.read(authRepositoryProvider).resetPassword(email: widget.email);
      if (mounted) {
        AppFeedback.success(context, context.tr('Te enviamos un nuevo código'));
        _startCooldown();
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.tr('No se pudo reenviar el código'));
      }
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (!mounted) return;
      AppFeedback.success(
          context, context.tr('Tu contraseña se actualizó correctamente.'));
      // Ya autenticado con la sesión de recuperación → ir a su inicio.
      final user = ref.read(currentUserProvider);
      final home = user?.role == UserRole.driver
          ? Routes.driverHome
          : Routes.passengerHome;
      context.go(user != null ? home : Routes.login);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [AppTopControls(), SizedBox(width: 4)]),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 8, AppSpacing.xl, AppSpacing.xl),
          child: _step == 0 ? _buildCodeStep(context) : _buildPasswordStep(context),
        ),
      ),
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          icon: Icons.lock_reset_rounded,
          title: context.tr('Recupera tu contraseña'),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: context.palette.textSecondary),
            children: [
              TextSpan(
                  text: context.trp(
                      'Ingresa el código de {n} dígitos que enviamos a\n',
                      {'n': '${AppConfig.otpLength}'})),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.brand),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        OtpBoxes(
          controller: _code,
          focusNode: _codeFocus,
          hasError: _error != null,
          onChanged: (v) {
            if (_error != null) setState(() => _error = null);
            setState(() {});
            if (v.length == AppConfig.otpLength) _verifyCode();
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _ErrorRow(message: _error!),
        ],
        const SizedBox(height: 32),
        PrimaryButton(
          label: context.tr('Verificar y continuar'),
          loading: _loading,
          onPressed:
              _code.text.length == AppConfig.otpLength ? _verifyCode : null,
        ),
        const SizedBox(height: 20),
        Center(
          child: _cooldown > 0
              ? Text(
                  context.trp(
                      'Puedes reenviar el código en {n} s', {'n': '$_cooldown'}),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.palette.textMuted),
                )
              : TextButton.icon(
                  onPressed: _resend,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(context.tr('Reenviar código')),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            icon: Icons.password_rounded,
            title: context.tr('Nueva contraseña'),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Crea una contraseña nueva para tu cuenta.'),
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: context.palette.textSecondary),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: context.tr('Nueva contraseña'),
            hint: context.tr('Mínimo 6 caracteres'),
            controller: _password,
            icon: Icons.lock_outline_rounded,
            obscure: true,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.length < 6)
                ? context.tr('Mínimo 6 caracteres')
                : null,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: context.tr('Repite la contraseña'),
            hint: '••••••••',
            controller: _confirm,
            icon: Icons.lock_outline_rounded,
            obscure: true,
            textInputAction: TextInputAction.done,
            validator: (v) =>
                v != _password.text ? context.tr('Las contraseñas no coinciden') : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _ErrorRow(message: _error!),
          ],
          const SizedBox(height: 28),
          PrimaryButton(
            label: context.tr('Guardar contraseña'),
            loading: _loading,
            onPressed: _savePassword,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.brand.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(icon, color: AppColors.brand, size: 34),
        ),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.danger, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.danger)),
        ),
      ],
    );
  }
}

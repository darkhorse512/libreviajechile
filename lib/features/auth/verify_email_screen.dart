import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/otp_boxes.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';

/// Pantalla de verificación: el usuario ingresa el código de 6 dígitos que
/// recibió por correo tras registrarse.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
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

  Future<void> _verify() async {
    if (_code.text.length < AppConfig.otpLength) return;
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(authFormControllerProvider.notifier)
        .verifyEmailOtp(widget.email, _code.text.trim());
    // Si es correcto, el router redirige automáticamente al iniciar sesión.
    if (!ok && mounted) {
      _code.clear();
      _focus.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    final ok =
        await ref.read(authFormControllerProvider.notifier).resendOtp(widget.email);
    if (!mounted) return;
    if (ok) {
      AppFeedback.success(context, context.tr('Te enviamos un nuevo código'));
      _startCooldown();
    } else {
      AppFeedback.error(context, context.tr('No se pudo reenviar el código'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormControllerProvider);
    return Scaffold(
      appBar: AppBar(actions: const [AppTopControls(), SizedBox(width: 4)]),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 8, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    color: AppColors.brand, size: 34),
              ),
              const SizedBox(height: 20),
              Text(context.tr('Verifica tu correo'),
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.palette.textSecondary,
                      ),
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
                length: AppConfig.otpLength,
                controller: _code,
                focusNode: _focus,
                hasError: state.error != null,
                onChanged: (v) {
                  if (state.error != null) {
                    ref.read(authFormControllerProvider.notifier).clearError();
                  }
                  setState(() {});
                  if (v.length == AppConfig.otpLength) _verify();
                },
              ),
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.error!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.danger)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                label: context.tr('Verificar y continuar'),
                loading: state.loading,
                onPressed:
                    _code.text.length == AppConfig.otpLength ? _verify : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: _cooldown > 0
                    ? Text(
                        context.trp('Puedes reenviar el código en {n} s',
                            {'n': '$_cooldown'}),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.palette.textMuted,
                            ),
                      )
                    : TextButton.icon(
                        onPressed: _resend,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(context.tr('Reenviar código')),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_feedback.dart';
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
      AppFeedback.success(context, 'Te enviamos un nuevo código');
      _startCooldown();
    } else {
      AppFeedback.error(context, 'No se pudo reenviar el código');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormControllerProvider);
    return Scaffold(
      appBar: AppBar(),
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
              Text('Verifica tu correo',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                  children: [
                    const TextSpan(
                        text: 'Ingresa el código de ${AppConfig.otpLength} '
                            'dígitos que enviamos a\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.brand),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _OtpBoxes(
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
                label: 'Verificar y continuar',
                loading: state.loading,
                onPressed:
                    _code.text.length == AppConfig.otpLength ? _verify : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: _cooldown > 0
                    ? Text(
                        'Puedes reenviar el código en $_cooldown s',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.palette.textMuted,
                            ),
                      )
                    : TextButton.icon(
                        onPressed: _resend,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Reenviar código'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Casillas para el código (largo configurable), controladas por un único
/// campo transparente. El ancho de cada casilla se adapta al espacio disponible
/// para que siempre quepan (6, 8, etc.).
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.hasError,
    this.length = AppConfig.otpLength,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final int length;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final activeIndex = text.length.clamp(0, length - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final boxW =
            ((constraints.maxWidth - gap * (length - 1)) / length).clamp(30.0, 52.0);
        final boxH = boxW * 1.25;
        final big = boxW < 42;
        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (i) {
                final filled = i < text.length;
                final active = focusNode.hasFocus && i == activeIndex;
                return Container(
                  width: boxW,
                  height: boxH,
                  margin: EdgeInsets.only(right: i == length - 1 ? 0 : gap),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: hasError
                          ? AppColors.danger
                          : active
                              ? AppColors.brand
                              : context.palette.border,
                      width: active || hasError ? 2 : 1.4,
                    ),
                  ),
                  child: Text(
                    filled ? text[i] : '',
                    style: (big
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  showCursor: false,
                  maxLength: length,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  onChanged: onChanged,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

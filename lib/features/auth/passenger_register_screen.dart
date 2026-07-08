import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_header.dart';

class PassengerRegisterScreen extends ConsumerStatefulWidget {
  const PassengerRegisterScreen({super.key});

  @override
  ConsumerState<PassengerRegisterScreen> createState() =>
      _PassengerRegisterScreenState();
}

class _PassengerRegisterScreenState
    extends ConsumerState<PassengerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      AppFeedback.error(context, 'Debes aceptar los términos y condiciones');
      return;
    }
    FocusScope.of(context).unfocus();
    final result =
        await ref.read(authFormControllerProvider.notifier).registerPassenger(
              fullName: _name.text.trim(),
              email: _email.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text,
            );
    if (result != null && result.needsVerification && mounted) {
      context.push(
          '${Routes.verifyEmail}?email=${Uri.encodeComponent(result.email)}');
    }
    // Si no requiere verificación, el router redirige al iniciar sesión.
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
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  icon: Icons.airline_seat_recline_normal_rounded,
                  color: AppColors.brand,
                  title: 'Crea tu cuenta de pasajero',
                  subtitle:
                      'Pide viajes en cualquier ciudad de Chile. Eliges el lugar al solicitar cada viaje.',
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Nombre completo',
                  hint: 'Ej: Camila Torres',
                  controller: _name,
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Correo electrónico',
                  hint: 'tucorreo@ejemplo.cl',
                  controller: _email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Teléfono',
                  hint: '+56 9 1234 5678',
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  controller: _password,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                ),
                const SizedBox(height: 8),
                _TermsCheck(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  ErrorBanner(message: state.error!),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Crear cuenta',
                  loading: state.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: const Text('Ya tengo cuenta · Ingresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheck extends StatelessWidget {
  const _TermsCheck({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: const [
                      TextSpan(text: 'Acepto los '),
                      TextSpan(
                        text: 'Términos y Condiciones',
                        style: TextStyle(
                            color: AppColors.brand, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: ' y la Política de Privacidad.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

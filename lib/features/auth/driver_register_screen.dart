import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/vehicle.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/city_picker.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_header.dart';

class DriverRegisterScreen extends ConsumerStatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  ConsumerState<DriverRegisterScreen> createState() =>
      _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends ConsumerState<DriverRegisterScreen> {
  int _step = 0;

  // Paso 1 — datos personales
  final _step1Key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String? _city;

  // Paso 2 — vehículo
  final _step2Key = GlobalKey<FormState>();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _plate = TextEditingController();
  int _seats = 4;
  bool _accepted = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _phone,
      _password,
      _make,
      _model,
      _year,
      _color,
      _plate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _continue() {
    if (!_step1Key.currentState!.validate()) return;
    if (_city == null) {
      AppFeedback.error(context, context.tr('Selecciona tu ciudad'));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (!_step2Key.currentState!.validate()) return;
    if (!_accepted) {
      AppFeedback.error(
          context, context.tr('Debes aceptar los términos y condiciones'));
      return;
    }
    FocusScope.of(context).unfocus();
    final result =
        await ref.read(authFormControllerProvider.notifier).registerDriver(
              fullName: _name.text.trim(),
              email: _email.text.trim(),
              phone: _phone.text.trim(),
              city: _city!,
              password: _password.text,
              vehicle: Vehicle(
                make: _make.text.trim(),
                model: _model.text.trim(),
                year: int.tryParse(_year.text.trim()) ?? DateTime.now().year,
                color: _color.text.trim(),
                plate: _plate.text.trim().toUpperCase(),
                seats: _seats,
              ),
            );
    if (result != null && result.needsVerification && mounted) {
      context.push(
          '${Routes.verifyEmail}?email=${Uri.encodeComponent(result.email)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFormControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(context.trp('Paso {n} de 2', {'n': '${_step + 1}'})),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _StepBar(step: _step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _step == 0
                    ? _personalStep(context)
                    : _vehicleStep(context, state.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _step == 0
                  ? PrimaryButton(
                      label: context.tr('Continuar'),
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _continue,
                    )
                  : PrimaryButton(
                      label: context.tr('Crear cuenta de conductor'),
                      loading: state.loading,
                      onPressed: _submit,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personalStep(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 8),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(
              icon: Icons.badge_outlined,
              color: AppColors.accent,
              title: context.tr('Tus datos personales'),
              subtitle:
                  context.tr('Con esto los pasajeros sabrán quién los llevará.'),
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: context.tr('Nombre completo'),
              hint: context.tr('Ej: Cristóbal Rojas'),
              controller: _name,
              icon: Icons.person_outline_rounded,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
            ),
            const SizedBox(height: 18),
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
              label: context.tr('Teléfono'),
              hint: '+56 9 1234 5678',
              controller: _phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: Validators.phone,
            ),
            const SizedBox(height: 18),
            CitySelectorField(
              label: context.tr('Ciudad donde conduces'),
              value: _city,
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: context.tr('Contraseña'),
              hint: context.tr('Mínimo 6 caracteres'),
              controller: _password,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: Validators.password,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _vehicleStep(BuildContext context, String? error) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 8),
      child: Form(
        key: _step2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(
              icon: Icons.directions_car_filled_rounded,
              color: AppColors.accent,
              title: context.tr('Datos de tu vehículo'),
              subtitle:
                  context.tr('Esta información se mostrará a los pasajeros.'),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: context.tr('Marca'),
                    hint: 'Toyota',
                    controller: _make,
                    icon: Icons.branding_watermark_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, field: context.tr('La marca')),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppTextField(
                    label: context.tr('Modelo'),
                    hint: 'Yaris',
                    controller: _model,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, field: context.tr('El modelo')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: context.tr('Año'),
                    hint: '2021',
                    controller: _year,
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    textInputAction: TextInputAction.next,
                    validator: Validators.year,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppTextField(
                    label: context.tr('Color'),
                    hint: context.tr('Blanco'),
                    controller: _color,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.required(v, field: context.tr('El color')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: context.tr('Patente'),
              hint: 'BBBB12',
              controller: _plate,
              icon: Icons.pin_outlined,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                UpperCaseFormatter(),
                LengthLimitingTextInputFormatter(6),
              ],
              validator: Validators.plate,
            ),
            const SizedBox(height: 22),
            Text(context.tr('Capacidad de pasajeros'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.palette.textSecondary,
                    )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                for (final n in [1, 2, 3, 4, 5, 6])
                  ChoiceChip(
                    label: Text('$n'),
                    selected: _seats == n,
                    onSelected: (_) => setState(() => _seats = n),
                    labelStyle: TextStyle(
                      color: _seats == n ? AppColors.onBrand : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _TermsRow(
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(message: error),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 4, AppSpacing.xl, 12),
      child: Row(
        children: [
          for (var i = 0; i < 2; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.accent : context.palette.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            if (i == 0) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                        text: context.tr(
                            'Confirmo que mis datos son verídicos y acepto los ')),
                    TextSpan(
                      text: context.tr('Términos del Conductor'),
                      style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Convierte la entrada a mayúsculas (patente).
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

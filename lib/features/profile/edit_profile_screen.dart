import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/app_user.dart';
import '../../data/models/vehicle.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/city_picker.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/primary_button.dart';
import '../auth/driver_register_screen.dart' show UpperCaseFormatter;

/// Edición del perfil del usuario (datos personales y, si es conductor, vehículo).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final AppUser user;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.fullName);
  late final _phone = TextEditingController(text: widget.user.phone ?? '');
  late String? _city = widget.user.city;

  // Vehículo (solo conductor)
  late final _make = TextEditingController(text: widget.user.vehicle?.make ?? '');
  late final _model = TextEditingController(text: widget.user.vehicle?.model ?? '');
  late final _year =
      TextEditingController(text: widget.user.vehicle?.year.toString() ?? '');
  late final _color = TextEditingController(text: widget.user.vehicle?.color ?? '');
  late final _plate = TextEditingController(text: widget.user.vehicle?.plate ?? '');
  late int _seats = widget.user.vehicle?.seats ?? 4;

  bool _saving = false;
  String? _error;

  bool get _isDriver => widget.user.isDriver;

  @override
  void dispose() {
    for (final c in [_name, _phone, _make, _model, _year, _color, _plate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_city == null) {
      AppFeedback.error(context, context.tr('Selecciona tu ciudad'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      Vehicle? vehicle;
      if (_isDriver) {
        vehicle = (widget.user.vehicle ??
                const Vehicle(
                    make: '', model: '', year: 2020, color: '', plate: ''))
            .copyWith(
          make: _make.text.trim(),
          model: _model.text.trim(),
          year: int.tryParse(_year.text.trim()) ?? DateTime.now().year,
          color: _color.text.trim(),
          plate: _plate.text.trim().toUpperCase(),
          seats: _seats,
        );
      }
      final updated = widget.user.copyWith(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        city: _city,
        vehicle: vehicle,
      );
      final saved = await ref.read(authRepositoryProvider).updateProfile(updated);
      ref.read(currentUserProvider.notifier).update(saved);
      if (mounted) {
        AppFeedback.success(context, context.tr('Perfil actualizado'));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = context.tr('No se pudo guardar. Intenta nuevamente.');
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Editar perfil'))),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 8, AppSpacing.xl, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Datos personales'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: context.tr('Nombre completo'),
                        controller: _name,
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: context.tr('Teléfono'),
                        controller: _phone,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),
                      CitySelectorField(
                        value: _city,
                        onChanged: (v) => setState(() => _city = v),
                      ),
                      if (_isDriver) ...[
                        const SizedBox(height: 28),
                        Text(context.tr('Vehículo'),
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: context.tr('Marca'),
                                controller: _make,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => Validators.required(v,
                                    field: context.tr('La marca')),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: AppTextField(
                                label: context.tr('Modelo'),
                                controller: _model,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => Validators.required(v,
                                    field: context.tr('El modelo')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: context.tr('Año'),
                                controller: _year,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: Validators.year,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: AppTextField(
                                label: context.tr('Color'),
                                controller: _color,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => Validators.required(v,
                                    field: context.tr('El color')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: context.tr('Patente'),
                          controller: _plate,
                          icon: Icons.pin_outlined,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseFormatter(),
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: Validators.plate,
                        ),
                        const SizedBox(height: 18),
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
                                  color: _seats == n ? Colors.white : null,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        ErrorBanner(message: _error!),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: context.palette.border)),
              ),
              child: PrimaryButton(
                label: context.tr('Guardar cambios'),
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

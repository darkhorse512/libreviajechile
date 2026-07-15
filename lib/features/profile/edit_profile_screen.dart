import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/image_upload_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/app_user.dart';
import '../../data/models/vehicle.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/city_picker.dart';
import '../../shared/widgets/error_banner.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/user_avatar.dart';
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

  late String? _avatarUrl = widget.user.avatarUrl;
  late final List<String> _carPhotos =
      List.of(widget.user.vehicle?.carPhotos ?? const <String>[]);
  bool _uploadingAvatar = false;
  bool _uploadingCar = false;

  bool _saving = false;
  String? _error;

  bool get _isDriver => widget.user.isDriver;

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(context.tr('Tomar foto')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(context.tr('Elegir de la galería')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pick(String kind) async {
    if (ref.read(isDemoModeProvider)) {
      AppFeedback.info(
          context, context.tr('Subir fotos requiere una cuenta real.'));
      return null;
    }
    final source = await _chooseSource();
    if (source == null) return null;
    try {
      return await ImageUploadService.pickAndUpload(kind: kind, source: source);
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.tr('No se pudo subir la imagen.'));
      }
      return null;
    }
  }

  Future<void> _changeAvatar() async {
    setState(() => _uploadingAvatar = true);
    final url = await _pick('avatar');
    if (!mounted) return;
    setState(() {
      if (url != null) _avatarUrl = url;
      _uploadingAvatar = false;
    });
  }

  Future<void> _addCarPhoto() async {
    if (_carPhotos.length >= 6) {
      AppFeedback.info(context, context.tr('Máximo 6 fotos del auto.'));
      return;
    }
    setState(() => _uploadingCar = true);
    final url = await _pick('car');
    if (!mounted) return;
    setState(() {
      if (url != null) _carPhotos.add(url);
      _uploadingCar = false;
    });
  }

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
          carPhotos: _carPhotos,
        );
      }
      final updated = widget.user.copyWith(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        city: _city,
        avatarUrl: _avatarUrl,
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
      appBar: AppBar(
        title: Text(context.tr('Editar perfil')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
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
                      Center(
                        child: GestureDetector(
                          onTap: _uploadingAvatar ? null : _changeAvatar,
                          child: Stack(
                            children: [
                              UserAvatar(
                                name: _name.text.isEmpty
                                    ? widget.user.fullName
                                    : _name.text,
                                imageUrl: _avatarUrl,
                                size: 96,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        width: 2.5),
                                  ),
                                  child: Icon(
                                    _uploadingAvatar
                                        ? Icons.hourglass_top_rounded
                                        : Icons.photo_camera_rounded,
                                    color: AppColors.onBrand,
                                    size: 16,
                                  ),
                                ),
                              ),
                              if (_uploadingAvatar)
                                const Positioned.fill(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black38,
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                                  color: _seats == n ? AppColors.onBrand : null,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Text(context.tr('Fotos del auto'),
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('Ayuda al pasajero a reconocer tu auto.'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.palette.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final url in _carPhotos)
                              _CarPhotoThumb(
                                url: url,
                                onRemove: () =>
                                    setState(() => _carPhotos.remove(url)),
                              ),
                            _AddPhotoTile(
                              loading: _uploadingCar,
                              onTap: _uploadingCar ? null : _addCarPhoto,
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

/// Miniatura de una foto del auto con botón para quitarla.
class _CarPhotoThumb extends StatelessWidget {
  const _CarPhotoThumb({required this.url, required this.onRemove});
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            url,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 92,
              height: 92,
              color: context.palette.border,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón para agregar una foto del auto.
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.palette.border, width: 1.5),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(Icons.add_a_photo_outlined,
                  color: context.palette.textSecondary),
        ),
      ),
    );
  }
}

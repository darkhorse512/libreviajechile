import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/image_upload_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/primary_button.dart';

/// Tipo de documento requerido para verificar a un conductor.
enum DriverDocType {
  driverPhoto,
  license,
  vehicleReg,
  antecedentes,
  soap,
  carFront,
  carBack,
}

extension DriverDocSpec on DriverDocType {
  /// Columna en `driver_details`.
  String get column => switch (this) {
        DriverDocType.driverPhoto => 'doc_driver_photo',
        DriverDocType.license => 'doc_license',
        DriverDocType.vehicleReg => 'doc_vehicle_reg',
        DriverDocType.antecedentes => 'doc_antecedentes',
        DriverDocType.soap => 'doc_soap',
        DriverDocType.carFront => 'doc_car_front',
        DriverDocType.carBack => 'doc_car_back',
      };

  /// `kind` que recibe la Edge Function (define la carpeta en R2). La foto del
  /// conductor va a avatars/; el resto a docs/.
  String get kind => switch (this) {
        DriverDocType.driverPhoto => 'avatar',
        _ => column,
      };

  /// La foto del conductor también se usa como avatar visible al pasajero.
  bool get isDriverPhoto => this == DriverDocType.driverPhoto;

  IconData get icon => switch (this) {
        DriverDocType.driverPhoto => Icons.person_rounded,
        DriverDocType.license => Icons.badge_rounded,
        DriverDocType.vehicleReg => Icons.description_rounded,
        DriverDocType.antecedentes => Icons.fact_check_rounded,
        DriverDocType.soap => Icons.health_and_safety_rounded,
        DriverDocType.carFront => Icons.directions_car_rounded,
        DriverDocType.carBack => Icons.time_to_leave_rounded,
      };

  String get title => switch (this) {
        DriverDocType.driverPhoto => 'Foto del conductor',
        DriverDocType.license => 'Licencia de conducir',
        DriverDocType.vehicleReg => 'Permiso de circulación',
        DriverDocType.antecedentes => 'Certificado de antecedentes',
        DriverDocType.soap => 'Seguro Obligatorio (SOAP)',
        DriverDocType.carFront => 'Foto del auto — parte delantera',
        DriverDocType.carBack => 'Foto del auto — parte trasera',
      };

  /// Instrucciones (cada una es un ítem con check), como en el ejemplo.
  List<String> get instructions => switch (this) {
        DriverDocType.driverPhoto => [
            'Sube una foto tuya de frente, con buena iluminación y sin lentes de sol ni gorro.',
            'Esta será la foto que verán los pasajeros cuando aceptes sus viajes.',
          ],
        DriverDocType.license => [
            'Sube una foto de tu licencia de conducir vigente.',
            'Todos los datos deben verse completos y legibles.',
          ],
        DriverDocType.vehicleReg => [
            'Sube la foto del permiso de circulación donde se vea la placa, año y modelo del vehículo.',
            'El permiso de circulación debe estar vigente.',
          ],
        DriverDocType.antecedentes => [
            'Sube tu certificado de antecedentes vigente.',
            'Puede ser una imagen o un archivo PDF.',
          ],
        DriverDocType.soap => [
            'Sube tu Seguro Obligatorio de Accidentes Personales (SOAP) vigente.',
            'Deben verse la patente y la fecha de vencimiento.',
          ],
        DriverDocType.carFront => [
            'Toma una foto del auto desde el frente. Asegúrate de que el auto se vea por completo y que la placa sea fácil de leer.',
          ],
        DriverDocType.carBack => [
            'Toma una foto del auto desde atrás. Asegúrate de que el auto se vea por completo y que la placa sea fácil de leer.',
          ],
      };

  String existingUrl(AppUser user) => switch (this) {
        DriverDocType.driverPhoto => user.vehicle?.docDriverPhoto ?? '',
        DriverDocType.license => user.vehicle?.docLicense ?? '',
        DriverDocType.vehicleReg => user.vehicle?.docVehicleReg ?? '',
        DriverDocType.antecedentes => user.vehicle?.docAntecedentes ?? '',
        DriverDocType.soap => user.vehicle?.docSoap ?? '',
        DriverDocType.carFront => user.vehicle?.docCarFront ?? '',
        DriverDocType.carBack => user.vehicle?.docCarBack ?? '',
      };
}

/// Pantalla mostrada al conductor mientras NO está aprobado: le pide subir sus
/// documentos y, una vez enviados, muestra el estado de revisión.
class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key, required this.user});
  final AppUser user;

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  final Map<DriverDocType, PickedFileData> _captured = {};
  bool _submitting = false;
  bool _refreshing = false;
  String? _error;

  bool _isDone(AppUser user, DriverDocType t) =>
      _captured.containsKey(t) || t.existingUrl(user).isNotEmpty;

  Future<void> _capture(DriverDocType type) async {
    if (ref.read(isDemoModeProvider)) {
      AppFeedback.info(
          context, context.tr('Subir documentos requiere una cuenta real.'));
      return;
    }
    final result = await Navigator.of(context).push<PickedFileData>(
      MaterialPageRoute(builder: (_) => _DocumentCaptureScreen(type: type)),
    );
    if (result != null && mounted) {
      setState(() => _captured[type] = result);
    }
  }

  Future<void> _submit(AppUser user) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    // Etapa actual, para dar un mensaje de error preciso.
    String stage = 'preparación';
    try {
      final docs = <String, String>{};
      for (final type in DriverDocType.values) {
        final captured = _captured[type];
        if (captured != null) {
          stage = 'subida de "${context.tr(type.title)}"';
          docs[type.column] = await ImageUploadService.uploadBytes(
            bytes: captured.bytes,
            contentType: captured.contentType,
            kind: type.kind,
          );
        } else {
          docs[type.column] = type.existingUrl(user); // reutiliza el existente
        }
      }
      stage = 'guardado en la base de datos';
      // La foto del conductor se usa también como avatar visible al pasajero.
      final avatarUrl = docs[DriverDocType.driverPhoto.column];
      final updated = await ref
          .read(authRepositoryProvider)
          .setDriverDocuments(user.id, docs, avatarUrl: avatarUrl);
      _captured.clear(); // ya subidos: pasa a la pantalla "en revisión"
      ref.read(currentUserProvider.notifier).update(updated);
      if (mounted) {
        AppFeedback.success(
            context, context.tr('¡Documentos enviados! Te avisaremos al aprobar.'));
      }
    } catch (e) {
      debugPrint('Driver docs submit failed at [$stage]: $e');
      if (mounted) {
        setState(() => _error = 'Falló en: $stage.\n$e');
        AppFeedback.error(
            context, context.tr('No se pudieron enviar los documentos.'));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _refreshStatus() async {
    setState(() => _refreshing = true);
    final updated = await ref.read(authRepositoryProvider).reloadUser();
    if (!mounted) return;
    if (updated != null) ref.read(currentUserProvider.notifier).update(updated);
    setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? widget.user;

    // Enviado y a la espera de revisión (y no rechazado).
    if (user.hasSubmittedDocuments &&
        user.verificationStatus.isPending &&
        _captured.isEmpty) {
      return _PendingReview(
          refreshing: _refreshing, onRefresh: _refreshStatus);
    }

    final allDone =
        DriverDocType.values.every((t) => _isDone(user, t));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
      children: [
        if (user.verificationStatus.isRejected) _RejectedBanner(user: user),
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: AppColors.brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('Verifica tu cuenta'),
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(
                    context.tr(
                        'Sube estos documentos para empezar a recibir viajes.'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final type in DriverDocType.values) ...[
          _DocTile(
            type: type,
            done: _isDone(user, type),
            captured: _captured[type],
            onTap: () => _capture(type),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.danger,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        PrimaryButton(
          label: context.tr('Enviar para revisión'),
          icon: Icons.send_rounded,
          loading: _submitting,
          onPressed: allDone ? () => _submit(user) : null,
        ),
        const SizedBox(height: 10),
        Text(
          context.tr(
              'Revisaremos tus documentos y activaremos tu cuenta lo antes posible.'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.palette.textMuted,
              ),
        ),
      ],
    );
  }
}

/// Fila-resumen de un documento en el checklist.
class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.type,
    required this.done,
    required this.captured,
    required this.onTap,
  });

  final DriverDocType type;
  final bool done;
  final PickedFileData? captured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: done
                ? AppColors.success.withValues(alpha: 0.6)
                : context.palette.border,
            width: done ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (done ? AppColors.success : AppColors.accent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(type.icon,
                  color: done ? AppColors.success : AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(type.title),
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    done
                        ? (captured?.fileName != null && captured!.isPdf
                            ? context.tr('PDF cargado')
                            : context.tr('Cargado'))
                        : context.tr('Toca para subir'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: done
                              ? AppColors.success
                              : context.palette.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              done ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: done ? AppColors.success : context.palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso de rechazo con el motivo indicado por el administrador.
class _RejectedBanner extends StatelessWidget {
  const _RejectedBanner({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Tu verificación fue rechazada'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.danger,
                        )),
                const SizedBox(height: 2),
                Text(
                  user.rejectionReason?.isNotEmpty == true
                      ? user.rejectionReason!
                      : context.tr(
                          'Vuelve a subir tus documentos con buena iluminación y legibles.'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado "en revisión": documentos enviados, esperando aprobación del admin.
class _PendingReview extends StatelessWidget {
  const _PendingReview({required this.refreshing, required this.onRefresh});
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.accent, size: 46),
            ),
            const SizedBox(height: 22),
            Text(context.tr('Tu cuenta está en revisión'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              context.tr(
                  'Recibimos tus documentos. Un administrador revisará tu cuenta y te avisaremos cuando puedas empezar a recibir viajes.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: refreshing ? null : onRefresh,
              icon: refreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.tr('Actualizar estado')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla a pantalla completa para capturar UN documento (estilo del ejemplo).
class _DocumentCaptureScreen extends StatefulWidget {
  const _DocumentCaptureScreen({required this.type});
  final DriverDocType type;

  @override
  State<_DocumentCaptureScreen> createState() => _DocumentCaptureScreenState();
}

class _DocumentCaptureScreenState extends State<_DocumentCaptureScreen> {
  PickedFileData? _preview;

  Future<void> _choose() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(context.tr('Tomar foto')),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(context.tr('Elegir de la galería')),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: Text(context.tr('Subir PDF o archivo')),
              onTap: () => Navigator.pop(context, 'file'),
            ),
          ],
        ),
      ),
    );
    if (action == null) return;
    final PickedFileData? picked = switch (action) {
      'camera' => await ImageUploadService.capturePhoto(ImageSource.camera),
      'gallery' => await ImageUploadService.capturePhoto(ImageSource.gallery),
      _ => await ImageUploadService.pickDocumentFile(),
    };
    if (picked != null && mounted) setState(() => _preview = picked);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final captured = _preview != null;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 8, AppSpacing.xl, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(type.title),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 18),
                    for (final line in type.instructions) ...[
                      _InstructionRow(text: context.tr(line)),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                    _PreviewArea(type: type, preview: _preview),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  PrimaryButton(
                    label: captured
                        ? context.tr('Usar este documento')
                        : context.tr('Tomar una foto'),
                    icon: captured
                        ? Icons.check_rounded
                        : Icons.photo_camera_rounded,
                    onPressed: captured
                        ? () => Navigator.of(context).pop(_preview)
                        : _choose,
                  ),
                  if (captured) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _choose,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(context.tr('Volver a tomar')),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_rounded, color: AppColors.brand, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                    height: 1.35,
                  )),
        ),
      ],
    );
  }
}

/// Área que muestra el documento capturado (o un marcador si aún no hay).
class _PreviewArea extends StatelessWidget {
  const _PreviewArea({required this.type, required this.preview});
  final DriverDocType type;
  final PickedFileData? preview;

  @override
  Widget build(BuildContext context) {
    final has = preview != null;
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: has
                ? AppColors.success
                : context.palette.border,
            width: has ? 3 : 1.5,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (has && !preview!.isPdf)
              Image.memory(preview!.bytes, fit: BoxFit.cover)
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      has ? Icons.picture_as_pdf_rounded : type.icon,
                      size: 46,
                      color: context.palette.textMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      has
                          ? (preview!.fileName ?? context.tr('PDF cargado'))
                          : context.tr('Sin documento'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.palette.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            if (has)
              const Positioned(
                top: 10,
                left: 10,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.success,
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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

/// Especificación de un documento requerido para verificar una cuenta.
class VerifDoc {
  const VerifDoc({
    required this.column,
    required this.kind,
    required this.icon,
    required this.title,
    required this.instructions,
  });

  /// Columna donde se guarda la URL (clave del mapa que recibe [onSubmit]).
  final String column;

  /// `kind` que recibe la Edge Function (carpeta en R2).
  final String kind;

  final IconData icon;

  /// Título en español (se traduce con context.tr).
  final String title;

  /// Instrucciones en español (se traducen con context.tr).
  final List<String> instructions;
}

/// Flujo de verificación de cuenta reutilizable (conductor o pasajero):
///  1) checklist de documentos por subir,
///  2) captura por documento (cámara / galería / PDF),
///  3) envío a revisión y pantalla "en revisión",
///  4) aviso y reintento si el administrador rechaza.
///
/// Es genérico: recibe la lista de documentos y el callback que persiste las
/// URLs. La aprobación la realiza el administrador desde el panel.
class VerificationFlow extends ConsumerStatefulWidget {
  const VerificationFlow({
    super.key,
    required this.user,
    required this.docs,
    required this.existingUrl,
    required this.onSubmit,
    required this.title,
    required this.subtitle,
    required this.pendingMessage,
    this.avatarColumn,
  });

  final AppUser user;
  final List<VerifDoc> docs;

  /// URL ya guardada de un documento (o vacío si falta).
  final String Function(AppUser user, VerifDoc doc) existingUrl;

  /// Persiste las URLs (columna → URL) y deja la cuenta en revisión.
  final Future<AppUser> Function(Map<String, String> docs, String? avatarUrl)
      onSubmit;

  /// Textos (en español; se traducen).
  final String title;
  final String subtitle;
  final String pendingMessage;

  /// Si se indica, la URL de esa columna también se usa como avatar.
  final String? avatarColumn;

  @override
  ConsumerState<VerificationFlow> createState() => _VerificationFlowState();
}

class _VerificationFlowState extends ConsumerState<VerificationFlow> {
  final Map<String, PickedFileData> _captured = {}; // por columna
  bool _submitting = false;
  bool _refreshing = false;
  String? _error;

  bool _isDone(AppUser user, VerifDoc d) =>
      _captured.containsKey(d.column) || widget.existingUrl(user, d).isNotEmpty;

  Future<void> _capture(VerifDoc doc) async {
    if (ref.read(isDemoModeProvider)) {
      AppFeedback.info(
          context, context.tr('Subir documentos requiere una cuenta real.'));
      return;
    }
    final result = await Navigator.of(context).push<PickedFileData>(
      MaterialPageRoute(builder: (_) => _CaptureScreen(doc: doc)),
    );
    if (result != null && mounted) {
      setState(() => _captured[doc.column] = result);
    }
  }

  Future<void> _submit(AppUser user) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    String stage = 'preparación';
    try {
      final docs = <String, String>{};
      for (final d in widget.docs) {
        final captured = _captured[d.column];
        if (captured != null) {
          stage = 'subida de "${context.tr(d.title)}"';
          docs[d.column] = await ImageUploadService.uploadBytes(
            bytes: captured.bytes,
            contentType: captured.contentType,
            kind: d.kind,
          );
        } else {
          docs[d.column] = widget.existingUrl(user, d);
        }
      }
      stage = 'guardado en la base de datos';
      final avatarUrl =
          widget.avatarColumn != null ? docs[widget.avatarColumn] : null;
      final updated = await widget.onSubmit(docs, avatarUrl);
      _captured.clear();
      ref.read(currentUserProvider.notifier).update(updated);
      if (mounted) {
        AppFeedback.success(context,
            context.tr('¡Documentos enviados! Te avisaremos al aprobar.'));
      }
    } catch (e) {
      debugPrint('Verification submit failed at [$stage]: $e');
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

    final allSubmitted =
        widget.docs.every((d) => widget.existingUrl(user, d).isNotEmpty);

    // Enviado y esperando revisión (y no rechazado).
    if (allSubmitted && user.verificationStatus.isPending && _captured.isEmpty) {
      return _PendingReview(
        message: widget.pendingMessage,
        refreshing: _refreshing,
        onRefresh: _refreshStatus,
      );
    }

    final allDone = widget.docs.every((d) => _isDone(user, d));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
      children: [
        if (user.verificationStatus.isRejected)
          _RejectedBanner(reason: user.rejectionReason),
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child:
                  const Icon(Icons.verified_user_rounded, color: AppColors.brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(widget.title),
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(context.tr(widget.subtitle),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.palette.textSecondary,
                          )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        for (final d in widget.docs) ...[
          _DocTile(
            doc: d,
            done: _isDone(user, d),
            captured: _captured[d.column],
            onTap: () => _capture(d),
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
                  child: SelectableText(_error!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.danger)),
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
    required this.doc,
    required this.done,
    required this.captured,
    required this.onTap,
  });

  final VerifDoc doc;
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
              child: Icon(doc.icon,
                  color: done ? AppColors.success : AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr(doc.title),
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
  const _RejectedBanner({required this.reason});
  final String? reason;

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
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.danger)),
                const SizedBox(height: 2),
                Text(
                  reason?.isNotEmpty == true
                      ? reason!
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
  const _PendingReview({
    required this.message,
    required this.refreshing,
    required this.onRefresh,
  });
  final String message;
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
            Text(context.tr(message),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    )),
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

/// Pantalla a pantalla completa para capturar UN documento.
class _CaptureScreen extends StatefulWidget {
  const _CaptureScreen({required this.doc});
  final VerifDoc doc;

  @override
  State<_CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<_CaptureScreen> {
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
    final doc = widget.doc;
    final captured = _preview != null;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(AppSpacing.xl, 8, AppSpacing.xl, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(doc.title),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 18),
                    for (final line in doc.instructions) ...[
                      _InstructionRow(text: context.tr(line)),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                    _PreviewArea(icon: doc.icon, preview: _preview),
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
                    icon:
                        captured ? Icons.check_rounded : Icons.photo_camera_rounded,
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
  const _PreviewArea({required this.icon, required this.preview});
  final IconData icon;
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
            color: has ? AppColors.success : context.palette.border,
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
                    Icon(has ? Icons.picture_as_pdf_rounded : icon,
                        size: 46, color: context.palette.textMuted),
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
                  child:
                      Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

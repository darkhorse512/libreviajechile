import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/user_avatar.dart';
import 'trip_controller.dart';

/// Hoja modal para calificar al otro participante de un viaje.
Future<bool?> showRateSheet(
  BuildContext context, {
  required String tripId,
  required String rateeId,
  required String personName,
  String? personAvatar,
  required String roleLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RateSheet(
      tripId: tripId,
      rateeId: rateeId,
      personName: personName,
      personAvatar: personAvatar,
      roleLabel: roleLabel,
    ),
  );
}

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({
    required this.tripId,
    required this.rateeId,
    required this.personName,
    required this.personAvatar,
    required this.roleLabel,
  });

  final String tripId;
  final String rateeId;
  final String personName;
  final String? personAvatar;
  final String roleLabel;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  int _stars = 5;
  final _comment = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ref.read(tripActionsProvider).rate(
            tripId: widget.tripId,
            stars: _stars,
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      // Refresca el perfil y las reseñas del calificado para que aparezcan al
      // instante en su perfil.
      ref.invalidate(userProfileProvider(widget.rateeId));
      ref.invalidate(userRatingsProvider(widget.rateeId));
      if (mounted) {
        AppFeedback.success(context, context.tr('¡Gracias por tu calificación!'));
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.tr('No se pudo guardar la calificación'));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.palette.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 24),
          UserAvatar(
              name: widget.personName, imageUrl: widget.personAvatar, size: 72),
          const SizedBox(height: 14),
          Text(context.trp('Califica a tu {role}', {'role': widget.roleLabel}),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(widget.personName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.palette.textSecondary,
                  )),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  iconSize: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  icon: Icon(
                    i <= _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.star,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            hint: context.tr('Escribe un comentario (opcional)'),
            controller: _comment,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: context.tr('Enviar calificación'),
            loading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

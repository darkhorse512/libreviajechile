import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/enums.dart';
import '../../data/models/trip.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/payment_method_widgets.dart';
import '../../shared/widgets/primary_button.dart';
import '../trips/trip_controller.dart';
import '../trips/widgets/trip_widgets.dart';

/// Hoja para que el conductor acepte el precio o envíe una contraoferta.
Future<void> showOfferSheet(BuildContext context, {required Trip trip}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _OfferSheet(trip: trip),
  );
}

class _OfferSheet extends ConsumerStatefulWidget {
  const _OfferSheet({required this.trip});
  final Trip trip;

  @override
  ConsumerState<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends ConsumerState<_OfferSheet> {
  bool _counter = false;
  late int _amount = widget.trip.offeredFare;
  int _eta = 5;
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _setMode(bool counter) {
    setState(() {
      _counter = counter;
      _amount = widget.trip.offeredFare;
    });
  }

  void _bump(int delta) {
    setState(() {
      _amount =
          (_amount + delta).clamp(AppConfig.minFareClp, AppConfig.maxFareClp);
    });
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      await ref.read(tripActionsProvider).sendOffer(
            tripId: widget.trip.id,
            amount: _amount,
            kind: _counter ? OfferKind.counter : OfferKind.accept,
            etaMinutes: _eta,
            message: _message.text.trim().isEmpty ? null : _message.text.trim(),
          );
      if (mounted) {
        AppFeedback.success(context, context.tr('Oferta enviada al pasajero'));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, context.tr('No se pudo enviar la oferta'));
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.tr('Responder solicitud'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TripRoute(
              origin: trip.originAddress,
              destination: trip.destinationAddress,
              compact: true,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('${context.tr('Método de pago')}: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        )),
                PaymentMethodChip(method: trip.paymentMethod),
              ],
            ),
            const SizedBox(height: 20),
            _ModeSwitch(counter: _counter, onChanged: _setMode, trip: trip),
            const SizedBox(height: 20),
            if (_counter) ...[
              Text(context.tr('Tu contraoferta'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  _round(Icons.remove_rounded,
                      () => _bump(-AppConfig.fareStepClp)),
                  Expanded(
                    child: Center(
                      child: Text(Formatters.clp(_amount),
                          style:
                              Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppColors.price,
                                    fontWeight: FontWeight.w800,
                                  )),
                    ),
                  ),
                  _round(Icons.add_rounded, () => _bump(AppConfig.fareStepClp)),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Text(context.tr('Tiempo estimado de llegada'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final m in [3, 5, 8, 12, 15, 20])
                  ChoiceChip(
                    label: Text(context.trp('{n} min', {'n': '$m'})),
                    selected: _eta == m,
                    onSelected: (_) => setState(() => _eta = m),
                    labelStyle: TextStyle(
                      color: _eta == m ? AppColors.onBrand : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: context.tr('Mensaje (opcional)'),
              hint: context.tr('Ej: Voy en camino, patente blanca…'),
              controller: _message,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _counter
                  ? '${context.tr('Enviar contraoferta')} · ${Formatters.clp(_amount)}'
                  : '${context.tr('Aceptar por')} ${Formatters.clp(_amount)}',
              icon: _counter ? Icons.swap_horiz_rounded : Icons.check_rounded,
              loading: _sending,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.price.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.price, size: 24),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.counter,
    required this.onChanged,
    required this.trip,
  });
  final bool counter;
  final ValueChanged<bool> onChanged;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _tab(
            context,
            selected: !counter,
            label: context.tr('Aceptar'),
            sub: Formatters.clp(trip.offeredFare),
            color: AppColors.success,
            onTap: () => onChanged(false),
          ),
          _tab(
            context,
            selected: counter,
            label: context.tr('Contraofertar'),
            sub: context.tr('Otro precio'),
            color: AppColors.price,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context, {
    required bool selected,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.surface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: context.palette.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: selected ? color : context.palette.textSecondary,
                      )),
              Text(sub,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.palette.textMuted,
                      )),
            ],
          ),
        ),
      ),
    );
  }
}

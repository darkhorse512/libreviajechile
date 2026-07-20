import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/payment_method.dart';

/// Ícono de un método de pago (imagen del asset, con esquinas redondeadas).
class PaymentMethodIcon extends StatelessWidget {
  const PaymentMethodIcon({super.key, required this.method, this.size = 28});
  final PaymentMethod method;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        method.asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: context.palette.surfaceAlt,
          child: Icon(Icons.payments_rounded,
              size: size * 0.6, color: context.palette.textMuted),
        ),
      ),
    );
  }
}

/// El nombre visible del método (traduce solo "Efectivo").
String paymentMethodLabel(BuildContext context, PaymentMethod method) =>
    method == PaymentMethod.efectivo ? context.tr('Efectivo') : method.label;

/// Chip compacto: ícono + nombre. Para mostrar el método en tarjetas de viaje.
class PaymentMethodChip extends StatelessWidget {
  const PaymentMethodChip({super.key, required this.method});
  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaymentMethodIcon(method: method, size: 20),
          const SizedBox(width: 8),
          Text(
            paymentMethodLabel(context, method),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Campo tipo selector (para la pantalla de solicitud): muestra el método
/// elegido y abre el selector al tocarlo.
class PaymentMethodField extends StatelessWidget {
  const PaymentMethodField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () async {
          final picked = await showPaymentMethodPicker(context, value);
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              PaymentMethodIcon(method: value, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Método de pago'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.palette.textMuted,
                          ),
                    ),
                    Text(
                      paymentMethodLabel(context, value),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more_rounded, color: context.palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja inferior "Métodos de pago" (como en la referencia de inDrive).
Future<PaymentMethod?> showPaymentMethodPicker(
  BuildContext context,
  PaymentMethod selected,
) {
  return showModalBottomSheet<PaymentMethod>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, 8),
            child: Text(
              ctx.tr('Métodos de pago'),
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
          ),
          for (final m in PaymentMethod.values)
            ListTile(
              leading: PaymentMethodIcon(method: m, size: 32),
              title: Text(paymentMethodLabel(ctx, m)),
              trailing: m == selected
                  ? const Icon(Icons.check_rounded, color: AppColors.brand)
                  : null,
              selected: m == selected,
              onTap: () => Navigator.pop(ctx, m),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

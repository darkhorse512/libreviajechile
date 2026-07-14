import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Casillas para un código OTP (largo configurable), controladas por un único
/// campo transparente. El ancho de cada casilla se adapta al espacio disponible.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({
    super.key,
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
        final boxW = ((constraints.maxWidth - gap * (length - 1)) / length)
            .clamp(30.0, 52.0);
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

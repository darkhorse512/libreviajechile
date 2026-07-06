import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Fondo decorativo con "blobs" de degradado suaves. Se usa en pantallas
/// de bienvenida y autenticación para dar un aire premium y moderno.
class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, required this.child, this.intensity = 1});

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _Blob(
            color: AppColors.brand.withValues(alpha: (isDark ? 0.30 : 0.22) * intensity),
            size: 320,
          ),
        ),
        Positioned(
          top: 60,
          left: -110,
          child: _Blob(
            color: AppColors.brandLight
                .withValues(alpha: (isDark ? 0.22 : 0.18) * intensity),
            size: 280,
          ),
        ),
        Positioned(
          bottom: -140,
          right: -60,
          child: _Blob(
            color: AppColors.accent
                .withValues(alpha: (isDark ? 0.16 : 0.14) * intensity),
            size: 300,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

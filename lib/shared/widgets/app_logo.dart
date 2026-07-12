import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Marca gráfica oficial (ícono de la app) desde `assets/icon.png`.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 64, this.shadow = true});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    // La marca "ed" (assets/icon.png) tiene fondo transparente: se muestra
    // completa (contain) sobre el fondo de la pantalla, con un leve resplandor.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.28),
                  blurRadius: size * 0.34,
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Logotipo horizontal oficial (marca + wordmark + eslogan) desde
/// `assets/logo.png`. Pensado para fondos claros. En fondos de color usa
/// [AppLogoMark] junto a texto propio.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.height = 44});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}

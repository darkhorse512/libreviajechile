import 'package:flutter/material.dart';

/// Paleta base de la marca "Libre Viaje Chile", derivada del logotipo oficial:
/// verde vibrante + azul marino + azul (camino/pin).
abstract class AppColors {
  AppColors._();

  // ----- Marca (verde) -----
  static const Color brand = Color(0xFF4FBE2A); // verde principal (accesible)
  static const Color brandDark = Color(0xFF3C9A1E);
  static const Color brandLight = Color(0xFF60CC30); // verde vivo del logo
  static const Color brandSoft = Color(0xFFEAF8E1);

  // Gradiente de marca (botones principales, hero, splash)
  static const List<Color> brandGradient = [Color(0xFF63CE33), Color(0xFF3FA81C)];

  // Azul marino del logo (texto "libre", detalles oscuros)
  static const Color navy = Color(0xFF002454);
  static const Color navyLight = Color(0xFF123B72);

  // ----- Secundario / acento (azul del camino y pin) -----
  static const Color accent = Color(0xFF0060C4); // azul (identidad conductor / info)
  static const Color accentDark = Color(0xFF004AA0);
  static const Color accentSoft = Color(0xFFE3EEFB);

  // ----- Estados positivos (verde) -----
  static const Color success = Color(0xFF2FA84F);
  static const Color successDark = Color(0xFF238C40);

  // ----- Semánticos -----
  static const Color price = Color(0xFFF59E0B); // ámbar (precio / oferta)
  static const Color danger = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0060C4);
  static const Color star = Color(0xFFFBBF24);

  // ----- Superficies claras -----
  static const Color lightBackground = Color(0xFFF4F7F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF2EC);
  static const Color lightBorder = Color(0xFFE1E7DD);
  static const Color lightTextPrimary = Color(0xFF0E1E14);
  static const Color lightTextSecondary = Color(0xFF566159);
  static const Color lightTextMuted = Color(0xFF8B968C);

  // ----- Superficies oscuras -----
  static const Color darkBackground = Color(0xFF0B1410);
  static const Color darkSurface = Color(0xFF14201A);
  static const Color darkSurfaceAlt = Color(0xFF1D2B23);
  static const Color darkBorder = Color(0xFF2A3B31);
  static const Color darkTextPrimary = Color(0xFFF1F6F1);
  static const Color darkTextSecondary = Color(0xFFA6B2A8);
  static const Color darkTextMuted = Color(0xFF6C7A6F);
}

/// Colores/semánticas de marca que no caben en [ColorScheme].
/// Se accede vía `Theme.of(context).extension<AppPalette>()!`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brandGradient,
    required this.accent,
    required this.success,
    required this.price,
    required this.warning,
    required this.info,
    required this.star,
    required this.surfaceAlt,
    required this.border,
    required this.textSecondary,
    required this.textMuted,
    required this.shadow,
  });

  final List<Color> brandGradient;
  final Color accent;
  final Color success;
  final Color price;
  final Color warning;
  final Color info;
  final Color star;
  final Color surfaceAlt;
  final Color border;
  final Color textSecondary;
  final Color textMuted;
  final Color shadow;

  static const light = AppPalette(
    brandGradient: AppColors.brandGradient,
    accent: AppColors.accent,
    success: AppColors.success,
    price: AppColors.price,
    warning: AppColors.warning,
    info: AppColors.info,
    star: AppColors.star,
    surfaceAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    shadow: Color(0x14123A1E),
  );

  static const dark = AppPalette(
    brandGradient: AppColors.brandGradient,
    accent: AppColors.accent,
    success: AppColors.success,
    price: AppColors.price,
    warning: AppColors.warning,
    info: AppColors.info,
    star: AppColors.star,
    surfaceAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    shadow: Color(0x66000000),
  );

  @override
  AppPalette copyWith({
    List<Color>? brandGradient,
    Color? accent,
    Color? success,
    Color? price,
    Color? warning,
    Color? info,
    Color? star,
    Color? surfaceAlt,
    Color? border,
    Color? textSecondary,
    Color? textMuted,
    Color? shadow,
  }) {
    return AppPalette(
      brandGradient: brandGradient ?? this.brandGradient,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      price: price ?? this.price,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      star: star ?? this.star,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      brandGradient: [
        Color.lerp(brandGradient.first, other.brandGradient.first, t)!,
        Color.lerp(brandGradient.last, other.brandGradient.last, t)!,
      ],
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      price: Color.lerp(price, other.price, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      star: Color.lerp(star, other.star, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Atajo para acceder a la paleta extendida desde cualquier `BuildContext`.
extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
}

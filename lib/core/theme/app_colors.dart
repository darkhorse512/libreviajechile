import 'package:flutter/material.dart';

/// Paleta base de la marca "EligeDrive", derivada del logotipo oficial:
/// verde lima eléctrico + negro + blanco (estilo nocturno).
abstract class AppColors {
  AppColors._();

  // ----- Marca (lima eléctrico del logo) -----
  static const Color brand = Color(0xFFB6E61E); // lima principal
  static const Color brandDark = Color(0xFF93C400);
  static const Color brandLight = Color(0xFFCDF25A);
  static const Color brandSoft = Color(0xFFEFF9CE); // tinte claro (tema claro)

  // Texto/íconos que van SOBRE la marca lima (debe ser oscuro por contraste).
  static const Color onBrand = Color(0xFF10130A);

  // Gradiente de marca (botones principales, hero, splash)
  static const List<Color> brandGradient = [Color(0xFFCBF43C), Color(0xFF9FD400)];

  // Azul marino del logo (fondos de marca / detalles)
  static const Color navy = Color(0xFF141E33);
  static const Color navyLight = Color(0xFF1E2C49);

  // ----- Secundario / acento (identidad conductor / info) -----
  static const Color accent = Color(0xFF3B8BFF);
  static const Color accentDark = Color(0xFF2E6FE0);
  static const Color accentSoft = Color(0xFF16233B);

  // ----- Estados positivos -----
  static const Color success = Color(0xFF34C759);
  static const Color successDark = Color(0xFF248A3D);

  // ----- Semánticos -----
  static const Color price = Color(0xFFF5B301); // ámbar (precio / oferta)
  static const Color danger = Color(0xFFFF5A5F);
  static const Color warning = Color(0xFFF5B301);
  static const Color info = Color(0xFF3B8BFF);
  static const Color star = Color(0xFFB6E61E); // estrellas lima (estilo póster)

  // ----- Superficies claras -----
  static const Color lightBackground = Color(0xFFF5F7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF1E8);
  static const Color lightBorder = Color(0xFFE2E6DA);
  static const Color lightTextPrimary = Color(0xFF11140C);
  static const Color lightTextSecondary = Color(0xFF585C50);
  static const Color lightTextMuted = Color(0xFF8B9080);

  // ----- Superficies oscuras (experiencia principal, estilo póster) -----
  static const Color darkBackground = Color(0xFF0A0B0D);
  static const Color darkSurface = Color(0xFF15171B);
  static const Color darkSurfaceAlt = Color(0xFF1F2229);
  static const Color darkBorder = Color(0xFF2B2F37);
  static const Color darkTextPrimary = Color(0xFFF4F6F1);
  static const Color darkTextSecondary = Color(0xFFAAB0A6);
  static const Color darkTextMuted = Color(0xFF737970);
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

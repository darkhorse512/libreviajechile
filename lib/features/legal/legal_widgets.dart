import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/surface_card.dart';

/// Datos de identificación comunes a los documentos legales de EligeDriver.
abstract class LegalInfo {
  static const company = 'EligeDriver SpA';
  static const rut = '78.467.243-3';
  static const version = '1.2';
  static const published = '16 de julio de 2026';
  static const effective = '1 de septiembre de 2026';
  static const address =
      'General Aldunate N° 620, depto./local 704, Temuco, Región de La Araucanía, Chile';
  static const email = 'eligedrive@gmail.com';
}

/// Encabezado con el título del documento y los datos del responsable.
class LegalHeader extends StatelessWidget {
  const LegalHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.gavel_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const _Kv('Responsable', LegalInfo.company),
          const _Kv('RUT', LegalInfo.rut),
          const _Kv('Versión', LegalInfo.version),
          const _Kv('Publicado', LegalInfo.published),
          const _Kv('Vigente desde', LegalInfo.effective),
          const _Kv('Domicilio', LegalInfo.address),
          const _Kv('Correo oficial', LegalInfo.email),
        ],
      ),
    );
  }
}

class _Kv extends StatelessWidget {
  const _Kv(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(k,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.palette.textMuted,
                      fontWeight: FontWeight.w700,
                    )),
          ),
          Expanded(
            child: Text(v, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// Recuadro de resumen/aceptación destacado (color de marca).
class LegalSummaryBox extends StatelessWidget {
  const LegalSummaryBox({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.verified_user_rounded,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brand, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          color: context.palette.textSecondary,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de sección numerada.
class LegalSection extends StatelessWidget {
  const LegalSection(this.number, this.title, {super.key});
  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$number',
                style: const TextStyle(
                    color: AppColors.brand, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de subsección (p. ej. 8.1).
class LegalSubsection extends StatelessWidget {
  const LegalSubsection(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.palette.textSecondary,
              )),
    );
  }
}

/// Párrafo de texto legal.
class LegalParagraph extends StatelessWidget {
  const LegalParagraph(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.5, color: context.palette.textSecondary)),
    );
  }
}

/// Lista con viñetas.
class LegalBullets extends StatelessWidget {
  const LegalBullets(this.items, {super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7, right: 10),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(it,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: context.palette.textSecondary,
                          )),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lista numerada (pasos ordenados).
class LegalOrderedList extends StatelessWidget {
  const LegalOrderedList(this.items, {super.key});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10, top: 1),
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                        color: AppColors.brand,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      )),
                ),
                Expanded(
                  child: Text(items[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: context.palette.textSecondary,
                          )),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Recuadro destacado con acento (promociones, avisos importantes).
class LegalCallout extends StatelessWidget {
  const LegalCallout({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.card_giftcard_rounded,
  });
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(body,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}

/// Pie con la normativa de referencia.
class LegalFooter extends StatelessWidget {
  const LegalFooter(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.palette.textMuted,
                height: 1.45,
              )),
    );
  }
}

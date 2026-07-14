import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';

/// Historial de calificaciones recibidas por el usuario.
class RatingsScreen extends ConsumerWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Mis calificaciones')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ref.watch(userRatingsProvider(user.id)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: context.tr('No pudimos cargar tus calificaciones'),
                ),
                data: (ratings) {
                  if (ratings.isEmpty) {
                    return EmptyState(
                      icon: Icons.star_border_rounded,
                      title: context.tr('Aún no tienes calificaciones'),
                      message: context.tr(
                          'Cuando completes viajes, las reseñas aparecerán aquí.'),
                    );
                  }
                  final avg =
                      ratings.map((r) => r.stars).reduce((a, b) => a + b) /
                          ratings.length;
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      SurfaceCard(
                        elevated: true,
                        child: Row(
                          children: [
                            Text(avg.toStringAsFixed(1),
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingStars(rating: avg, size: 18),
                                const SizedBox(height: 4),
                                Text(
                                  context.trp('{n} reseñas',
                                      {'n': '${ratings.length}'}),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: context.palette.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final r in ratings) ...[
                        _RatingCard(
                          stars: r.stars,
                          comment: r.comment,
                          raterName: r.rater?.fullName,
                          raterAvatar: r.rater?.avatarUrl,
                          date: Formatters.date(r.createdAt),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.stars,
    required this.date,
    this.comment,
    this.raterName,
    this.raterAvatar,
  });

  final int stars;
  final String date;
  final String? comment;
  final String? raterName;
  final String? raterAvatar;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: raterName ?? '?', imageUrl: raterAvatar, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(raterName ?? '—',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < stars ? AppColors.star : context.palette.border,
                  ),
                ),
              ),
            ],
          ),
          if (comment != null && comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('“${comment!}”',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Text(date,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.palette.textMuted)),
        ],
      ),
    );
  }
}

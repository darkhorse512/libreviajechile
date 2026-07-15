import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/rating.dart';
import '../../../shared/widgets/surface_card.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Tarjeta de una reseña recibida (estrellas + comentario + autor + fecha).
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.rating});
  final Rating rating;

  @override
  Widget build(BuildContext context) {
    final name = rating.rater?.fullName;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                  name: name ?? '?', imageUrl: rating.rater?.avatarUrl, size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name ?? '—',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < rating.stars
                        ? AppColors.star
                        : context.palette.border,
                  ),
                ),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('“${rating.comment!}”',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          Text(Formatters.date(rating.createdAt),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.palette.textMuted)),
        ],
      ),
    );
  }
}

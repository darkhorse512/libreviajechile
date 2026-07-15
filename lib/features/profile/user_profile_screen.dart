import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import 'widgets/review_card.dart';

/// Perfil público de otro usuario (conductor o pasajero): datos, calificación
/// y reseñas recibidas. De solo lectura.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId, this.initial});

  final String userId;
  final AppUser? initial;

  static Future<void> show(
    BuildContext context, {
    required String userId,
    AppUser? initial,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: userId, initial: initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fresh = ref.watch(userProfileProvider(userId)).valueOrNull;
    final user = fresh ?? initial;
    final ratingsAsync = ref.watch(userRatingsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Perfil')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userProfileProvider(userId));
                ref.invalidate(userRatingsProvider(userId));
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  _HeaderCard(user: user),
                  if (user.isDriver && user.vehicle != null) ...[
                    const SizedBox(height: 16),
                    _VehicleCard(user: user),
                  ],
                  const SizedBox(height: 20),
                  Text(context.tr('Reseñas'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ratingsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: context.tr('No pudimos cargar las reseñas'),
                    ),
                    data: (ratings) {
                      if (ratings.isEmpty) {
                        return EmptyState(
                          icon: Icons.star_border_rounded,
                          title: context.tr('Sin reseñas todavía'),
                        );
                      }
                      return Column(
                        children: [
                          for (final r in ratings) ...[
                            ReviewCard(rating: r),
                            const SizedBox(height: 12),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isDriver = user.role == UserRole.driver;
    return SurfaceCard(
      elevated: true,
      child: Column(
        children: [
          UserAvatar(name: user.fullName, imageUrl: user.avatarUrl, size: 84),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(user.fullName,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded,
                    color: AppColors.brand, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 8),
          InfoPill(
            label: context.tr(user.role.label),
            icon: isDriver ? Icons.directions_car_rounded : Icons.person_rounded,
            color: isDriver ? AppColors.accent : AppColors.brand,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Stat(
                value: user.hasRatings ? user.ratingAvg.toStringAsFixed(1) : '—',
                label: context.tr('Calificación'),
                icon: Icons.star_rounded,
                color: AppColors.star,
              ),
              _divider(context),
              _Stat(
                value: '${user.tripsCount}',
                label: context.tr('Viajes'),
                icon: Icons.route_rounded,
                color: AppColors.brand,
              ),
              _divider(context),
              _Stat(
                value: '${user.ratingCount}',
                label: context.tr('Reseñas'),
                icon: Icons.reviews_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 40, color: context.palette.border);
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final v = user.vehicle!;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    color: AppColors.accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.displayName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${v.year} · ${v.color} · ${v.plate}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.palette.textSecondary,
                            )),
                  ],
                ),
              ),
            ],
          ),
          if (v.carPhotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: v.carPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _openGallery(context, v.carPhotos, i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      v.carPhotos[i],
                      width: 150,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 150,
                        height: 110,
                        color: context.palette.border,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openGallery(BuildContext context, List<String> photos, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(photos: photos, initialIndex: index),
      ),
    );
  }
}

/// Visor a pantalla completa de las fotos del auto.
class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({required this.photos, required this.initialIndex});
  final List<String> photos;
  final int initialIndex;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photos.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.photos[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: context.palette.textMuted)),
        ],
      ),
    );
  }
}

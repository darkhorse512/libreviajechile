import 'app_user.dart';

/// Una calificación recibida por un usuario.
class Rating {
  const Rating({
    required this.id,
    required this.stars,
    required this.createdAt,
    this.comment,
    this.rater,
  });

  final String id;
  final int stars;
  final DateTime createdAt;
  final String? comment;
  final AppUser? rater;

  factory Rating.fromMap(Map<String, dynamic> map, {AppUser? rater}) {
    return Rating(
      id: map['id'] as String,
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      comment: map['comment'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      rater: rater,
    );
  }
}

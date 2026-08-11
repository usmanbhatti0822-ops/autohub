import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class Review {
  final String id;
  final String authorId;
  final String authorName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorName: (json['author'] is Map ? json['author']['fullName'] as String? : null) ?? 'AutoHub User',
        rating: json['rating'] as int,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class UserRating {
  final double average;
  final int count;
  final List<Review> reviews;
  const UserRating({required this.average, required this.count, this.reviews = const []});
}

class ReviewsRepository {
  final Dio _dio;
  ReviewsRepository(this._dio);

  Future<UserRating> forUser(String userId) async {
    final res = await _dio.get('/reviews/user/$userId');
    final list = (res.data['reviews'] as List).map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    return UserRating(
      average: double.parse(res.data['average'].toString()),
      count: list.length,
      reviews: list,
    );
  }

  Future<void> create({
    required String subjectId,
    required String type,
    required int rating,
    String? comment,
    String? relatedBookingId,
  }) async {
    await _dio.post('/reviews', data: {
      'subjectId': subjectId,
      'type': type,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
      if (relatedBookingId != null) 'relatedBookingId': relatedBookingId,
    });
  }
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.read(dioProvider));
});

final userRatingProvider = FutureProvider.autoDispose.family<UserRating, String>((ref, userId) {
  if (userId.isEmpty) return const UserRating(average: 0, count: 0);
  return ref.read(reviewsRepositoryProvider).forUser(userId);
});

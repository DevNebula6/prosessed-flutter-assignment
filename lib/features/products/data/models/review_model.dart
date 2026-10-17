import '../../domain/entities/review.dart';

class ReviewModel {
  const ReviewModel({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
      reviewerName: json['reviewerName'] as String,
    );
  }

  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;

  Review toEntity() => Review(
    rating: rating,
    comment: comment,
    date: date,
    reviewerName: reviewerName,
  );
}

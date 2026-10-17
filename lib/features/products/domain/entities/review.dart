import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
  });

  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;

  @override
  List<Object?> get props => [rating, comment, date, reviewerName];
}

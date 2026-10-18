import 'package:equatable/equatable.dart';

import 'review.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.brand,
    this.description = '',
    this.images = const [],
    this.reviews = const [],
  });

  final int id;
  final String title;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;

  /// Not every product has a brand (groceries, for example).
  final String? brand;

  // Only filled in when the full product is loaded, list pages skip them.
  final String description;
  final List<String> images;
  final List<Review> reviews;

  double get discountedPrice => price * (1 - discountPercentage / 100);

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    price,
    discountPercentage,
    rating,
    stock,
    thumbnail,
    brand,
    description,
    images,
    reviews,
  ];
}

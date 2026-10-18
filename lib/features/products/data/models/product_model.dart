import '../../domain/entities/product.dart';
import 'review_model.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.brand,
    required this.description,
    required this.images,
    required this.reviews,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      thumbnail: json['thumbnail'] as String,
      brand: json['brand'] as String?,
      // List requests only select the card fields, so these can be missing.
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? const []).cast<String>(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map((review) => ReviewModel.fromJson(review as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String title;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final String? brand;
  final String description;
  final List<String> images;
  final List<ReviewModel> reviews;

  Product toEntity() => Product(
    id: id,
    title: title,
    category: category,
    price: price,
    discountPercentage: discountPercentage,
    rating: rating,
    stock: stock,
    thumbnail: thumbnail,
    brand: brand,
    description: description,
    images: images,
    reviews: reviews.map((review) => review.toEntity()).toList(),
  );
}

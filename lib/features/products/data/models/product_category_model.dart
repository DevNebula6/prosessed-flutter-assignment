import '../../domain/entities/product_category.dart';

class ProductCategoryModel {
  const ProductCategoryModel({required this.slug, required this.name});

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      slug: json['slug'] as String,
      name: json['name'] as String,
    );
  }

  final String slug;
  final String name;

  ProductCategory toEntity() => ProductCategory(slug: slug, name: name);
}

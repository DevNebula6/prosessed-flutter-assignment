import '../../domain/entities/products_page.dart';
import 'product_model.dart';

class ProductsPageModel {
  const ProductsPageModel({
    required this.products,
    required this.skip,
    required this.total,
  });

  factory ProductsPageModel.fromJson(Map<String, dynamic> json) {
    return ProductsPageModel(
      products: (json['products'] as List<dynamic>)
          .map(
            (product) => ProductModel.fromJson(product as Map<String, dynamic>),
          )
          .toList(),
      skip: json['skip'] as int,
      total: json['total'] as int,
    );
  }

  final List<ProductModel> products;
  final int skip;
  final int total;

  ProductsPage toEntity() => ProductsPage(
    products: products.map((product) => product.toEntity()).toList(),
    skip: skip,
    total: total,
  );
}

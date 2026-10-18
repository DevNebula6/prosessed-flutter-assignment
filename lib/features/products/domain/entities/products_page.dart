import 'package:equatable/equatable.dart';

import 'product.dart';

/// One page of a paginated product request.
class ProductsPage extends Equatable {
  const ProductsPage({
    required this.products,
    required this.skip,
    required this.total,
  });

  final List<Product> products;
  final int skip;
  final int total;

  bool get hasMore => skip + products.length < total;

  @override
  List<Object?> get props => [products, skip, total];
}

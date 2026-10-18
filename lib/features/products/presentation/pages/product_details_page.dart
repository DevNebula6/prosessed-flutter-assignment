import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../widgets/product_details.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key, required this.productId, this.preview});

  final int productId;
  final Product? preview;

  static Route<void> route(Product product) {
    return MaterialPageRoute(
      builder: (_) =>
          ProductDetailsPage(productId: product.id, preview: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ProductDetails(productId: productId, preview: preview),
    );
  }
}

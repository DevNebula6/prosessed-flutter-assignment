import 'package:flutter/material.dart';

import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/widgets/cart_icon.dart';
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
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const CartIcon(),
            onPressed: () => Navigator.of(context).push(CartPage.route()),
          ),
        ],
      ),
      body: ProductDetails(productId: productId, preview: preview),
    );
  }
}

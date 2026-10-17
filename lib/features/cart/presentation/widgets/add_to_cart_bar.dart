import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/quantity_selector.dart';
import '../../../products/domain/entities/product.dart';
import '../cubit/cart_cubit.dart';
import '../pages/cart_page.dart';

class AddToCartBar extends StatefulWidget {
  const AddToCartBar({super.key, required this.product});

  final Product product;

  @override
  State<AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<AddToCartBar> {
  var _quantity = 1;

  void _add(int quantity) {
    // Grab the navigator now, the snackbar can outlive this page.
    final navigator = Navigator.of(context);
    context.read<CartCubit>().add(widget.product, quantity: quantity);
    setState(() => _quantity = 1);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            quantity == 1
                ? 'Added to your cart'
                : 'Added $quantity to your cart',
          ),
          action: SnackBarAction(
            label: 'View cart',
            onPressed: () => navigator.push(CartPage.route()),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final inCart = context.select(
      (CartCubit cubit) => cubit.state.quantityOf(product.id),
    );
    // What's left once the units already in the cart are taken off.
    final available = product.stock - inCart;
    final quantity = min(_quantity, max(available, 1));

    final label = switch (available) {
      _ when !product.inStock => 'Out of stock',
      <= 0 => 'All in your cart',
      _ => 'Add to cart',
    };

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (available > 0) ...[
                QuantitySelector(
                  value: quantity,
                  max: available,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: available > 0 ? () => _add(quantity) : null,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const CartPage());
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const EmptyView(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Products you add will show up here.',
            )
          : _CartContent(cart),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent(this.cart);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: cart.items.length,
      itemBuilder: (context, index) => CartItemTile(cart.items[index]),
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: AppSpacing.lg,
        endIndent: AppSpacing.lg,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Summary beside the list on wide screens, pinned below it otherwise.
        if (constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: items),
              SizedBox(
                width: 360,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: CartSummary(cart: cart),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: items),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: CartSummary(cart: cart),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

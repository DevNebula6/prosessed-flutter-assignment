import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/quantity_selector.dart';
import '../../domain/entities/cart_item.dart';
import '../cubit/cart_cubit.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile(this.item, {super.key});

  final CartItem item;

  void _remove(BuildContext context) {
    final cart = context.read<CartCubit>()..remove(item.product.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${item.product.title}'),
          // Snack bars with an action stay up until dismissed by default.
          // Only keep it for screen reader users, who need time to reach Undo.
          persist: MediaQuery.accessibleNavigationOf(context),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => cart.add(item.product, quantity: item.quantity),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final product = item.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(context),
      background: ColoredBox(
        color: colors.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colors.onErrorContainer,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ColoredBox(
                color: colors.surfaceContainerLowest,
                child: SizedBox.square(
                  dimension: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: AppNetworkImage(
                      product.thumbnail,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatPrice(item.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.quantity > 1)
                    Text(
                      '${formatPrice(product.discountedPrice)} each',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      QuantitySelector(
                        value: item.quantity,
                        max: product.stock,
                        onChanged: (quantity) => context
                            .read<CartCubit>()
                            .updateQuantity(product.id, quantity),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _remove(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

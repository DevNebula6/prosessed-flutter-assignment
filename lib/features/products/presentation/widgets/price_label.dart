import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';

/// Discounted price with the original price struck through next to it.
class PriceLabel extends StatelessWidget {
  const PriceLabel(this.product, {super.key, this.large = false});

  final Product product;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hasDiscount = product.discountPercentage >= 1;

    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          formatPrice(product.discountedPrice),
          style: (large ? textTheme.headlineSmall : textTheme.titleMedium)
              ?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (hasDiscount)
          Text(
            formatPrice(product.price),
            semanticsLabel: 'was ${formatPrice(product.price)}',
            style: (large ? textTheme.bodyLarge : textTheme.bodySmall)
                ?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
      ],
    );
  }
}

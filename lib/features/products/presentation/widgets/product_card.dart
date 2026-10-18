import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product.dart';
import 'discount_badge.dart';
import 'price_label.dart';
import 'rating_label.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!;
    // Always reserve two lines for the title so images line up across a row.
    final titleHeight = MediaQuery.textScalerOf(context)
        .scale(titleStyle.fontSize! * titleStyle.height! * 2);

    return MergeSemantics(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: theme.colorScheme.surfaceContainerLowest,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: AppNetworkImage(
                          product.thumbnail,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    if (product.discountPercentage >= 1)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: DiscountBadge(product.discountPercentage),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: titleHeight,
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PriceLabel(product),
                    const SizedBox(height: AppSpacing.xs),
                    RatingLabel(product.rating),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';
import '../../domain/entities/product.dart';
import 'discount_badge.dart';
import 'price_label.dart';
import 'rating_label.dart';

/// Shared by the card thumbnail and the first details image so the image
/// flies between the two screens.
String productImageHeroTag(int productId) => 'product-image-$productId';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.selected = false,
  });

  final Product product;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleSmall!;
    // Always reserve two lines for the title so images line up across a row.
    final titleHeight = MediaQuery.textScalerOf(context)
        .scale(titleStyle.fontSize! * titleStyle.height! * 2);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: selected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Read out as one item; the heart below stays its own button.
          MergeSemantics(
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
                            child: Hero(
                              tag: productImageHeroTag(product.id),
                              child: AppNetworkImage(
                                product.thumbnail,
                                fit: BoxFit.contain,
                              ),
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
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: WishlistButton(product: product, onImage: true),
          ),
        ],
      ),
    );
  }
}

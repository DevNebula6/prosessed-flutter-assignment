import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../cart/presentation/widgets/add_to_cart_bar.dart';
import '../../../wishlist/presentation/widgets/wishlist_button.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_details_cubit.dart';
import 'discount_badge.dart';
import 'image_carousel.dart';
import 'price_label.dart';
import 'product_card.dart';
import 'rating_label.dart';
import 'review_tile.dart';
import 'stock_status.dart';

/// Product details without a scaffold, so they can fill a page or a pane.
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.productId, this.preview});

  final int productId;

  /// The product as it came from the list, shown while the full one loads.
  final Product? preview;

  @override
  Widget build(BuildContext context) {
    final preview = this.preview;

    return BlocProvider(
      create: (_) => getIt<ProductDetailsCubit>()..load(productId),
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) => switch (state) {
          ProductDetailsLoaded(:final product) => _DetailsContent(product),
          ProductDetailsLoading() when preview != null => _DetailsContent(
            preview,
            isLoading: true,
          ),
          ProductDetailsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ProductDetailsNotFound() => EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Product not found',
            message: "This product doesn't exist or is no longer available.",
            actionLabel: Navigator.canPop(context) ? 'Back to shop' : null,
            onAction: () => Navigator.pop(context),
          ),
          ProductDetailsError(:final failure) => ErrorView(
            failure: failure,
            onRetry: () => context.read<ProductDetailsCubit>().load(productId),
          ),
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent(this.product, {this.isLoading = false});

  final Product product;

  /// The description and reviews are still on their way.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final gallery = ImageCarousel(
      images: product.images.isEmpty ? [product.thumbnail] : product.images,
      placeholderUrl: product.thumbnail,
      heroTag: productImageHeroTag(product.id),
    );
    final info = _ProductInfo(product, isLoading: isLoading);

    final content = LayoutBuilder(
      builder: (context, constraints) {
        // Image and text side by side when there's room for both.
        if (constraints.maxWidth >= 720) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: gallery),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: info),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            gallery,
            Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: info),
          ],
        );
      },
    );

    return Column(
      children: [
        Expanded(child: content),
        AddToCartBar(product: product),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo(this.product, {required this.isLoading});

  final Product product;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final mutedColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.brand case final brand?)
          Text(
            brand,
            style: text.labelLarge?.copyWith(color: theme.colorScheme.primary),
          ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(product.title, style: text.headlineSmall)),
            WishlistButton(product: product),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        RatingLabel(product.rating),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PriceLabel(product, large: true),
            if (product.discountPercentage >= 1)
              DiscountBadge(product.discountPercentage),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StockStatus(product.stock),
        const SizedBox(height: AppSpacing.xl),
        Text('Description', style: text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (isLoading)
          const _TextSkeleton(lines: 3)
        else
          Text(
            product.description,
            style: text.bodyLarge?.copyWith(color: mutedColor),
          ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          isLoading ? 'Reviews' : 'Reviews (${product.reviews.length})',
          style: text.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isLoading)
          const _TextSkeleton(lines: 4)
        else if (product.reviews.isEmpty)
          Text(
            'No reviews yet.',
            style: text.bodyMedium?.copyWith(color: mutedColor),
          )
        else
          for (final review in product.reviews) ReviewTile(review),
      ],
    );
  }
}

class _TextSkeleton extends StatelessWidget {
  const _TextSkeleton({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var line = 0; line < lines; line++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: FractionallySizedBox(
                // A shorter last line reads as the end of a paragraph.
                widthFactor: line == lines - 1 ? 0.6 : 1,
                child: const ShimmerBox(height: 14),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../bloc/products_bloc.dart';
import 'product_card.dart';
import 'product_card_skeleton.dart';

/// Two columns on phones, three or four on tablets.
const productGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 240,
  mainAxisSpacing: AppSpacing.md,
  crossAxisSpacing: AppSpacing.md,
  childAspectRatio: 0.62,
);

/// The product list as slivers, for use inside a [CustomScrollView].
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state.products.isEmpty) {
          return switch (state.status) {
            ProductsStatus.failure => SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorView(
                failure: state.failure!,
                onRetry: () {
                  context.read<ProductsBloc>().add(const ProductsRequested());
                },
              ),
            ),
            ProductsStatus.empty => SliverFillRemaining(
              hasScrollBody: false,
              child: _NoResults(query: state.query),
            ),
            _ => SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid.builder(
                gridDelegate: productGridDelegate,
                itemCount: 8,
                itemBuilder: (_, _) => const ProductCardSkeleton(),
              ),
            ),
          };
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid.builder(
                gridDelegate: productGridDelegate,
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: state.products[index]);
                },
              ),
            ),
            SliverToBoxAdapter(child: _GridFooter(state)),
          ],
        );
      },
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const EmptyView(
        icon: Icons.inventory_2_outlined,
        title: 'Nothing here yet',
        message: 'Try another category.',
      );
    }

    return EmptyView(
      icon: Icons.search_off_rounded,
      title: 'No results for "$query"',
      message: 'Check the spelling or try a different search.',
      actionLabel: 'Clear search',
      onAction: () => context.read<ProductsBloc>().add(const SearchChanged('')),
    );
  }
}

class _GridFooter extends StatelessWidget {
  const _GridFooter(this.state);

  final ProductsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = switch (state) {
      ProductsState(status: ProductsStatus.loadingMore) =>
        const CircularProgressIndicator(),
      ProductsState(failure: _?) => Column(
        children: [
          Text(
            "Couldn't load more products.",
            style: theme.textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: () {
              context.read<ProductsBloc>().add(const NextPageRequested());
            },
            child: const Text('Try again'),
          ),
        ],
      ),
      ProductsState(hasReachedEnd: true) => Text(
        "You've reached the end",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Center(child: child),
    );
  }
}

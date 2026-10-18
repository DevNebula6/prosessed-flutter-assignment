import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../domain/entities/product.dart';
import '../bloc/products_bloc.dart';
import '../cubit/categories_cubit.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_details.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_search_field.dart';
import '../widgets/sort_button.dart';
import 'product_details_page.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ProductsBloc>()..add(const ProductsRequested()),
        ),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..load()),
      ],
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  /// The product shown in the side pane on expanded layouts.
  Product? _selected;

  bool get _isExpanded => ScreenSize.of(context) == ScreenSize.expanded;

  void _openProduct(Product product) {
    if (_isExpanded) {
      setState(() => _selected = product);
    } else {
      Navigator.of(context).push(ProductDetailsPage.route(product));
    }
  }

  Future<void> _refresh() async {
    final categories = context.read<CategoriesCubit>();
    if (categories.state is CategoriesError) unawaited(categories.load());

    final bloc = context.read<ProductsBloc>()..add(const ProductsRefreshed());
    await bloc.stream.firstWhere(
      (state) => state.status != ProductsStatus.loading,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    // Ask for the next page a little before the user reaches the bottom.
    if (notification.depth == 0 && notification.metrics.extentAfter < 600) {
      final bloc = context.read<ProductsBloc>();
      // After a failure, wait for the footer's retry instead of re-firing
      // on every scroll.
      if (bloc.state.failure == null) bloc.add(const NextPageRequested());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final list = RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ProductSearchField()),
            const SliverToBoxAdapter(child: CategoryChips()),
            ProductGrid(
              onProductTap: _openProduct,
              selectedProductId: _isExpanded ? _selected?.id : null,
            ),
          ],
        ),
      ),
    );

    return BlocListener<ProductsBloc, ProductsState>(
      listenWhen: (previous, current) {
        return previous.failure == null &&
            current.failure != null &&
            current.products.isNotEmpty;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.failure!.message)));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          actions: const [SortButton()],
        ),
        body: _isExpanded
            ? Row(
                children: [
                  Expanded(flex: 3, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(flex: 2, child: _DetailsPane(product: _selected)),
                ],
              )
            : list,
      ),
    );
  }
}

class _DetailsPane extends StatelessWidget {
  const _DetailsPane({required this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    final product = this.product;
    if (product == null) {
      return const EmptyView(
        icon: Icons.touch_app_outlined,
        title: 'Pick a product',
        message: 'Its details will show up here.',
      );
    }

    // The grid card already carries this hero tag on the same route, and two
    // heroes with one tag on a route is an error.
    return HeroMode(
      enabled: false,
      child: ProductDetails(
        key: ValueKey(product.id),
        productId: product.id,
        preview: product,
      ),
    );
  }
}

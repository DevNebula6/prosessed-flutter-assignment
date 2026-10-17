import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../bloc/products_bloc.dart';
import '../widgets/product_grid.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductsBloc>()..add(const ProductsRequested()),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView();

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<ProductsBloc>()..add(const ProductsRefreshed());
    await bloc.stream.firstWhere(
      (state) => state.status != ProductsStatus.loading,
    );
  }

  bool _onScroll(BuildContext context, ScrollNotification notification) {
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
        appBar: AppBar(title: const Text('Discover')),
        body: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => _onScroll(context, notification),
            child: const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [ProductGrid()],
            ),
          ),
        ),
      ),
    );
  }
}

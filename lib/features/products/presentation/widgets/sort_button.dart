import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product_sort.dart';
import '../bloc/products_bloc.dart';

class SortButton extends StatelessWidget {
  const SortButton({super.key});

  Future<void> _showSortOptions(
    BuildContext context,
    ProductSort current,
  ) async {
    final selected = await showModalBottomSheet<ProductSort>(
      context: context,
      builder: (context) => _SortSheet(current: current),
    );
    if (selected != null && context.mounted) {
      context.read<ProductsBloc>().add(SortChanged(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sort = context.select((ProductsBloc bloc) => bloc.state.sort);

    return IconButton(
      tooltip: 'Sort',
      icon: Badge(
        isLabelVisible: sort != ProductSort.relevance,
        child: const Icon(Icons.swap_vert_rounded),
      ),
      onPressed: () => _showSortOptions(context, sort),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final ProductSort current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Text('Sort by', style: theme.textTheme.titleMedium),
          ),
          for (final sort in ProductSort.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              title: Text(sort.label),
              selected: sort == current,
              trailing: sort == current
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.pop(context, sort),
            ),
        ],
      ),
    );
  }
}

extension on ProductSort {
  String get label => switch (this) {
    ProductSort.relevance => 'Recommended',
    ProductSort.priceLowToHigh => 'Price: low to high',
    ProductSort.priceHighToLow => 'Price: high to low',
    ProductSort.rating => 'Top rated',
    ProductSort.title => 'Name: A to Z',
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../bloc/products_bloc.dart';
import '../cubit/categories_cubit.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select((ProductsBloc bloc) => bloc.state.category);
    final categoriesState = context.watch<CategoriesCubit>().state;

    final chips = switch (categoriesState) {
      CategoriesLoading() => [
        for (final width in const [48.0, 88.0, 72.0, 104.0, 64.0])
          AppShimmer(child: ShimmerBox(width: width, height: 32, radius: 16)),
      ],
      CategoriesError() => [
        ActionChip(
          avatar: const Icon(Icons.refresh_rounded),
          label: const Text("Couldn't load categories"),
          onPressed: () => context.read<CategoriesCubit>().load(),
        ),
      ],
      CategoriesLoaded(:final categories) => [
        _chip(context, label: 'All', slug: null, selected: selected),
        for (final category in categories)
          _chip(
            context,
            label: category.name,
            slug: category.slug,
            selected: selected,
          ),
      ],
    };

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) => Center(child: chips[index]),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required String? slug,
    required String? selected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: slug == selected,
      onSelected: (_) {
        context.read<ProductsBloc>().add(CategorySelected(slug));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../bloc/products_bloc.dart';

class ProductSearchField extends StatefulWidget {
  const ProductSearchField({super.key});

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<ProductsBloc>().add(const SearchChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsBloc, ProductsState>(
      // Picking a category clears the search, so the text has to go too.
      listenWhen: (previous, current) {
        return previous.query != current.query && current.query.isEmpty;
      },
      listener: (context, state) => _controller.clear(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xs,
        ),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => TextField(
            controller: _controller,
            onChanged: (value) {
              context.read<ProductsBloc>().add(SearchChanged(value));
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clear,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

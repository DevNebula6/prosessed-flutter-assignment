import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/domain/entities/product.dart';
import '../bloc/wishlist_bloc.dart';

/// A heart that saves [product] to the wishlist or takes it off again.
class WishlistButton extends StatelessWidget {
  const WishlistButton({
    super.key,
    required this.product,
    this.onImage = false,
  });

  final Product product;

  /// Puts a backdrop behind the heart so it stays visible on a photo.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final saved = context.select(
      (WishlistBloc bloc) => bloc.state.contains(product.id),
    );
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: saved ? 'Remove from wishlist' : 'Save to wishlist',
      style: onImage
          ? IconButton.styleFrom(
              backgroundColor: colors.surface.withValues(alpha: 0.85),
            )
          : null,
      onPressed: () {
        context.read<WishlistBloc>().add(WishlistToggled(product));
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: saved
            ? const Icon(
                Icons.favorite_rounded,
                key: ValueKey('saved'),
                color: AppColors.favorite,
              )
            : const Icon(
                Icons.favorite_border_rounded,
                key: ValueKey('not-saved'),
              ),
      ),
    );
  }
}

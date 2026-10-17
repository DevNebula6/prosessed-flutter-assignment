import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';

/// Cart icon with a badge for the number of units in the cart.
class CartIcon extends StatelessWidget {
  const CartIcon({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final count = context.select((CartCubit cubit) => cubit.state.itemCount);

    return TweenAnimationBuilder<double>(
      // A new key restarts the little bump every time the count changes.
      key: ValueKey(count),
      tween: Tween(begin: 1.25, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(
          selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
        ),
      ),
    );
  }
}

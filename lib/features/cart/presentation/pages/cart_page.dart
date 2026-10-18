import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';
import 'order_success_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const CartPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CheckoutCubit>(),
      // On the Cart tab this Scaffold sits inside the home one, and snackbars
      // only show in the outermost Scaffold of a messenger, on top of the
      // checkout panel. Its own messenger keeps them inside this Scaffold.
      child: const ScaffoldMessenger(child: _CartView()),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  void _onCheckoutChanged(BuildContext context, CheckoutState state) {
    switch (state) {
      case CheckoutSuccess(:final order):
        final cart = context.read<CartCubit>();
        final total = cart.state.total;
        cart.clear();
        Navigator.of(context).push(OrderSuccessPage.route(order, total: total));
      case CheckoutError(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case CheckoutIdle() || CheckoutInProgress():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartCubit>().state;

    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: _onCheckoutChanged,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Summary beside the list on wide screens, pinned below it otherwise.
          final isWide = constraints.maxWidth >= 720;

          return Scaffold(
            appBar: AppBar(title: const Text('Cart')),
            body: switch (cart) {
              Cart(isEmpty: true) => const EmptyView(
                icon: Icons.shopping_cart_outlined,
                title: 'Your cart is empty',
                message: 'Products you add will show up here.',
              ),
              _ when isWide => _WideCart(cart),
              _ => _CartItems(cart),
            },
            // As the bottom bar rather than part of the body, so snackbars
            // like "Removed … Undo" appear above it instead of covering it.
            bottomNavigationBar: cart.isEmpty || isWide
                ? null
                : _CheckoutPanel(cart),
          );
        },
      ),
    );
  }
}

class _CartItems extends StatelessWidget {
  const _CartItems(this.cart);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: cart.items.length,
      itemBuilder: (context, index) => CartItemTile(cart.items[index]),
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: AppSpacing.lg,
        endIndent: AppSpacing.lg,
      ),
    );
  }
}

class _WideCart extends StatelessWidget {
  const _WideCart(this.cart);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _CartItems(cart)),
        SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _Checkout(cart),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  const _CheckoutPanel(this.cart);

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _Checkout(cart),
        ),
      ),
    );
  }
}

class _Checkout extends StatelessWidget {
  const _Checkout(this.cart);

  final Cart cart;

  void _placeOrder(BuildContext context) {
    if (context.read<AuthCubit>().state case Authenticated(:final user)) {
      context.read<CheckoutCubit>().placeOrder(userId: user.id, cart: cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlacing = context.select(
      (CheckoutCubit cubit) => cubit.state is CheckoutInProgress,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CartSummary(cart: cart),
        const SizedBox(height: AppSpacing.lg),
        LoadingButton(
          label: 'Place order',
          isLoading: isPlacing,
          onPressed: () => _placeOrder(context),
        ),
      ],
    );
  }
}

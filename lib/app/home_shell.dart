import 'package:flutter/material.dart';

import '../core/utils/breakpoints.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/cart/presentation/widgets/cart_icon.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/wishlist/presentation/pages/wishlist_page.dart';

/// Top-level tabs: a bottom bar on phones, a navigation rail on wider screens.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const HomeShell());
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _tabs = [
    (
      label: 'Shop',
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
    ),
    (
      label: 'Wishlist',
      icon: Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
    ),
    (label: 'Cart', icon: CartIcon(), selectedIcon: CartIcon(selected: true)),
    (
      label: 'Profile',
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
    ),
  ];

  static const _pages = [
    ProductsPage(),
    WishlistPage(),
    CartPage(),
    ProfilePage(),
  ];

  var _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps each tab's state, like scroll position, when switching.
    // Shop and Wishlist can show the same product, so only the visible tab
    // takes part in hero animations; duplicate hero tags on a route are an
    // error.
    final body = IndexedStack(
      index: _index,
      children: [
        for (final (index, page) in _pages.indexed)
          HeroMode(enabled: index == _index, child: page),
      ],
    );

    if (ScreenSize.of(context) == ScreenSize.compact) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: tab.icon,
                selectedIcon: tab.selectedIcon,
                label: tab.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: [
                for (final tab in _tabs)
                  NavigationRailDestination(
                    icon: tab.icon,
                    selectedIcon: tab.selectedIcon,
                    label: Text(tab.label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

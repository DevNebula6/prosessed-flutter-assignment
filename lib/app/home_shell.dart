import 'package:flutter/material.dart';

import '../core/utils/breakpoints.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/cart/presentation/widgets/cart_icon.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

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
    (label: 'Cart', icon: CartIcon(), selectedIcon: CartIcon(selected: true)),
    (
      label: 'Profile',
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
    ),
  ];

  var _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps each tab's state, like scroll position, when switching.
    final body = IndexedStack(
      index: _index,
      children: const [ProductsPage(), CartPage(), ProfilePage()],
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

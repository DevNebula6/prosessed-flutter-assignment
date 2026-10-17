import 'package:flutter/material.dart';

import '../core/utils/breakpoints.dart';
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
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
    ),
    (
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  var _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps each tab's state, like scroll position, when switching.
    final body = IndexedStack(
      index: _index,
      children: const [
        Center(child: Text('Products are coming next.')),
        ProfilePage(),
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
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
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
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
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

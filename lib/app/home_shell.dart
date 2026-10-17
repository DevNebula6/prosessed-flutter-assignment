import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const HomeShell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSphere'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: const Center(child: Text('Products are coming next.')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_bloc.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'home_shell.dart';
import 'navigation.dart';

class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkSession()),
        BlocProvider(create: (_) => getIt<CartCubit>()),
        BlocProvider(create: (_) => getIt<WishlistBloc>()),
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'ShopSphere',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          builder: (context, child) => BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) {
              return previous.runtimeType != current.runtimeType;
            },
            listener: _onAuthChanged,
            child: child,
          ),
          home: const SplashPage(),
        ),
      ),
    );
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    // The cart and wishlist belong to whoever is signed in.
    if (state is Unauthenticated) {
      context.read<CartCubit>().clear();
      context.read<WishlistBloc>().add(const WishlistCleared());
    }

    final route = switch (state) {
      Authenticated() => HomeShell.route(),
      Unauthenticated() => LoginPage.route(),
      AuthInitial() => null,
    };
    if (route != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(route, (_) => false);
    }

    // Explains a sign-out the user didn't ask for, like an expired session.
    if (state case Unauthenticated(:final message?)) {
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

abstract final class ApiEndpoints {
  static const baseUrl = 'https://dummyjson.com';

  /// How long an access token lasts. Lower it with
  /// `--dart-define=TOKEN_LIFETIME_MINUTES=1` to see the refresh in action.
  static const tokenLifetimeMinutes = int.fromEnvironment(
    'TOKEN_LIFETIME_MINUTES',
    defaultValue: 30,
  );

  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const me = '/auth/me';

  static const products = '/products';
  static const searchProducts = '/products/search';
  static const categories = '/products/categories';
  static String productsByCategory(String slug) => '/products/category/$slug';
  static String product(int id) => '/products/$id';

  static const addCart = '/carts/add';
}

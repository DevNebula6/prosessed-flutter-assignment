abstract final class ApiEndpoints {
  static const baseUrl = 'https://dummyjson.com';

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

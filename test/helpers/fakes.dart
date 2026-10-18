import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/core/storage/theme_storage.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_category.dart';
import 'package:shopsphere/features/products/domain/entities/product_sort.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';
import 'package:shopsphere/features/products/domain/entities/review.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/profile/domain/entities/user_profile.dart';
import 'package:shopsphere/features/profile/domain/repositories/profile_repository.dart';
import 'package:shopsphere/features/wishlist/domain/repositories/wishlist_repository.dart';

// In-memory stand-ins for every repository, for tests that build whole
// screens. Each one behaves like a quick, healthy backend.

const testUser = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily.johnson@x.dummyjson.com',
  image: 'https://dummyjson.com/icon/emilys/128',
);

Product testProduct(int id, {int stock = 5}) {
  return Product(
    id: id,
    title: 'Essence Mascara Lash Princess $id',
    category: 'beauty',
    price: 9.99,
    discountPercentage: 10.48,
    rating: 4.2,
    stock: stock,
    thumbnail: 'https://cdn.dummyjson.com/$id/thumbnail.webp',
    brand: 'Essence',
    description: 'A popular mascara known for its volumizing effect.',
    images: [
      'https://cdn.dummyjson.com/$id/1.webp',
      'https://cdn.dummyjson.com/$id/2.webp',
    ],
    reviews: [
      Review(
        rating: 4,
        comment: 'Very satisfied! It lasted all day without smudging.',
        date: DateTime(2025, 4, 30),
        reviewerName: 'Eleanor Collins',
      ),
    ],
  );
}

class FakeAuthRepository extends Fake implements AuthRepository {
  FakeAuthRepository({this.savedUser});

  final User? savedUser;

  @override
  Future<User?> getSavedUser() async => savedUser;

  @override
  Future<void> logout() async {}
}

class FakeProductRepository extends Fake implements ProductRepository {
  final products = [
    for (var id = 1; id <= 6; id++) testProduct(id),
    testProduct(7, stock: 0),
  ];

  @override
  Future<Result<ProductsPage>> getProducts({
    String query = '',
    String? category,
    ProductSort sort = ProductSort.relevance,
    int skip = 0,
    int limit = 20,
  }) async {
    return Ok(ProductsPage(products: products, skip: 0, total: 100));
  }

  @override
  Future<Result<Product>> getProduct(int id) async {
    for (final product in products) {
      if (product.id == id) return Ok(product);
    }
    return const Err(NotFoundFailure());
  }

  @override
  Future<Result<List<ProductCategory>>> getCategories() async {
    return const Ok([
      ProductCategory(slug: 'beauty', name: 'Beauty'),
      ProductCategory(slug: 'fragrances', name: 'Fragrances'),
      ProductCategory(slug: 'home-decoration', name: 'Home Decoration'),
    ]);
  }
}

class FakeCartRepository extends Fake implements CartRepository {
  FakeCartRepository([this.saved = const Cart()]);

  Cart saved;

  @override
  Cart loadCart() => saved;

  @override
  Future<void> saveCart(Cart cart) async => saved = cart;

  @override
  Future<Result<Order>> placeOrder({
    required int userId,
    required Cart cart,
  }) async {
    return Ok(Order(id: 209, totalQuantity: cart.itemCount));
  }
}

class FakeWishlistRepository extends Fake implements WishlistRepository {
  FakeWishlistRepository([this.saved = const []]);

  List<Product> saved;

  @override
  List<Product> loadWishlist() => saved;

  @override
  Future<void> saveWishlist(List<Product> products) async => saved = products;
}

class FakeProfileRepository extends Fake implements ProfileRepository {
  @override
  Future<Result<UserProfile>> getProfile() async {
    return const Ok(
      UserProfile(
        firstName: 'Emily',
        lastName: 'Johnson',
        username: 'emilys',
        email: 'emily.johnson@x.dummyjson.com',
        phone: '+81 965-431-3024',
        image: 'https://dummyjson.com/icon/emilys/128',
        city: 'Phoenix',
        country: 'United States',
      ),
    );
  }
}

class FakeThemeStorage extends Fake implements ThemeStorage {
  @override
  ThemeMode read() => ThemeMode.light;

  @override
  Future<void> write(ThemeMode mode) async {}
}

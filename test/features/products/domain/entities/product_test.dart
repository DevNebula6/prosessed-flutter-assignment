import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/products_page.dart';

void main() {
  Product product({double price = 100, double discount = 0, int stock = 5}) {
    return Product(
      id: 1,
      title: 'Phone',
      category: 'smartphones',
      price: price,
      discountPercentage: discount,
      rating: 4.5,
      stock: stock,
      thumbnail: 'thumbnail.webp',
    );
  }

  test('applies the discount percentage to the price', () {
    expect(product(price: 200, discount: 15).discountedPrice, 170);
    expect(product(price: 9.99).discountedPrice, 9.99);
  });

  test('is out of stock when stock is zero', () {
    expect(product(stock: 0).inStock, isFalse);
    expect(product(stock: 1).inStock, isTrue);
  });

  group('ProductsPage.hasMore', () {
    test('is true while items remain after this page', () {
      final page = ProductsPage(products: [product()], skip: 0, total: 2);

      expect(page.hasMore, isTrue);
    });

    test('is false on the last page', () {
      final page = ProductsPage(products: [product()], skip: 1, total: 2);

      expect(page.hasMore, isFalse);
    });

    test('is false for an empty result', () {
      const page = ProductsPage(products: [], skip: 0, total: 0);

      expect(page.hasMore, isFalse);
    });
  });
}

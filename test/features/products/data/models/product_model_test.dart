import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_category_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/models/products_page_model.dart';
import 'package:shopsphere/features/products/domain/entities/product_category.dart';
import 'package:shopsphere/features/products/domain/entities/review.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  test('parses a full product with images and reviews', () {
    final json = fixture('product.json') as Map<String, dynamic>;

    final product = ProductModel.fromJson(json).toEntity();

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.brand, 'Essence');
    expect(product.price, 9.99);
    expect(product.stock, 99);
    expect(product.description, startsWith('The Essence Mascara'));
    expect(product.images, hasLength(1));
    expect(product.reviews, hasLength(3));
    expect(
      product.reviews.first,
      Review(
        rating: 3,
        comment: 'Would not recommend!',
        date: DateTime.utc(2025, 4, 30, 9, 41, 2, 53),
        reviewerName: 'Eleanor Collins',
      ),
    );
  });

  test('parses a page of list items with only the selected fields', () {
    final json = fixture('products_page.json') as Map<String, dynamic>;

    final page = ProductsPageModel.fromJson(json).toEntity();

    expect(page.total, 194);
    expect(page.skip, 0);
    expect(page.products.map((product) => product.id), [1, 16]);

    final apple = page.products.last;
    expect(apple.brand, isNull);
    expect(apple.description, isEmpty);
    expect(apple.images, isEmpty);
    expect(apple.reviews, isEmpty);
  });

  test('parses categories', () {
    final json = fixture('categories.json') as List<dynamic>;

    final categories = json
        .map(
          (item) =>
              ProductCategoryModel.fromJson(item as Map<String, dynamic>)
                  .toEntity(),
        )
        .toList();

    expect(
      categories.first,
      const ProductCategory(slug: 'beauty', name: 'Beauty'),
    );
    expect(categories, hasLength(3));
  });
}

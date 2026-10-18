import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:shopsphere/features/wishlist/data/repositories/wishlist_repository_impl.dart';

class MockWishlistLocalDataSource extends Mock
    implements WishlistLocalDataSource {}

void main() {
  late MockWishlistLocalDataSource local;
  late WishlistRepositoryImpl repository;

  const apple = Product(
    id: 16,
    title: 'Apple',
    category: 'groceries',
    price: 1.99,
    discountPercentage: 12.62,
    rating: 4.19,
    stock: 8,
    thumbnail: 'thumbnail.webp',
  );

  setUpAll(() => registerFallbackValue(<ProductModel>[]));

  setUp(() {
    local = MockWishlistLocalDataSource();
    repository = WishlistRepositoryImpl(local);
  });

  test('loads the saved products', () {
    when(() => local.getProducts())
        .thenReturn([ProductModel.fromEntity(apple)]);

    expect(repository.loadWishlist(), [apple]);
  });

  test('starts empty when the saved list is unreadable', () {
    when(() => local.getProducts()).thenThrow(const FormatException());

    expect(repository.loadWishlist(), isEmpty);
  });

  test('saves the products in order', () async {
    when(() => local.saveProducts(any())).thenAnswer((_) async {});

    await repository.saveWishlist([apple]);

    final saved =
        verify(() => local.saveProducts(captureAny())).captured.single
            as List<ProductModel>;
    expect(saved.single.toEntity(), apple);
  });
}

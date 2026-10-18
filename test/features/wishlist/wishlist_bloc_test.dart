import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_bloc.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

Product product(int id) {
  return Product(
    id: id,
    title: 'Product $id',
    category: 'beauty',
    price: 10,
    discountPercentage: 0,
    rating: 4,
    stock: 5,
    thumbnail: 'thumbnail.webp',
  );
}

void main() {
  late MockWishlistRepository repository;

  setUp(() {
    repository = MockWishlistRepository();
    when(() => repository.loadWishlist()).thenReturn(const []);
    when(() => repository.saveWishlist(any())).thenAnswer((_) async {});
  });

  test('starts with the saved products', () {
    when(() => repository.loadWishlist()).thenReturn([product(1)]);

    final bloc = WishlistBloc(repository);

    expect(bloc.state.products, [product(1)]);
    expect(bloc.state.contains(1), isTrue);
  });

  blocTest<WishlistBloc, WishlistState>(
    'toggling a new product saves it at the top',
    build: () => WishlistBloc(repository),
    seed: () => WishlistState([product(1)]),
    act: (bloc) => bloc.add(WishlistToggled(product(2))),
    expect: () => [
      WishlistState([product(2), product(1)]),
    ],
    verify: (_) =>
        verify(() => repository.saveWishlist([product(2), product(1)]))
            .called(1),
  );

  blocTest<WishlistBloc, WishlistState>(
    'toggling a saved product removes it',
    build: () => WishlistBloc(repository),
    seed: () => WishlistState([product(1), product(2)]),
    act: (bloc) => bloc.add(WishlistToggled(product(1))),
    expect: () => [
      WishlistState([product(2)]),
    ],
  );

  blocTest<WishlistBloc, WishlistState>(
    'quick toggles are applied and saved in order',
    build: () => WishlistBloc(repository),
    act: (bloc) => bloc
      ..add(WishlistToggled(product(1)))
      ..add(WishlistToggled(product(2)))
      ..add(WishlistToggled(product(1))),
    expect: () => [
      WishlistState([product(1)]),
      WishlistState([product(2), product(1)]),
      WishlistState([product(2)]),
    ],
    verify: (_) =>
        verify(() => repository.saveWishlist([product(2)])).called(1),
  );

  blocTest<WishlistBloc, WishlistState>(
    'clearing empties the wishlist',
    build: () => WishlistBloc(repository),
    seed: () => WishlistState([product(1)]),
    act: (bloc) => bloc.add(const WishlistCleared()),
    expect: () => [const WishlistState()],
  );
}

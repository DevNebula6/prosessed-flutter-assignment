part of 'product_details_cubit.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductDetailsNotFound extends ProductDetailsState {
  const ProductDetailsNotFound();
}

final class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

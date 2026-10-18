import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._getProduct) : super(const ProductDetailsLoading());

  final GetProduct _getProduct;

  Future<void> load(int id) async {
    emit(const ProductDetailsLoading());
    final result = await _getProduct(id);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => ProductDetailsLoaded(value),
      Err(failure: NotFoundFailure()) => const ProductDetailsNotFound(),
      Err(:final failure) => ProductDetailsError(failure),
    });
  }
}

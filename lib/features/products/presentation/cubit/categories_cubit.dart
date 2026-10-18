import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/usecases/get_categories.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._getCategories) : super(const CategoriesLoading());

  final GetCategories _getCategories;

  Future<void> load() async {
    emit(const CategoriesLoading());
    final result = await _getCategories();
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => CategoriesLoaded(value),
      Err() => const CategoriesError(),
    });
  }
}

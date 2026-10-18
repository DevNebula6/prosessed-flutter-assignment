import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/product_sort.dart';
import '../models/product_category_model.dart';
import '../models/products_page_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this._dio);

  final Dio _dio;

  // Just what a product card needs, which keeps list pages small.
  static const _listFields =
      'title,price,discountPercentage,rating,stock,thumbnail,brand,category';

  Future<ProductsPageModel> getProducts({
    required String query,
    required String? category,
    required ProductSort sort,
    required int skip,
    required int limit,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _productsPath(query, category),
      queryParameters: {
        if (query.isNotEmpty) 'q': query,
        'limit': limit,
        'skip': skip,
        'select': _listFields,
        ..._sortParameters(sort),
      },
    );
    return ProductsPageModel.fromJson(response.data!);
  }

  Future<List<ProductCategoryModel>> getCategories() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.categories);
    return response.data!
        .map(
          (json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  static String _productsPath(String query, String? category) {
    if (query.isNotEmpty) return ApiEndpoints.searchProducts;
    if (category != null) return ApiEndpoints.productsByCategory(category);
    return ApiEndpoints.products;
  }

  static Map<String, String> _sortParameters(ProductSort sort) {
    return switch (sort) {
      ProductSort.relevance => const {},
      ProductSort.priceLowToHigh => const {'sortBy': 'price', 'order': 'asc'},
      ProductSort.priceHighToLow => const {'sortBy': 'price', 'order': 'desc'},
      ProductSort.rating => const {'sortBy': 'rating', 'order': 'desc'},
      ProductSort.title => const {'sortBy': 'title', 'order': 'asc'},
    };
  }
}

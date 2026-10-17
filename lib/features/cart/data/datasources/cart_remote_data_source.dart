import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this._dio);

  final Dio _dio;

  Future<OrderModel> placeOrder({
    required int userId,
    required List<CartItemModel> items,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.addCart,
      data: {
        'userId': userId,
        'products': [
          for (final item in items)
            {'id': item.product.id, 'quantity': item.quantity},
        ],
      },
    );
    return OrderModel.fromJson(response.data!);
  }
}

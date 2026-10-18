import '../../domain/entities/order.dart';

/// The `POST /carts/add` response. DummyJSON doesn't store the order, and it
/// rounds its totals to whole dollars, so the app keeps its own cart total.
class OrderModel {
  const OrderModel({required this.id, required this.totalQuantity});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  final int id;
  final int totalQuantity;

  Order toEntity() => Order(id: id, totalQuantity: totalQuantity);
}

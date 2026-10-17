import '../../domain/entities/order.dart';

/// The `POST /carts/add` response. DummyJSON works out the totals but
/// doesn't store anything.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.total,
    required this.discountedTotal,
    required this.totalQuantity,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      total: (json['total'] as num).toDouble(),
      discountedTotal: (json['discountedTotal'] as num).toDouble(),
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  final int id;
  final double total;
  final double discountedTotal;
  final int totalQuantity;

  Order toEntity() => Order(
    id: id,
    total: total,
    discountedTotal: discountedTotal,
    totalQuantity: totalQuantity,
  );
}

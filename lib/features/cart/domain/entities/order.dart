import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.total,
    required this.discountedTotal,
    required this.totalQuantity,
  });

  final int id;
  final double total;
  final double discountedTotal;
  final int totalQuantity;

  @override
  List<Object?> get props => [id, total, discountedTotal, totalQuantity];
}

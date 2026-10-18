import 'package:equatable/equatable.dart';

class Order extends Equatable {
  const Order({required this.id, required this.totalQuantity});

  final int id;
  final int totalQuantity;

  @override
  List<Object?> get props => [id, totalQuantity];
}

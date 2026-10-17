import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _cartKey = 'cart';

  List<CartItemModel> getItems() {
    final raw = _prefs.getString(_cartKey);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveItems(List<CartItemModel> items) {
    return _prefs.setString(
      _cartKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}

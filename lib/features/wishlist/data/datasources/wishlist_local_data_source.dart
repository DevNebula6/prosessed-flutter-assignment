import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../products/data/models/product_model.dart';

class WishlistLocalDataSource {
  WishlistLocalDataSource(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _wishlistKey = 'wishlist';

  List<ProductModel> getProducts() {
    final raw = _prefs.getString(_wishlistKey);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProducts(List<ProductModel> products) {
    return _prefs.setString(
      _wishlistKey,
      jsonEncode(products.map((product) => product.toJson()).toList()),
    );
  }
}

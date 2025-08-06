import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/CartModel.dart';

class CartService {
  static Future<List<CartModel>> loadCartData() async {
    final String response = await rootBundle.loadString('lib/src/data/cart_moc.json');
    final List<dynamic> data = await json.decode(response);
    return data.map((item) => CartModel.fromJson(item)).toList();
  }
}

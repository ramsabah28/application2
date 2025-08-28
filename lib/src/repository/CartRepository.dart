import 'package:application2/src/models/CartModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../exception/CartEmptyException.dart';

class CartRepository {
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> addToCart(String uuid, int count) async {
    final prefs = await _prefs;
    if (uuid.isEmpty || count <= 0) return;

    final cartString = prefs.getString('cart');
    Map<String, dynamic> cart = {};
    if (cartString != null && cartString.isNotEmpty) {
      try {
        cart = Map<String, dynamic>.from(jsonDecode(cartString));
      } catch (_) {
        throw CartParseException(
          'Failed to parse cart data from local storage.',
        );
      }
    }

    cart[uuid] = count;
    await prefs.setString('cart', jsonEncode(cart));
  }

  Future<List<CartModel>> getCart() async {}
}

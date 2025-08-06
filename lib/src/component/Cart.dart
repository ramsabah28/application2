import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CartModel.dart';
import '../services/CartService.dart';
import 'features/CartItemCard.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _Cart();
}

class _Cart extends State<Cart> {
  List<CartModel> cartItems = [];

  @override
  void initState() {
    super.initState();
    CartService.loadCartData().then((items) {
      setState(() {
        cartItems = items;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return cartItems.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return CartItemCard(item: item);
            },
          );
  }
}
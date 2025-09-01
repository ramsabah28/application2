import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CartModel.dart';


class CartService {
  static Future<List<CartModel>> loadCartData() async {
    final String response =
    await rootBundle.loadString('lib/src/data/cart_moc.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => CartModel.fromJson(item)).toList();
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Warenkorb"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<CartModel>>(
        future: CartService.loadCartData(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Fehler: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Dein Warenkorb ist leer"));
          }

          final cartItems = snapshot.data!;
          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(item.name),
                subtitle: Text("Menge: ${item.count}"),
                trailing: Text("${item.price} €"),
              );
            },
          );
        },
      ),
    );
  }
}

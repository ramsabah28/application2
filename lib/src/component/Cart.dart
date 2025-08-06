import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CartModel.dart';
import '../services/CartService.dart';
import 'features/CartItemCard.dart';
import 'features/PayKnowButton.dart';

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

  void updateItemCount(int index, int newCount) {
    setState(() {
      cartItems[index] = CartModel(
        name: cartItems[index].name,
        description: cartItems[index].description,
        category: cartItems[index].category,
        brand: cartItems[index].brand,
        count: newCount,
        price: cartItems[index].price,
        imageUrl: cartItems[index].imageUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.count),
    );
    double tax = totalPrice * 0.19;
    double shipmentCost = totalPrice > 0 ? 4.99 : 0.0;
    double priceWithoutTax = totalPrice - tax;
    double grandTotal = totalPrice + shipmentCost;

    return cartItems.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return CartItemCard(
                      item: item,
                      count: item.count,
                      onCountChanged: (newCount) =>
                          updateItemCount(index, newCount),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Divider(),
                    Text(
                      'Zwichensumme: ${priceWithoutTax.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'MwSt: ${tax.toStringAsFixed(2)}€',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Versandkosten: ${shipmentCost.toStringAsFixed(2)}€',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gesamtsumme: ${grandTotal.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    PayKnowButton(
                      onPressed: () {
                        // TODO: Implement payment logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment process started!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

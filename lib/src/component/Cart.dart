import 'package:flutter/material.dart';
import '../models/CartModel.dart';
import '../repository/CartRepository.dart';
import 'features/CartItemCard.dart';
import 'features/PayKnowButton.dart';
import '../services/BillService.dart';
import '../models/BillModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}
class _CartState extends State<Cart> {
  late Future<List<CartModel>> _cartFuture;
  List<CartModel> cartItems = [];
  @override
  void initState() {
    super.initState();
    _cartFuture = CartRepository().getCart();
  }

  void updateItemCount(int index, int newCount) async {
    final uuid = cartItems[index].uuid;
    if (newCount == 0) {
      setState(() {
        cartItems.removeAt(index);
      });
      await CartRepository().removeFromCart(uuid);
    } else {
      setState(() {
        cartItems[index] = CartModel(
          uuid: cartItems[index].uuid,
          name: cartItems[index].name,
          description: cartItems[index].description,
          category: cartItems[index].category,
          brand: cartItems[index].brand,
          count: newCount,
          price: cartItems[index].price,
          imageUrl: cartItems[index].imageUrl,
        );
      });
      await CartRepository().addToCart(uuid, newCount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CartModel>>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Fehler beim Laden des Warenkorbs.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Warenkorb ist leer.'));
        }

        cartItems = snapshot.data!;

        double totalPrice = cartItems.fold(
          0,
              (sum, item) => sum + (item.price * item.count),
        );
        double tax = totalPrice * 0.19;
        double shipmentCost = totalPrice > 0 ? 4.99 : 0.0;
        double priceWithoutTax = totalPrice - tax;
        double grandTotal = totalPrice + shipmentCost;

        return Column(
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
                  const Divider(),
                  Text(
                    'Zwischensumme: ${priceWithoutTax.toStringAsFixed(2)}€',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'MwSt: ${tax.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Versandkosten: ${shipmentCost.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gesamtsumme: ${grandTotal.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PayKnowButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bitte anmelden, um zu bezahlen.')),
                        );
                        return;
                      }

                      final items = cartItems
                          .map((ci) => BillItem(pid: ci.uuid, count: ci.count, price: ci.price))
                          .toList();
                      final totalItemsCount = cartItems.fold(0, (sum, item) => sum + item.count);

                      final bill = BillModel(
                        uuid: '',
                        UID: user.uid,
                        items: items,
                        count: totalItemsCount,
                        price: grandTotal,
                        BID: 0,
                        date: '',
                      );

                      try {
                        await BillService.addBill(bill);
                        await CartRepository().clearCart();
                        setState(() {
                          _cartFuture = CartRepository().getCart();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rechnung erstellt und Warenkorb geleert.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler beim Erstellen der Rechnung: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/CartModel.dart';
import '../repository/CartRepository.dart';
import 'features/CartItemCard.dart';
import 'features/PayKnowButton.dart';
import '../services/BillService.dart';
import '../models/BillModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:application2/src/payment/PaymentSelection.dart';
import '../services/InvoiceService.dart';
import '../models/InvoiceModel.dart';
import '../services/ProductService.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}
class _CartState extends State<Cart> {
  late Future<List<CartModel>> _cartFuture;
  List<CartModel> cartItems = [];
  Map<String, int> productStock = {}; // Store product stock from Firestore
  bool stockLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCartWithStock();
  }

  Future<List<CartModel>> _loadCartWithStock() async {
    final cartItems = await CartRepository().getCart();
    
    // Load stock for each product
    for (final item in cartItems) {
      try {
        final product = await ProductService.loadProduct(item.uuid);
        productStock[item.uuid] = product.count;
      } catch (e) {
        productStock[item.uuid] = 0;
      }
    }
    
    stockLoaded = true;
    return cartItems;
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
                    maxCount: productStock[item.uuid] ?? 0,
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
                  PayNowButton(
                    onPressed: () {
                      // Navigate to payment selection so the user can choose a payment method
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PaymentSelection(amount: grandTotal, currency: 'EUR'),
                      ));
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

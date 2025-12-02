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
import '../services/OrderService.dart';
import 'package:uuid/uuid.dart';

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

  String _generateInvoiceId(String uuid) {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final last4Digits = uuid.substring(uuid.length - 4);
    
    return '$year$month$day$last4Digits';
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
            // Bottom summary that can be tapped to expand
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.4,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            Text(
                              'Zwischensumme: ${priceWithoutTax.toStringAsFixed(2)}€',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'MwSt: ${tax.toStringAsFixed(2)}€',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Versandkosten: ${shipmentCost.toStringAsFixed(2)}€',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gesamtsumme: ${grandTotal.toStringAsFixed(2)}€',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Place Order Button (Direct Order)
                            PayNowButton(
                              label: 'Jetzt Kaufen',
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

                                // Generate UUID for both bill and order
                                final billUuid = const Uuid().v4();

                                final bill = BillModel(
                                  uuid: billUuid,
                                  UID: user.uid,
                                  items: items,
                                  count: totalItemsCount,
                                  price: grandTotal,
                                  BID: 0,
                                  date: '',
                                  InvoiceID: _generateInvoiceId(billUuid),
                                );

                                try {

                                  await BillService.addBill(bill);
                                  

                                  await OrderService.addOrder(
                                    uid: user.uid,
                                    billId: billUuid,
                                  );
                                  

                                  await CartRepository().clearCart();
                                  Navigator.pop(context);
                                  setState(() {
                                    _cartFuture = _loadCartWithStock();
                                  });
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Bestellung aufgegeben und Warenkorb geleert.')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Fehler beim Aufgeben der Bestellung: $e')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            // Pay Now Button (Payment Selection)
                            /**
                            PayNowButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PaymentSelection(amount: grandTotal, currency: 'EUR'),
                                ));
                              },
                            ),
                                **/
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gesamtsumme: ${grandTotal.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

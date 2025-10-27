import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';



///TODO: add InAppBill(productId: 'your_product_id', title: 'Buy Credits') for AppStore and PlayStore
class InAppBill extends StatefulWidget {
  final String productId;
  final String title;

  const InAppBill({super.key, required this.productId, required this.title});

  @override
  State<InAppBill> createState() => _InAppBillState();
}

class _InAppBillState extends State<InAppBill> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _available = false;
  List<ProductDetails> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(_onPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    _initStore();
  }

  Future<void> _initStore() async {
    setState(() => _loading = true);
    try {
      _available = await _iap.isAvailable();
      if (!_available) {
        setState(() => _loading = false);
        return;
      }
      final response = await _iap.queryProductDetails({widget.productId}.toSet());
      if (response.error != null) {
        debugPrint('Product query error: ${response.error}');
      }
      setState(() {
        _products = response.productDetails;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error initializing store: $e');
      setState(() => _loading = false);
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      debugPrint('Purchase updated: ${purchase.productID} ${purchase.status}');
      if (purchase.status == PurchaseStatus.pending) {
        // show pending UI
      } else if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // IMPORTANT: In production, verify the purchase with your backend/StoreKit server.
        // Here we simply deliver the product and complete the purchase.
        await _deliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kauf fehlgeschlagen: ${purchase.error}')));
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    // TODO: Grant the user the purchased entitlement (e.g. credits, feature unlock)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kauf erfolgreich — Danke!')));
    // You can also update Firestore / local state here.
  }

  Future<void> _buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    // For consumables use buyConsumable, for non-consumable use buyNonConsumable
    await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_available
              ? const Center(child: Text('In-App Purchases sind auf diesem Gerät nicht verfügbar'))
              : _products.isEmpty
                  ? const Center(child: Text('Produkt nicht gefunden'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Produkt: ${_products.first.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_products.first.description),
                          const SizedBox(height: 16),
                          Text('Preis: ${_products.first.price}'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _buyProduct(_products.first),
                            child: const Text('Kaufen'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _initStore,
                            child: const Text('Erneut laden'),
                          )
                        ],
                      ),
                    ),
    );
  }
}

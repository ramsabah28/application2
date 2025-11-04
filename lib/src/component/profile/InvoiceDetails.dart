import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:application2/src/services/ProductService.dart';
import 'package:application2/src/models/ProductModel.dart';

class InvoiceDetails extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetails({super.key, required this.invoiceId});

  Future<Map<String, dynamic>> _loadBill() async {
    final ref = FirebaseFirestore.instance.collection('bills').doc(invoiceId);
    final snap = await ref.get();
    if (!snap.exists) {
      return {'items': <Map<String, dynamic>>[], 'totalPrice': 0.0, 'paid': false, 'date': ''};
    }
    final data = snap.data() as Map<String, dynamic>;
    final List<dynamic> pidList = (data['pid'] as List?) ?? const [];
    final double totalPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
    final bool paid = (data['paid'] as bool?) ?? false;
    final Map<String, dynamic>? dateMap = data['date'] as Map<String, dynamic>?;
    final String dateStr = dateMap == null
        ? ''
        : '${dateMap['year']}-${dateMap['month']}-${dateMap['day']}';

    List<Map<String, dynamic>> items = [];
    for (final pid in pidList) {
      try {
        final product = await ProductService.loadProduct(pid.toString());
        items.add({'product': product, 'count': 1, 'price': product.price});
      } catch (_) {
        items.add({
          'product': ProductModel(
            uuid: pid.toString(),
            name: 'Unbekanntes Produkt',
            description: '',
            midDescription: '',
            longDiscription: '',
            category: '',
            brand: '',
            count: 0,
            price: 0.0,
            imageUrl: '',
          ),
          'count': 1,
          'price': 0.0,
        });
      }
    }
    return {'items': items, 'totalPrice': totalPrice, 'paid': paid, 'date': dateStr};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 243, 246, 1),
      appBar: AppBar(title: const Text('Rechnungsdetails'), backgroundColor:const Color.fromRGBO(243, 243, 246, 1) ,),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadBill(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Fehler beim Laden der Positionen.'));
          }
          final data = snapshot.data ?? {'items': <Map<String, dynamic>>[], 'totalPrice': 0.0, 'paid': false, 'date': ''};
          final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(data['items'] as List);
          final double totalPrice = data['totalPrice'] as double;
          final bool paid = data['paid'] as bool;
          final String dateStr = data['date'] as String;
          if (items.isEmpty) {
            return const Center(child: Text('Keine Positionen vorhanden.'));
          }
          return Column(
            children: [
              // Header with date and payment status
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Datum: $dateStr',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: paid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: paid ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        paid ? 'Bezahlt' : 'Offen',
                        style: TextStyle(
                          color: paid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Items list with total at the bottom
              Expanded(
                child: ListView.builder(
                  itemCount: items.length + 1, // +1 for the total section
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    // Show total section at the last index
                    if (index == items.length) {
                      return Column(
                        children: [
                          const Divider(height: 1, thickness: 1),
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Gesamtsumme',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${totalPrice.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    
                    // Show regular item
                    final item = items[index];
                    final product = item['product'] as ProductModel;
                    final price = item['price'] as double;
                    final count = item['count'] as int;
                    final totalItemPrice = price * count;
                    
                    return Column(
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              // Product image with left padding
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[400],
                                            size: 24,
                                          ),
                                        )
                                      : Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (product.brand.isNotEmpty)
                                      Text(
                                        product.brand,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'x$count',
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${price.toStringAsFixed(2)}€ je Stück',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Price with right padding
                              Container(
                                margin: const EdgeInsets.only(right: 16),
                                child: Text(
                                  '${totalItemPrice.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < items.length - 1) // Add divider between items, but not after the last item
                          const Divider(height: 1, thickness: 1),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



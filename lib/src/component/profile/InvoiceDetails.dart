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
      appBar: AppBar(title: const Text('Rechnungsdetails')),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(child: Text('Datum: $dateStr')),
                    Text(paid ? 'Bezahlt' : 'Offen', style: TextStyle(color: paid ? Colors.green : Colors.red)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['product'] as ProductModel;
                    final price = item['price'] as double;
                    final count = item['count'] as int;
                    return ListTile(
                      leading: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text(product.name),
                      subtitle: Text('${product.brand} • x$count'),
                      trailing: Text('${(price * count).toStringAsFixed(2)}€',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gesamtsumme', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${totalPrice.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



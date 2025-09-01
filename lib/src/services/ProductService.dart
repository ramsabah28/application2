import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ProductModel.dart';

class ProductService {
  static Future<List<ProductModel>> loadProductData() async {
    final String response = await rootBundle.loadString('lib/src/data/product_moc.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }
}


class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produkte"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: ProductService.loadProductData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Fehler: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Keine Produkte gefunden"));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: Text(product.name),
                subtitle: Text("${product.price} €"),
              );
            },
          );
        },
      ),
    );
  }
}

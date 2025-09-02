import 'package:flutter/material.dart';
import '../models/ProductModel.dart';
import '../services/ProductService.dart';
import 'features/ProductItemCard.dart';

class DynamicProductList extends StatefulWidget {
  const DynamicProductList({Key? key}) : super(key: key);

  @override
  State<DynamicProductList> createState() => _DynamicProductListState();
}

class _DynamicProductListState extends State<DynamicProductList> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.loadProductData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Fehler beim Laden der Produkte.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Produkte gefunden.'));
        }

        final products = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(2),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItemCard(item: product);
          },
        );
      },
    );
  }
}

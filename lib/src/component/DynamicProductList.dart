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
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final loadedProducts = await ProductService.loadProductData();
    setState(() {
      products = loadedProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(2),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItemCard(item: product);
      },
    );
  }
}

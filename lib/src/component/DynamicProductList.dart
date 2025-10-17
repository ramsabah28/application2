import 'package:flutter/material.dart';
import '../models/ProductModel.dart';
import '../services/ProductService.dart';
import 'features/ProductItemCard.dart';
import 'SwitchNavigation.dart';
import 'package:flutter/widgets.dart';

class DynamicProductList extends StatefulWidget {
  final int initialIndex;
  final String? category;
  const DynamicProductList({Key? key, this.initialIndex = 0, this.category}) : super(key: key);

  @override
  State<DynamicProductList> createState() => _DynamicProductListState();
}

class _DynamicProductListState extends State<DynamicProductList> {
  late Future<List<ProductModel>> _productsFuture;

  final PageStorageKey<String> _pageStorageKey = PageStorageKey<String>('dynamicProductList');
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.category == null || widget.category!.isEmpty
        ? ProductService.loadProductData()
        : ProductService.loadProductsByCategory(widget.category!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(widget.initialIndex * 100.0);
      }
    });
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
          key: _pageStorageKey,
          controller: _scrollController,
          padding: const EdgeInsets.all(2),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItemCard(
              item: product,
              uuid: product.uuid,
              onTap: () {
                final navState = context.findAncestorStateOfType<SwitchNavigationState>();
                navState?.showDynamicProductContent(product.uuid, productIndex: index);
              },
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/ProductModel.dart';
import '../services/ProductService.dart';
import 'features/ProductItemCard.dart';
import 'SwitchNavigation.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

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

  static const LinearGradient _shimmerGradient = LinearGradient(
    colors: [Color(0xFFEBEBF4), Color(0xFFFFFFFF), Color(0xFFEBEBF4)],
    stops: [0.1, 0.2, 0.3],
    begin: Alignment(-1.0, -0.6),
    end: Alignment(1.0, 0.8),
    tileMode: TileMode.clamp,
  );

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      key: const PageStorageKey<String>('dynamicProductList_loading'),
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Shimmer(
                  gradient: _shimmerGradient,
                  period: const Duration(milliseconds: 900),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer(
                        gradient: _shimmerGradient,
                        period: const Duration(milliseconds: 900),
                        child: Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Shimmer(
                        gradient: _shimmerGradient,
                        period: const Duration(milliseconds: 900),
                        child: Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer(
                        gradient: _shimmerGradient,
                        period: const Duration(milliseconds: 900),
                        child: Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
          return _buildLoadingSkeleton();
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

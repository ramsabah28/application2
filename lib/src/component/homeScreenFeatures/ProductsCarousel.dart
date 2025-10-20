import 'package:flutter/material.dart';
import '../../models/ProductModel.dart';
import '../../services/ProductService.dart';
import '../features/ShimmerImageFromNetwork.dart';
import '../SwitchNavigation.dart';

class ProductsCarousel extends StatefulWidget {
  const ProductsCarousel({super.key});

  @override
  State<ProductsCarousel> createState() => _ProductsCarouselState();
}

class _ProductsCarouselState extends State<ProductsCarousel> {
  late Future<List<ProductModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductService.loadProductData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<ProductModel>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator(color: theme.primaryColor)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final list = snapshot.data!;
        final items = (list.toList()..shuffle()).take(10).toList();

        return SizedBox(
          height: 320,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final Product = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: InkWell(
                  onTap: () {
                    final navState = context.findAncestorStateOfType<SwitchNavigationState>();
                    navState?.showDynamicProductContent(Product.uuid, productIndex: 0);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: ShimmerImageFromNetwork(
                            imageUrl: Product.imageUrl,
                            height: 200,
                            width: double.infinity,
                            shimmerBottomInset: 0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Text(
                            Product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                          child: Text(
                            Product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
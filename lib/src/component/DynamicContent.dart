import 'package:flutter/material.dart';
import '../repository/CartRepository.dart';
import 'features/AddInCartButton.dart';
import 'features/FavButton.dart';
import '../services/ProductService.dart';
import 'features/ShimmerImageFromNetwork.dart';
import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'features/FullscreenImageViewer.dart';

class DynamicContent extends StatelessWidget {
  final String uuid;

  const DynamicContent({super.key, required this.uuid});

  static const LinearGradient _shimmerGradient = LinearGradient(
    colors: [Color(0xFFEBEBF4), Color(0xFFFFFFFF), Color(0xFFEBEBF4)],
    stops: [0.1, 0.2, 0.3],
    begin: Alignment(-1.0, -0.6),
    end: Alignment(1.0, 0.8),
    tileMode: TileMode.clamp,
  );

  Widget _buildLoadingSkeleton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand line
            Shimmer(
              gradient: _shimmerGradient,
              period: const Duration(milliseconds: 900),
              child: Container(
                height: 14,
                width: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title line
            Shimmer(
              gradient: _shimmerGradient,
              period: const Duration(milliseconds: 900),
              child: Container(
                height: 26,
                width: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Image block
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Shimmer(
                    gradient: _shimmerGradient,
                    period: const Duration(milliseconds: 900),
                    child: Container(
                      height: 350, // Updated to match the new image container height
                      width: screenWidth * 0.96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Description lines
            Shimmer(
              gradient: _shimmerGradient,
              period: const Duration(milliseconds: 900),
              child: Container(
                height: 14,
                width: screenWidth * 0.9,
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
                width: screenWidth * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Price line
            Shimmer(
              gradient: _shimmerGradient,
              period: const Duration(milliseconds: 900),
              child: Container(
                height: 22,
                width: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: Shimmer(
                    gradient: _shimmerGradient,
                    period: const Duration(milliseconds: 900),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Shimmer(
                  gradient: _shimmerGradient,
                  period: const Duration(milliseconds: 900),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProductService.loadProduct(uuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSkeleton(context);
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler: \\${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Produkt nicht gefunden'));
        }
        final product = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 16),
                // Product Images Slider
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            height: 350, // Further increased for better portrait display
                            width: screenWidth * 0.96,
                            child: Builder(
                              builder: (_) {
                                final List<String> urls = [
                                  product.imageUrl,
                                  ...product.images
                                      .where((e) => e is Map && e['url'] != null)
                                      .map<String>((e) => (e as Map)['url'].toString())
                                ];
                                final uniqueUrls = urls.toSet().toList();
                                return PageView.builder(
                                  itemCount: uniqueUrls.length,
                                  itemBuilder: (context, idx) {
                                    final u = uniqueUrls[idx];
                                    return Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => FullscreenImageViewer(
                                                imageUrls: uniqueUrls,
                                                initialIndex: idx,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: 'image_viewer_${idx}_$u',
                                          child: Container(
                                            height: 350,
                                            width: screenWidth * 0.96,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: ShimmerImageFromNetwork(
                                                imageUrl: u,
                                                height: 350,
                                                width: screenWidth * 0.96,
                                                shimmerBottomInset: 12,
                                                fit: BoxFit.cover, // Cover fit to fill the container
                                                alignment: Alignment.center, // Center the image for better composition
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Description
                Text(product.description, style: const TextStyle(fontSize: 15)),
                SizedBox(height: 16),
                // Price
                Text(
                  '${product.price.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    AddInCartButton(
                      onPressed: () async {
                        try {
                          final cartRepo = CartRepository();
                          print(uuid);
                          await cartRepo.addToCart(uuid, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Produkt zum Warenkorb hinzugefügt!',
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Fehler beim Hinzufügen zum Warenkorb: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 4),
                    FavButton(),
                  ],
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 8),
                if (product.midDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      product.midDescription,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                if (product.longDiscription.isNotEmpty)
                  Text(
                    product.longDiscription,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
              ],
            ),
          ),
        );
      }, // End of FutureBuilder builder
    ); // End of FutureBuilder
  }
}

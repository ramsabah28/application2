import 'package:flutter/material.dart';
import '../repository/CartRepository.dart';
import 'features/AddInCartButton.dart';
import 'features/FavButton.dart';
import '../services/ProductService.dart';
import 'dart:ui';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';


class DynamicContent extends StatelessWidget {
  final String uuid;

  const DynamicContent({super.key, required this.uuid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProductService.loadProduct(uuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                // Product Image
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.network(
                            product.imageUrl,
                            height: 200,
                            width: screenWidth * 0.96,
                            fit: BoxFit.contain,
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
                // ...existing code...
              ],
            ),
          ),
        );
      }, // End of FutureBuilder builder
    ); // End of FutureBuilder
  }
}

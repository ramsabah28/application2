import 'package:flutter/material.dart';
import '../../models/ProductModel.dart';
import 'AddInCartButton.dart';
import 'FavButton.dart';
import 'Rating.dart';

class ProductItemCard extends StatelessWidget {
  final ProductModel item;
  final VoidCallback? onTap;

  const ProductItemCard({Key? key, required this.item, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(5),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 8),
                      child: Container(
                        width: 120,
                        height: 250,
                        color: Colors.white,
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 1,
                          maxScale: 10,
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.brand,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(item.description),
                        Text(
                          item.price.toString() + "€",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        Text(
                          item.count >= 1 ? "Verfügbar" : "Nicht verfügbar",
                          style: TextStyle(
                            color: item.count >= 1 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Rating(ratingCount: 120, ratingValue: 3.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavButton(
                  onPressed: () {
                    // TODO: Add to favorites logic
                  },
                ),
                SizedBox(width: 8),
                AddInCartButton(
                  onPressed: () {
                    // TODO: Add to cart logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

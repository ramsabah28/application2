import 'package:application2/src/component/SwitchNavigation.dart';
import 'package:flutter/material.dart';
import '../../models/ProductModel.dart';
import '../../repository/CartRepository.dart';
import 'AddInCartButton.dart';
import 'FavButton.dart';
import 'Rating.dart';
import '../../component/features/ShimmerImageFromNetwork.dart';
import '../../services/FavoritService.dart';

class ProductItemCard extends StatelessWidget {
  final ProductModel item;
  final VoidCallback? onTap;
  final String uuid;

  const ProductItemCard({
    Key? key,
    required this.item,
    this.onTap,
    required this.uuid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final state = context.findAncestorStateOfType<SwitchNavigationState>();
        state?.showDynamicProductContent(uuid);
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, left: 8),
                        child: Container(
                          width: 200,
                          height: 250,
                          color: Colors.white,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 1,
                            maxScale: 10,
                            child: ShimmerImageFromNetwork(
                              imageUrl: item.imageUrl,
                              height: 200,
                              width: 200,
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
                          Text(item.description.length > 20
                              ? item.description.substring(0, 50) + '…'
                              : item.description),
                          Text(
                            "${item.price}€",
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
                          //TODO: use the ReviewService.dart to get the Rating from Firestore(use the uuid of the product)
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
                    onPressed: () async {
                      final added = await FavoritService.addToFavorites(uuid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added ? 'Zu Favoriten hinzugefügt!' : 'Bereits in Favoriten!'
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  AddInCartButton(
                    onPressed: () async {
                      try {
                        final cartRepo = CartRepository();
                        final uuid = (item as dynamic).uuid ?? '';
                        print(uuid);
                        await cartRepo.addToCart(uuid, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Produkt zum Warenkorb hinzugefügt!')),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

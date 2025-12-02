import 'package:application2/src/component/SwitchNavigation.dart';
import 'package:flutter/material.dart';
import '../../models/ProductModel.dart';
import '../../repository/CartRepository.dart';
import 'AddInCartButton.dart';
import 'FavButton.dart';
import 'Rating.dart';
import '../../component/features/ShimmerImageFromNetwork.dart';
import '../../services/FavoritService.dart';
import '../../services/ReviewService.dart';

class ProductItemCard extends StatefulWidget {
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
  State<ProductItemCard> createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard> {
  double averageRating = 0.0;
  int reviewCount = 0;
  bool isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadRatingData();
  }

  Future<void> _loadRatingData() async {
    try {
      final rating = await ReviewService.getAverageRating(widget.uuid);
      final count = await ReviewService.getReviewCount(widget.uuid);
      
      if (mounted) {
        setState(() {
          averageRating = rating;
          reviewCount = count;
          isLoadingRating = false;
        });
      }
    } catch (e) {
      print('Error loading rating data: $e');
      if (mounted) {
        setState(() {
          isLoadingRating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final state = context.findAncestorStateOfType<SwitchNavigationState>();
        state?.showDynamicProductContent(widget.uuid);
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
                              imageUrl: widget.item.imageUrl,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
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
                                  widget.item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.item.brand,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${widget.item.price}€",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            widget.item.count >= 1 ? "Verfügbar" : "Nicht verfügbar",
                            style: TextStyle(
                              color: widget.item.count >= 1 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Real-time rating from ReviewService
                          isLoadingRating
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Loading rating...', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                )
                              : Rating(
                                  ratingCount: reviewCount,
                                  ratingValue: averageRating,
                                ),
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
                      final added = await FavoritService.addToFavorites(widget.uuid);
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
                        final uuid = (widget.item as dynamic).uuid ?? '';
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

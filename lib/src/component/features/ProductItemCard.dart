import 'package:flutter/material.dart';
import '../../models/CartModel.dart';

class ProductItemCard extends StatelessWidget {
  final CartModel item;
  final VoidCallback? onTap;

  const ProductItemCard({Key? key, required this.item, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.white,
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 3,
                      child: Image.network(item.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    item.brand,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(item.description),
                  Text(
                    item.price.toString() + "€",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.count >= 1 ? "Verfügbar" : "Nicht verfügbar",
                    style: TextStyle(
                      color: item.count >= 1 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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

import 'package:flutter/material.dart';
import '../../models/CartModel.dart';
import '../../data/CustomColors.dart';

class CartItemCard extends StatelessWidget {
  final CartModel item;

  const CartItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Container(
          width: 120,
          height: 120,
          color: Colors.white,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1,
            maxScale: 3,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),

        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CustomColors.primaryDark,
            fontSize: 28,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: ${item.brand}'),
            Text('Category: ${item.category}'),
            Text('Description: ${item.description}'),
            Text('Count: ${item.count}'),
            Text('Price: ${item.price}'),
          ],
        ),
      ),
    );
  }
}

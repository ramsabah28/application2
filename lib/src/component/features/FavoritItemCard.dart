import 'package:flutter/material.dart';
import '../../models/ProductModel.dart';

class FavoritItemCard extends StatelessWidget {
	final ProductModel product;
	final VoidCallback? onRemove;

	const FavoritItemCard({Key? key, required this.product, this.onRemove}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Card(
			color: Colors.white,
			margin: EdgeInsets.all(10),
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
										child: Image.network(product.imageUrl, fit: BoxFit.contain),
									),
								),
							),
							SizedBox(height: 8),
							IconButton(
								icon: Icon(Icons.delete_outline),
								onPressed: onRemove,
							),
						],
					),
					SizedBox(width: 30),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									product.name,
									style: TextStyle(
										fontWeight: FontWeight.bold,
										color: Theme.of(context).primaryColor,
										fontSize: 20,
									),
								),
								Text(
									product.brand,
									style: TextStyle(fontWeight: FontWeight.bold),
								),
								Text(product.description),
								Text(
									"${product.price}\u20ac",
									style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
								),
								Text(
									product.count >= 1 ? "Verfügbar" : "Nicht verfügbar",
									style: TextStyle(
										color: product.count >= 1 ? Colors.green : Colors.red,
										fontWeight: FontWeight.bold,
									),
								),
							],
						),
					),
				],
			),
		);
	}
}
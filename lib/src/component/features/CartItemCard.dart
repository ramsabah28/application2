import 'package:flutter/material.dart';
import '../../models/CartModel.dart';
import '../../data/CustomColors.dart';
import 'CountButton.dart';

class CartItemCard extends StatefulWidget {
  final CartModel item;

  const CartItemCard({Key? key, required this.item}) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.item.count;
  }

  void _increment() {
    setState(() {
      count++;
    });
  }

  void _decrement() {
    setState(() {
      if (count > 0) count--;
    });
  }

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
              Container(
                width: 100,
                height: 100,
                color: Colors.white,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 3,
                  child: Image.network(widget.item.imageUrl, fit: BoxFit.contain),
                ),
              ),
              SizedBox(height: 8),
              CountButton(
                count: count,
                onIncrement: _increment,
                onDecrement: _decrement,
              ),
            ],
          ),
          SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primery,
                    fontSize: 28,
                  ),
                ),
                Text(
                  widget.item.brand,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.item.description),
                Text(
                  widget.item.price.toString() + "€",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.item.count >= 1 ? "Available" : "Not available",
                  style: TextStyle(
                    color: widget.item.count >= 1 ? Colors.green : Colors.red,
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

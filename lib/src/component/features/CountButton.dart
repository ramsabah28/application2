import 'package:flutter/material.dart';

class CountButton extends StatelessWidget {
  final int count;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const CountButton({
    Key? key,
    required this.count,
    this.onIncrement,
    this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: onDecrement,
        ),
        Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

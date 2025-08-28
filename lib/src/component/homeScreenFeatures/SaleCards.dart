import 'package:flutter/material.dart';

class SaleCards extends StatelessWidget {
  const SaleCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(10),
      child: SizedBox(
        height: 100,
        child: Center(
          child: Text(
            '30% Off',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
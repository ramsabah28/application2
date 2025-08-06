import 'package:flutter/material.dart';

class DynamicProductList extends StatelessWidget {
  const DynamicProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Dynamic Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

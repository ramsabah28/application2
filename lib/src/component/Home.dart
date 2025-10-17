import 'package:flutter/material.dart';
import 'homeScreenFeatures/ProductsCarousel.dart';
import 'homeScreenFeatures/SaleCard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SaleCards(),
        SizedBox(height: 12),
        const ProductsCarousel(),
        SizedBox(height: 10),
      ],
    );
  }
}

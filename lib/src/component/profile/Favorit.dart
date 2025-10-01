import 'package:flutter/material.dart';
import '../features/CartItemCard.dart';
import '../MainBar.dart';

class Favorit extends StatefulWidget {
  const Favorit({Key? key}) : super(key: key);

  @override
  State<Favorit> createState() => _FavoritState();
}

class _FavoritState extends State<Favorit> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Favorit Placeholder',
        style: TextStyle(fontSize: 24, color: Colors.grey),
      ),
    );
  }
}

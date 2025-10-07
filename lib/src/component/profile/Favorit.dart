import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ProductService.dart';

class Favorit extends StatefulWidget {
  const Favorit({Key? key}) : super(key: key);

  @override
  State<Favorit> createState() => _FavoritState();
}

class _FavoritState extends State<Favorit> {
  // List<String> _favoriteUuids = [];
  bool _loading = true;
  List<dynamic> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final uuids = prefs.getStringList('favorites') ?? [];
    List<dynamic> products = [];
    for (final uuid in uuids) {
      try {
        final product = await ProductService.loadProduct(uuid);
        products.add(product);
      } catch (e) {

      }
    }
    setState(() {
      _favoriteProducts = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_favoriteProducts.isEmpty) {
      return Center(
        child: Text(
          'Keine Favoriten gefunden.',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return Center(
          child: Text(product),
        );
      },
    );
  }
}
// Duplicate build method removed

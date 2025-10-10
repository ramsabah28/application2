import 'package:flutter/material.dart';

import '../models/ProductModel.dart';

class SearchOverlayEntry extends StatelessWidget {
  final VoidCallback onClose;
  final List results;
  const SearchOverlayEntry({Key? key, required this.onClose, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Search Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? Center(child: Text('No results'))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final product = results[index];
                            return ListTile(
                              leading: product.imageUrl != null
                                  ? Image.network(product.imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                                  : null,
                              title: Text(product.name),
                              subtitle: Text(product.brand ?? ''),
                              trailing: Text('€${product.price.toString()}'),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SearchOverlayEntry extends StatelessWidget {
  final VoidCallback onClose;
  const SearchOverlayEntry({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            width: 300,
            height: 200,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Search Overlay', style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                Text('Type to search for products...'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onClose,
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
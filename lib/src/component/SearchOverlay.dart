import 'package:flutter/material.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({Key? key}) : super(key: key);

  @override
  SearchOverlayState createState() => SearchOverlayState();
}

class SearchOverlayState extends State<SearchOverlay> {
  bool _visible = false;

  void showOverlay(BuildContext context) {
    setState(() {
      _visible = true;
    });
  }

  void hideOverlay() {
    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return SizedBox.shrink();
    return Positioned.fill(
      child: Container(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
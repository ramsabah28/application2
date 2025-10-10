import 'package:application2/src/data/CustomColors.dart';
import 'package:flutter/material.dart';
import '../services/ProductService.dart';
import 'SearchOverlayEntry.dart';

class MainBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBack;

  const MainBar({super.key, this.showBackArrow = false, this.onBack});

  @override
  State<MainBar> createState() => _MainBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainBarState extends State<MainBar> {
  OverlayEntry? _searchOverlayEntry;
  List searchResults = [];

  void hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  void showSearchOverlay() {
    if (_searchOverlayEntry != null) return;
    _searchOverlayEntry = OverlayEntry(
      builder: (context) => SearchOverlayEntry(
        onClose: hideSearchOverlay,
        results: searchResults,
      ),
    );
    Overlay.of(context).insert(_searchOverlayEntry!);
  }

  void updateSearchOverlay(List results) {
    setState(() {
      searchResults = results;
    });
    if (_searchOverlayEntry != null) {
      _searchOverlayEntry!.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColors.secondary,
      elevation: 0,
  leading: widget.showBackArrow
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: CustomColors.primery),
              onPressed:
                  widget.onBack ??
                  () {
                    Navigator.of(context).maybePop();
                  },
            )
          : null,
      title: Container(
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) {
                    showSearchOverlay();
                  } else {
                    hideSearchOverlay();
                  }
                },
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search...',
                  ),
                  style: const TextStyle(fontSize: 16),
                  onTap: () {
                    showSearchOverlay();
                  },
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      final results = await ProductService.searchProducts(value);
                      updateSearchOverlay(results);
                      if (_searchOverlayEntry == null) {
                        showSearchOverlay();
                      }
                    } else {
                      updateSearchOverlay([]);
                    }
                  },
                  onEditingComplete: () {
                    hideSearchOverlay();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: CustomColors.primery),
          onPressed: () {},
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:application2/src/data/CustomColors.dart';
import 'package:flutter/material.dart';
import '../services/ProductService.dart';
import 'SearchOverlayEntry.dart';

class MainBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBack;

  const MainBar({super.key, this.showBackArrow = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    OverlayEntry? _searchOverlayEntry;

    void hideSearchOverlay() {
      _searchOverlayEntry?.remove();
      _searchOverlayEntry = null;
    }

    void showSearchOverlay() {
      if (_searchOverlayEntry != null) return;
      _searchOverlayEntry = OverlayEntry(
        builder: (context) => SearchOverlayEntry(onClose: hideSearchOverlay),
      );
      Overlay.of(context).insert(_searchOverlayEntry!);
    }

    return AppBar(
      backgroundColor: CustomColors.secondary,
      elevation: 0,
      leading: showBackArrow
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: CustomColors.primery),
              onPressed:
                  onBack ??
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
                    // Firestore search by product name
                    if (value.isNotEmpty) {
                      final results = await ProductService.searchProducts(value);
                      // TODO: show the result as
                      print('Search results: \\n' + results.map((e) => e.name).join(', '));
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

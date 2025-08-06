import 'package:application2/src/data/CustomColors.dart';
import 'package:flutter/material.dart';
import '../data/CustomColors.dart';

class MainBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBack;

  const MainBar({super.key, this.showBackArrow = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColors.secondary,
      elevation: 0,
      leading: showBackArrow
          ? IconButton(
              icon:  Icon(Icons.arrow_back, color: CustomColors.primery),
              onPressed: onBack ?? () {
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
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: CustomColors.primery),
          onPressed: () {

          },
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

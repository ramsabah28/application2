import 'package:application2/src/data/CustomColors.dart';
import 'package:flutter/material.dart';
import '../data/CustomColors.dart';
import 'Home.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBar();
}

class _CustomNavigationBar extends State<CustomNavigationBar> {
  int __selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: CustomColors.secondary,
      destinations: <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: CustomColors.primery),
          label: "Home",
          selectedIcon: Icon(Icons.home, color: CustomColors.primery),
        ),
        NavigationDestination(
          icon: Icon(Icons.list_outlined, color: CustomColors.primery),
          label: 'Category',
          selectedIcon: Icon(Icons.list, color: CustomColors.primery),
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined, color: CustomColors.primery),
          label: 'Cart',
          selectedIcon: Icon(Icons.shopping_bag, color: CustomColors.primery),
        ),
      ],
    );
  }
}

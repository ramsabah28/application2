import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBar();
}

class _CustomNavigationBar extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    var Color = Theme.of(context).primaryColor;
    return NavigationBar(
      indicatorColor: Colors.white,
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onItemTapped,
      backgroundColor: Theme.of(context).primaryColorLight,
      destinations: <Widget>[
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: Theme.of(context).primaryColor,
          ),
          label: "Home",
          selectedIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.list_outlined,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Category',
          selectedIcon: Icon(Icons.list, color: Theme.of(context).primaryColor),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.shopping_bag_outlined,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Cart',
          selectedIcon: Icon(
            Icons.shopping_bag,
            color: Theme.of(context).primaryColor,
          ),
        ),
        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: Theme.of(context).primaryColor,
          ),
          label: 'Profile',
          selectedIcon: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

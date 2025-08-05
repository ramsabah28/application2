import 'package:application2/src/data/CustomColors.dart';
import 'package:flutter/material.dart';


class CustomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  
  const CustomNavigationBar({
    super.key, 
    required this.selectedIndex, 
    required this.onItemTapped
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBar();
}

class _CustomNavigationBar extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onItemTapped,
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
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: CustomColors.primery),
          label: 'Profile',
          selectedIcon: Icon(Icons.person, color: CustomColors.primery),
        ),
      ],
    );
  }
}

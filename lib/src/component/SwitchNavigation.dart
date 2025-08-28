import 'package:flutter/material.dart';
import 'Home.dart';
import 'Category.dart';
import 'Cart.dart';
import 'MainBar.dart';
import '../data/CustomColors.dart';
import 'CustomNavigationBar.dart';
import 'Profile.dart';
import 'DynamicProductList.dart';

class SwitchNavigation extends StatefulWidget {
  const SwitchNavigation({super.key});

  @override
  State<SwitchNavigation> createState() => SwitchNavigationState();
}

class SwitchNavigationState extends State<SwitchNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [Home(), Category(), Cart(), Profile()];
  Widget? _overrideScreen;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _overrideScreen = null;
    });
  }

  void showDynamicProductList() {
    setState(() {
      _overrideScreen = DynamicProductList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _overrideScreen ?? _screens[_selectedIndex],
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      backgroundColor: CustomColors.secondary,
      appBar: _overrideScreen != null
          ? MainBar(
              showBackArrow: true,
              onBack: () {
                setState(() {
                  _overrideScreen = null;
                });
              },
            )
          : MainBar(),
    );
  }
}

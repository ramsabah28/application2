import 'package:flutter/material.dart';
import 'Home.dart';
import 'Category.dart';
import 'Cart.dart';
import 'MainBar.dart';
import '../data/CustomColors.dart';
import 'CustomNavigationBar.dart';

class SwitchNavigation extends StatefulWidget {
  const SwitchNavigation({super.key});

  @override
  State<SwitchNavigation> createState() => _SwitchNavigation();
}

class _SwitchNavigation extends State<SwitchNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [Home(), Category(), Cart()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: CustomColors.primery,
        secondaryHeaderColor: CustomColors.secondary,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
        backgroundColor: CustomColors.secondary,
        appBar: MainBar(),
      ),
    );
  }
}

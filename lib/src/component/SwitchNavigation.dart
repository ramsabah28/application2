import 'package:flutter/material.dart';
import 'Home.dart';
import 'Category.dart';
import 'Cart.dart';
import 'MainBar.dart';
import '../data/CustomColors.dart';
import 'CustomNavigationBar.dart';
import 'profile/Profile.dart';
import 'DynamicProductList.dart';
import 'DynamicContent.dart';

class SwitchNavigation extends StatefulWidget {
  const SwitchNavigation({super.key});

  @override
  State<SwitchNavigation> createState() => SwitchNavigationState();
}

class SwitchNavigationState extends State<SwitchNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [Home(), Category(), Cart(), Profile()];
  Widget? _overrideScreen;
  int? _lastProductIndex;

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

  void showDynamicProductContent(String uuid, {int? productIndex}) {
    setState(() {
      _overrideScreen = DynamicContent(uuid: uuid);
      _lastProductIndex = productIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _overrideScreen == null && _selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_overrideScreen != null) {
          setState(() {
            if (_overrideScreen is DynamicContent) {
              _overrideScreen = DynamicProductList(
                initialIndex: _lastProductIndex ?? 0,
              );
            } else {
              _overrideScreen = null;
            }
          });
          return;
        }
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }
      },
      child: Scaffold(
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
                    if (_overrideScreen is DynamicContent) {
                      _overrideScreen = DynamicProductList(
                        initialIndex: _lastProductIndex ?? 0,
                      );
                    } else {
                      _overrideScreen = null;
                    }
                  });
                },
              )
            : MainBar(),
      ),
    );
  }
}

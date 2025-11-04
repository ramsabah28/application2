import 'package:flutter/material.dart';
import 'Home.dart';
import 'Category.dart';
import 'Cart.dart';
import 'MainBar.dart';
import '../data/CustomColors.dart';
import 'CustomNavigationBar.dart';
import 'profile/Profile.dart';
import 'profile/Adress.dart';
import 'profile/Favorit.dart';
import 'profile/Invoice.dart';
import 'profile/Order.dart';
import 'profile/UserReview.dart';
import 'DynamicProductList.dart';
import 'DynamicContent.dart';

class SwitchNavigation extends StatefulWidget {
  const SwitchNavigation({super.key});

  @override
  State<SwitchNavigation> createState() => SwitchNavigationState();
}

class SwitchNavigationState extends State<SwitchNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Home(), 
    Category(), 
    Cart(), 
    Profile()
  ];
  Widget? _overrideScreen;
  int? _lastProductIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _overrideScreen = null;
    });
  }

  void showDynamicProductList({String? category}) {
    setState(() {
     _overrideScreen = DynamicProductList(category: category);
    });
  }

  void showDynamicProductContent(String uuid, {int? productIndex}) {
    setState(() {
      _overrideScreen = DynamicContent(uuid: uuid);
      _lastProductIndex = productIndex;
    });
  }

  // Profile sub-screen navigation methods
  void showProfileAddress() {
    setState(() {
      _overrideScreen = AdressScreen();
    });
  }

  void showProfileOrders() {
    setState(() {
      _overrideScreen = Order();
    });
  }

  void showProfileInvoices() {
    setState(() {
      _overrideScreen = Invoice();
    });
  }

  void showProfileFavorites() {
    setState(() {
      _overrideScreen = Favorit();
    });
  }

  void showProfileUserReview() {
    setState(() {
      _overrideScreen = UserReview();
    });
  }

  void backToProfile() {
    setState(() {
      _selectedIndex = 3;
      _overrideScreen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _overrideScreen == null && _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_overrideScreen != null) {
          setState(() {
            if (_overrideScreen is DynamicContent) {
              _overrideScreen = DynamicProductList(
                initialIndex: _lastProductIndex ?? 0,
              );
            } else if (_overrideScreen is AdressScreen || 
                       _overrideScreen is Order || 
                       _overrideScreen is Invoice || 
                       _overrideScreen is Favorit ||
                       _overrideScreen is UserReview) {
              // Back to Profile for profile sub-screens
              _selectedIndex = 3;
              _overrideScreen = null;
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
        body: _overrideScreen ?? (_selectedIndex == 3 
            ? Profile(
                onShowAddress: showProfileAddress,
                onShowOrders: showProfileOrders,
                onShowInvoices: showProfileInvoices,
                onShowFavorites: showProfileFavorites,
                onShowUserReview: showProfileUserReview,
              )
            : _screens[_selectedIndex]),
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
                    } else if (_overrideScreen is AdressScreen || 
                               _overrideScreen is Order || 
                               _overrideScreen is Invoice || 
                               _overrideScreen is Favorit ||
                               _overrideScreen is UserReview) {
                      // Back to Profile for profile sub-screens
                      _selectedIndex = 3;
                      _overrideScreen = null;
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

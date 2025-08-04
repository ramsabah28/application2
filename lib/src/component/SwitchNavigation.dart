import 'package:flutter/material.dart';
import 'Home.dart';
import 'CustomAppBar.dart';
import '../data/CustomColors.dart';
import 'CustomNavigationBar.dart';

class SwitchNavigation extends StatefulWidget {
  const SwitchNavigation({super.key});

  @override
  State<SwitchNavigation> createState() => _SwitchNavigation();
}

class _SwitchNavigation extends State<SwitchNavigation> {

  final List<Widget> _screens = [
    Home()
  ];

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
        bottomNavigationBar:CustomNavigationBar() ,
        backgroundColor: CustomColors.secondary,
        appBar: AppBar(backgroundColor: CustomColors.secondary),
      ),
    );
  }
}

import 'package:application2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'src/component/SwitchNavigation.dart';
import 'src/data/CustomColors.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PocketStore',
      theme: ThemeData(
        primaryColor: CustomColors.primery,
        primaryColorDark: CustomColors.primaryDark,
        primaryColorLight: CustomColors.secondary,
        secondaryHeaderColor: CustomColors.secondary,
        brightness: Brightness.light,
      ),
      home: SwitchNavigation(),
    );
  }
}

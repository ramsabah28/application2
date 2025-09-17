import 'package:application2/firebase_options.dart';
import 'package:application2/src/security/authentication/AuthRepository.dart';
import 'package:application2/src/security/authentication/FirebaseAuthRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'src/component/SwitchNavigation.dart';
import 'src/data/CustomColors.dart';

Future<void> main() async {
  final AuthRepository auth = FirebaseAuthRepository();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(auth: auth));
}

class MyApp extends StatelessWidget {
  final AuthRepository auth;

  const MyApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        return MaterialApp(
          key: Key(snapshot.data?.uid ?? "no-user-id"),
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
      },
    );
  }
}

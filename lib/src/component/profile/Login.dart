import 'package:application2/src/component/features/LoginAndRegisterButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application2/src/provider/AuthProvider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/Logo.png',
                    height: 200,
                  ),
                  SizedBox(height: 100),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color:Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (authProvider.errorMessage != null)
                    Text(
                      authProvider.errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 16),
                  LoginAndRegisterButton(
                    label: "Login",
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            authProvider.login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

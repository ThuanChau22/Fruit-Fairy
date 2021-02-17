import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/create_account.dart';
import 'package:fruitfairy/screens/login_screen.dart';
import 'package:fruitfairy/screens/login-signup.dart';

void main() => runApp(FruitFairy());

class FruitFairy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      initialRoute: LoginSignUpScreen.id,
      routes: {
        LoginSignUpScreen.id: (context) => LoginSignUpScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CreateAccount.id: (context) => CreateAccount(),
      },
    );
  }
}

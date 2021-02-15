import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/welcome_screen.dart';
import 'package:fruitfairy/screens/login_screen.dart';

void main() => runApp(FruitFairy());

class FruitFairy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
      },
    );
  }
}

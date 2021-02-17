import 'package:flutter/material.dart';

import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fruitfairy/screens/create_account.dart';
import 'package:fruitfairy/screens/login_screen.dart';
import 'package:fruitfairy/screens/login-signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FruitFairy());
}

class FruitFairy extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      initialRoute:
          _auth.currentUser == null ? SignOptionScreen.id : HomeScreen.id,
      routes: {
        SignOptionScreen.id: (context) => SignOptionScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        HomeScreen.id: (context) => HomeScreen(),

        //TODO: conflict
        LoginSignUpScreen.id: (context) => LoginSignUpScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CreateAccount.id: (context) => CreateAccount(),
      },
    );
  }
}

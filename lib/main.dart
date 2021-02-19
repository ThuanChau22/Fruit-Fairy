import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/reset_password_screen.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_donor_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/screens/signup_role_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        ResetPasswordScreen.id: (context) => ResetPasswordScreen(),
        SignUpRoleScreen.id: (context) => SignUpRoleScreen(),
        SignUpDonorScreen.id: (context) => SignUpDonorScreen(),
        HomeScreen.id: (context) => HomeScreen(),
      },
    );
  }
}


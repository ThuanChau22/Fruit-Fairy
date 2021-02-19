import 'package:flutter/material.dart';
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
  final User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    bool signedIn = user != null && user.emailVerified;
    return MaterialApp(
      theme: ThemeData.light().copyWith(),
      initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        SignOptionScreen.id: (context) => SignOptionScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        SignUpRoleScreen.id: (context) => SignUpRoleScreen(),
        SignUpDonorScreen.id: (context) => SignUpDonorScreen(),
      },
    );
  }
}

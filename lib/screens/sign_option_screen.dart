import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_screen.dart';

class SignOptionScreen extends StatefulWidget {
  static const String id = 'auth_option_screen';
  @override
  _SignOptionScreenState createState() => _SignOptionScreenState();
}

class _SignOptionScreenState extends State<SignOptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Text('Sign In'),
                onPressed: () {
                  Navigator.pushNamed(context, SignInScreen.id);
                },
              ),
              FlatButton(
                child: Text('Sign Up'),
                onPressed: () {
                  Navigator.pushNamed(context, SignUpScreen.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

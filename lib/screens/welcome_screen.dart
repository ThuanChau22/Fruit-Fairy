import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
    if (_auth.currentUser == null) {
      Navigator.of(context).pushNamed(SignOptionScreen.id);
    } else {
      Navigator.of(context).pushNamed(HomeScreen.id);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/fruitbackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.white.withOpacity(0.50),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 100.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FRUIT FAIRY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.0),
                Text(
                  'Solve Food Waste One Donation\nAt A Time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

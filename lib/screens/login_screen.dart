import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const String id = 'login_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFF05e5c),
          child: Center(
            child: Text(
              'Sign In/Sign Up Screen',
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_role_screen.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class SignOptionScreen extends StatefulWidget {
  static const String id = 'sign_option_screen';
  @override
  _SignOptionScreenState createState() => _SignOptionScreenState();
}

class _SignOptionScreenState extends State<SignOptionScreen> {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: ScrollableLayout(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fairyLogo(),
                SizedBox(height: screen.height * 0.03),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.25,
                  ),
                  child: Column(
                    children: [
                      signInButton(context),
                      signUpButton(context),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget fairyLogo() {
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: 60,
        radius: 105,
      ),
    );
  }

  Widget signInButton(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.02),
      child: RoundedButton(
        label: 'Sign In',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          Navigator.of(context).pushNamed(SignInScreen.id);
        },
      ),
    );
  }

  Widget signUpButton(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.02),
      child: RoundedButton(
        label: 'Sign Up',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          Navigator.of(context).pushNamed(SignUpRoleScreen.id);
        },
      ),
    );
  }
}

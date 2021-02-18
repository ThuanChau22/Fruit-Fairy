import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_role_screen.dart';

class SignOptionScreen extends StatefulWidget {
  static const String id = 'sign_option_screen';
  @override
  _SignOptionScreenState createState() => _SignOptionScreenState();
}

class _SignOptionScreenState extends State<SignOptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Column(
      //     children: [
      //       Text(
      //         'Solve Food Waste ',
      //         textAlign: TextAlign.center,
      //         style: TextStyle(),
      //       ),
      //       Text(
      //         'One Donation At A Time',
      //         textAlign: TextAlign.center,
      //         style: TextStyle(),
      //       ),
      //     ],
      //   ),
      //   backgroundColor: kAppBarColor,
      // ),
      backgroundColor: kBackroundColor,
      body: SafeArea(
        child: ScrollableLayout(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: FruitFairyLogo.id,
                  child: FruitFairyLogo(
                    fontSize: 40.0,
                    radius: 95.0,
                  ),
                ),
                SizedBox(height: 24.0),
                RoundedButton(
                  label: 'Sign In',
                  labelColor: kBackroundColor,
                  backgroundColor: kLabelColor,
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignInScreen.id);
                  },
                ),
                RoundedButton(
                  label: 'Sign Up',
                  labelColor: kBackroundColor,
                  backgroundColor: kLabelColor,
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignUpRoleScreen.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

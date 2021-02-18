import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_role_screen.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:flutter_circular_text/circular_text.dart';

class SignOptionScreen extends StatefulWidget {
  static const String id = 'sign_option_screen';
  @override
  _SignOptionScreenState createState() => _SignOptionScreenState();
}

class _SignOptionScreenState extends State<SignOptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackroundColor,
      body: SafeArea(
        child: ScrollableLayout(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      CircularText(
                        children: [
                          TextItem(
                            text: Text(
                              'Fruit Fairy',
                              style: TextStyle(
                                fontFamily: 'Pacifico',
                                color: Colors.white,
                                fontSize: 40.0,
                              ),
                            ),
                            space: 10,
                            startAngle: -85,
                            startAngleAlignment: StartAngleAlignment.center,
                            direction: CircularTextDirection.clockwise,
                          ),
                        ],
                        radius: 105.0,
                        position: CircularTextPosition.outside,
                        backgroundPaint: Paint()..color = Colors.transparent,
                      ),
                      CircleAvatar(
                        radius: 95.0,
                        backgroundImage: AssetImage('images/Fairy-Fruit.png'),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 150.0,
                ),
                RoundedButton(
                  label: 'Sign In',
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(SignInScreen.id);
                  },
                ),
                RoundedButton(
                  label: 'Sign Up',
                  color: Colors.white,
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

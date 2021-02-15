import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  void transition() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(LoginScreen.id);
  }

  @override
  void initState() {
    super.initState();
    transition();
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
            color: Color(0xAAFFFFFF),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 80.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FRUIT FAIRYsss',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.0,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  'Solve Food Waste One Donation\nAt A Time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40.0,
                    color: Color(0x77000000),
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

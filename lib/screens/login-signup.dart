import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/login_screen.dart';
import 'package:fruitfairy/widgets/roundedbutton.dart';
import 'package:flutter_circular_text/circular_text.dart';

class LoginSignUpScreen extends StatelessWidget {
  static const String id = 'LoginSignUpScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF05e5c),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
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
                    backgroundPaint: Paint()..color = Color(0xFFF05e5c),
                  ),
                  CircleAvatar(
                    radius: 100.0,
                    backgroundImage: AssetImage('images/Fairy-Fruit.png'),
                    backgroundColor: Colors.green.shade100,
                  ),
                ],
              ),

              SizedBox(
                height: 150.0,
              ),
              RoundedButton(
                  label: 'Sign In',
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.id);
                  },
                  ),
              RoundedButton(
                  label: 'Sign Up', color: Colors.white, onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

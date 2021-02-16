import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text/model.dart';
import 'package:flutter_circular_text/circular_text/widget.dart';
import 'package:fruitfairy/widgets/roundedbutton.dart';

import '../constant.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF05e5c),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign In'),
        backgroundColor: Color(0xFFF05e5c),
      ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      backgroundPaint: Paint()..color = Color(0xFFF05e5c),
                    ),
                    CircleAvatar(
                      radius: 100.0,
                      backgroundImage: AssetImage('images/Fairy-Fruit.png'),
                      backgroundColor: Colors.green.shade100,
                    ),
                  ],
                ),
              ),

              // ListTile(
              //   leading: CircleAvatar(
              //    // radius: 50.0,
              //     backgroundImage: AssetImage('images/Fairy-Fruit.png'),
              //     backgroundColor: Colors.green.shade100,
              //   ),
              //   title: Text('Fruit Fairy',
              //   style: TextStyle(
              //     fontFamily: 'Pacifico',
              //     color: Colors.white,
              //     fontSize: 40.0,
              //   ),),
              // ),
               SizedBox(
                height: 24.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.left,
                onChanged: (value) {},
                decoration: kTextFieldDecoration.copyWith(hintText: 'Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.left,
                onChanged: (value) {},
                decoration: kTextFieldDecoration.copyWith(hintText: 'Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
               //ToDo: the button color and the wording color
                  label: 'Sign In', color: Colors.white, onPressed: null,),
            ]),
      ),
    );
  }
}

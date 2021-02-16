import 'package:flutter/material.dart';
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
              ListTile(
                leading: CircleAvatar(
                 // radius: 50.0,
                  backgroundImage: AssetImage('images/Fairy-Fruit.png'),
                  backgroundColor: Colors.green.shade100,
                ),
                title: Text('Fruit Fairy',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  color: Color(0xFFF05e5c),
                  fontSize: 40.0,
                ),),
              ),
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
                  label: 'Sign In', color: Colors.green, onPressed: null),
            ]),
      ),
    );
  }
}

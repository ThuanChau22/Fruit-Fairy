import 'package:flutter/material.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignInScreen extends StatefulWidget {
  static const String id = 'signin_screen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showSpinner = false;
  String _email;
  String _password;

  void _signIn() async {
    setState(() => _showSpinner = true);
    try {
      UserCredential registeredUser = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (registeredUser != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(HomeScreen.id);
      }
    } catch (e) {
      print(e.message);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: ScrollableLayout(
            child: Container(
              padding: EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                    label: 'Email',
                    value: _email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                  SizedBox(height: 20.0),
                  InputField(
                    label: 'Password',
                    value: _password,
                    obscureText: true,
                    onChanged: (value) {
                      _password = value;
                    },
                  ),
                  FlatButton(
                    child: Text('Sign In'),
                    onPressed: _signIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

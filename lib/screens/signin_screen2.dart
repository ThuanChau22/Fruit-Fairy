import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignInScreen2 extends StatefulWidget {
  static const String id = 'signin_screen2';

  @override
  _SignInScreen2State createState() => _SignInScreen2State();
}

class _SignInScreen2State extends State<SignInScreen2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showSpinner = false;
  String _email = '';
  String _password = '';

  String _emailError = '';
  String _passwordError = '';
  String _signInError = '';

  bool _isValid() {
    String errors = '';
    setState(() {
      errors += _emailError = Validate.checkEmail(
        email: _email,
      );
      errors += _passwordError = Validate.checkPassword(
        password: _password,
      );
    });
    return errors.isEmpty;
  }

  void _signIn() async {
    if (!_isValid()) {
      return;
    }

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
      _signInError = 'Incorrect Email/Password. Please try again!';
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackroundColor,
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool isscrolled) {
            return [
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Text('Sign In'),
                backgroundColor: kAppBarColor,
                floating: true,
                forceElevated: isscrolled,
                actions: [],
              ),
            ];
          },
          body: ScrollableLayout(
            child: Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.15,
                right: MediaQuery.of(context).size.width * 0.15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: FruitFairyLogo.id,
                    child: FruitFairyLogo(
                      fontSize: 30.0,
                      radius: 85.0,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  InputField(
                    label: 'Email',
                    value: _email,
                    keyboardType: TextInputType.emailAddress,
                    errorMessage: _emailError,
                    onChanged: (value) => setState(() {
                      _email = value;
                      _emailError = Validate.checkEmail(
                        email: _email,
                      );
                    }),
                  ),
                  SizedBox(height: 5.0),
                  InputField(
                    label: 'Password',
                    value: _password,
                    obscureText: true,
                    errorMessage: _passwordError,
                    onChanged: (value) => setState(() {
                      _password = value;
                      _passwordError = Validate.checkPassword(
                        password: _password,
                      );
                    }),
                  ),
                  SizedBox(height: 15.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: RoundedButton(
                      label: 'Sign In',
                      labelColor: kBackroundColor,
                      backgroundColor: kLabelColor,
                      onPressed: _signIn,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    _signInError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kErrorColor,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

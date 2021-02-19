import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/reset_password_screen.dart';
import 'package:fruitfairy/utils/Validation.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_circular_text/circular_text/model.dart';
import 'package:flutter_circular_text/circular_text/widget.dart';

class SignInScreen extends StatefulWidget {
  static const String id = 'signin_screen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign In'),
        backgroundColor: kAppBarColor,
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: ScrollableLayout(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.15,
              ),
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
                                  fontSize: 30.0,
                                ),
                              ),
                              space: 10,
                              startAngle: -85,
                              startAngleAlignment: StartAngleAlignment.center,
                              direction: CircularTextDirection.clockwise,
                            ),
                          ],
                          radius: 95.0,
                          position: CircularTextPosition.outside,
                          backgroundPaint: Paint()..color = Colors.transparent,
                        ),
                        CircleAvatar(
                          radius: 85.0,
                          backgroundImage: AssetImage('images/Fairy-Fruit.png'),
                          backgroundColor: Colors.green.shade100,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
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
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ResetPasswordScreen.id,
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontSize: 12,  decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: RoundedButton(
                      label: 'Sign In',
                      color: Colors.white,
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

import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/screens/reset_password_screen.dart';
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

  String _email = '';
  String _password = '';

  String _emailError = '';
  String _passwordError = '';

  BuildContext _scaffoldContext;

  void showConfirmEmailMessage() {
    MessageBar(
      scaffoldContext: _scaffoldContext,
      //TODO: add check email message
      message: 'check email',
    ).show();
  }

  bool _validate() {
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
    if (_validate()) {
      setState(() => _showSpinner = true);
      try {
        UserCredential registeredUser = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        if (registeredUser != null) {
          if (!registeredUser.user.emailVerified) {
            await registeredUser.user.sendEmailVerification();
            showConfirmEmailMessage();
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.id,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (e.code == 'too-many-requests') {
          showConfirmEmailMessage();
        } else {
          MessageBar(
            scaffoldContext: _scaffoldContext,
            message: 'Incorrect Email or Password. Please try again!',
          ).show();
        }
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCredential userCredential = ModalRoute.of(context).settings.arguments;
      if (userCredential != null &&
          userCredential.additionalUserInfo.isNewUser) {
        showConfirmEmailMessage();
      }
    });
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
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          return SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.15,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: FruitFairyLogo.id,
                          child: FruitFairyLogo(
                            fontSize: 25.0,
                            radius: 60.0,
                          ),
                        ),
                        SizedBox(height: 24.0),
                        emailInputField(),
                        SizedBox(height: 5.0),
                        passwordInputField(),
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
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.0),
                        signInButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputField emailInputField() {
    return InputField(
      label: 'Email',
      value: _email,
      keyboardType: TextInputType.emailAddress,
      errorMessage: _emailError,
      onChanged: (value) {
        setState(() {
          _email = value.trim();
          _emailError = Validate.checkEmail(
            email: _email,
          );
        });
      },
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  InputField passwordInputField() {
    return InputField(
      label: 'Password',
      value: _password,
      obscureText: true,
      errorMessage: _passwordError,
      onChanged: (value) {
        setState(() {
          _password = value;
          _passwordError = Validate.checkPassword(
            password: _password,
          );
        });
      },
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  Padding signInButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Sign In',
        labelColor: kBackgroundColor,
        backgroundColor: kLabelColor,
        onPressed: () {
          _signIn();
        },
      ),
    );
  }
}

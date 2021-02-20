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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignInScreen extends StatelessWidget {
  static const String id = 'signin_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return SafeArea(
            child: SignIn(context),
          );
        },
      ),
    );
  }
}

class SignIn extends StatefulWidget {
  final BuildContext scaffoldContext;

  const SignIn(this.scaffoldContext);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _showSpinner = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  String _emailError = '';
  String _passwordError = '';

  Future<void> getCredentials() async {
    setState(() => _showSpinner = true);
    try {
      Map<String, String> credentials = await _storage.readAll();
      if (credentials.isNotEmpty) {
        setState(() {
          _email.text = credentials.entries.first.key;
          _password.text = credentials.entries.first.value;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  Future<void> saveCredentials() async {
    await _storage.deleteAll();
    if (_rememberMe) {
      setState(() => _showSpinner = true);
      try {
        await _storage.write(key: _email.text, value: _password.text);
      } catch (e) {
        print(e);
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  void showConfirmEmailMessage() {
    MessageBar(
      widget.scaffoldContext,
      message: 'Please check your email for a verification link',
    ).show();
  }

  bool _validate() {
    String errors = '';
    setState(() {
      errors += _emailError = Validate.checkEmail(
        email: _email.text,
      );
      errors += _passwordError = Validate.checkPassword(
        password: _password.text,
      );
    });
    return errors.isEmpty;
  }

  void _signIn() async {
    if (_validate()) {
      setState(() => _showSpinner = true);
      try {
        UserCredential registeredUser = await _auth.signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        if (registeredUser != null) {
          if (!registeredUser.user.emailVerified) {
            await registeredUser.user.sendEmailVerification();
            showConfirmEmailMessage();
          } else {
            await saveCredentials();
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.id,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (e.code == 'too-many-requests') {
          MessageBar(
            widget.scaffoldContext,
            message: 'Please check your email or sign in again shortly',
          ).show();
        } else {
          MessageBar(
            widget.scaffoldContext,
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
    getCredentials();
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
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(kAppBarColor),
      ),
      child: ScrollableLayout(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.15,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fairyLogo(),
                SizedBox(height: 24.0),
                emailInputField(),
                SizedBox(height: 10.0),
                passwordInputField(),
                optionTile(),
                SizedBox(height: 15.0),
                signInButton(context),
                SizedBox(height: 30.0),
                forgotPasswordLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Hero fairyLogo() {
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: MediaQuery.of(context).size.width * 0.07,
        radius: MediaQuery.of(context).size.width * 0.15,
      ),
    );
  }

  Widget emailInputField() {
    return InputField(
      label: 'Email',
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      errorMessage: _emailError,
      onChanged: (value) {
        setState(() {
          _email = value.trim();
          _emailError = Validate.checkEmail(
            email: _email.text,
          );
        });
      },
      onTap: () {
        MessageBar(widget.scaffoldContext).hide();
      },
    );
  }

  Widget passwordInputField() {
    return InputField(
      label: 'Password',
      controller: _password,
      obscureText: _obscureText,
      errorMessage: _passwordError,
      onChanged: (value) {
        setState(() {
          _password = value;
          _passwordError = Validate.checkPassword(
            password: _password.text,
          );
        });
      },
      onTap: () {
        MessageBar(widget.scaffoldContext).hide();
      },
    );
  }

  Widget optionTile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: kLabelColor,
                ),
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: kLabelColor,
                  checkColor: kBackgroundColor,
                  onChanged: (bool value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  },
                ),
              ),
            ),
            Text(
              'Remember me',
              style: TextStyle(
                color: kLabelColor,
                fontSize: 16,
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: kLabelColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget signInButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
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

  Widget forgotPasswordLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ResetPasswordScreen.id);
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: kLabelColor,
            fontSize: 16,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

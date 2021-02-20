import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

enum AuthMode { SignIn, Reset }

class SignInScreen extends StatefulWidget {
  static const String id = 'signin_screen';
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  AuthMode _mode = AuthMode.SignIn;
  String appBarLabel = 'Sign In';
  String buttonLabel = 'Sign In';
  String navigationLinkLabel = 'Forgot Password?';

  bool _showSpinner = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  String _emailError = '';
  String _passwordError = '';

  BuildContext _scaffoldContext;

  void getCredentials() async {
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

  void saveCredentials() async {
    await _storage.deleteAll();
    if (_rememberMe) {
      setState(() => _showSpinner = true);
      try {
        await _storage.write(
          key: _email.text.trim(),
          value: _password.text,
        );
      } catch (e) {
        print(e);
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  void showConfirmEmailMessage() {
    MessageBar(
      _scaffoldContext,
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
          email: _email.text.trim(),
          password: _password.text,
        );
        if (registeredUser != null) {
          if (!registeredUser.user.emailVerified) {
            await registeredUser.user.sendEmailVerification();
            showConfirmEmailMessage();
          } else {
            saveCredentials();
            Navigator.of(context).pushNamedAndRemoveUntil(
              HomeScreen.id,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (e.code == 'too-many-requests') {
          MessageBar(
            _scaffoldContext,
            message: 'Please check your email or sign in again shortly',
          ).show();
        } else {
          MessageBar(
            _scaffoldContext,
            message: 'Incorrect Email or Password. Please try again!',
          ).show();
        }
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  void _resetPassword() async {
    setState(() {
      _emailError = Validate.checkEmail(
        email: _email.text,
      );
    });
    if (_emailError.isEmpty) {
      setState(() => _showSpinner = true);
      try {
        await _auth.sendPasswordResetEmail(email: _email.text.trim());
        buttonLabel = 'Re-send';
      } catch (e) {
        print(e);
      } finally {
        setState(() => _showSpinner = false);
      }
      // TODO: Send email reset password message
      MessageBar(
        _scaffoldContext,
        message: 'Email sent',
      ).show();
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
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text(appBarLabel),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          return SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kAppBarColor),
              ),
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.15,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      fairyLogo(),
                      SizedBox(height: 24.0),
                      emailInputField(),
                      Visibility(
                        visible: _mode == AuthMode.SignIn,
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            passwordInputField(),
                            optionTile(),
                            SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                      signInButton(context),
                      SizedBox(height: 30.0),
                      navigationLink(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget fairyLogo() {
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
          _emailError = Validate.checkEmail(
            email: _email.text,
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
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
          _passwordError = Validate.checkPassword(
            password: _password.text,
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
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
                  checkColor: kPrimaryColor,
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
        vertical: 16.0,
        horizontal: MediaQuery.of(context).size.width * 0.15,
      ),
      child: RoundedButton(
        label: buttonLabel,
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          _mode == AuthMode.SignIn ? _signIn() : _resetPassword();
        },
      ),
    );
  }

  Widget navigationLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_mode == AuthMode.SignIn) {
              _mode = AuthMode.Reset;
              appBarLabel = 'Reset Password';
              buttonLabel = 'Send';
              navigationLinkLabel = 'Back to Sign In';
            } else {
              _mode = AuthMode.SignIn;
              appBarLabel = 'Sign In';
              buttonLabel = 'Sign In';
              navigationLinkLabel = 'Forgot Password?';
            }
          });
        },
        child: Text(
          navigationLinkLabel,
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

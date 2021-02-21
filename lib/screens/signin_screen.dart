import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/label_link.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

enum AuthMode { SignIn, Phone, Reset }

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

  bool _showSpinner = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  String _emailError = '';
  String _passwordError = '';

  BuildContext _scaffoldContext;

  void _getCredential() async {
    setState(() => _showSpinner = true);
    try {
      Map<String, String> credentials = await _storage.readAll();
      if (credentials.isNotEmpty) {
        setState(() {
          _email.text = credentials[kStoreEmail];
          _password.text = credentials[kStorePassword];
          _rememberMe = true;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  void _storeCredential() async {
    await _storage.deleteAll();
    if (_rememberMe) {
      setState(() => _showSpinner = true);
      try {
        await _storage.write(key: kStoreEmail, value: _email.text.trim());
        await _storage.write(key: kStorePassword, value: _password.text);
      } catch (e) {
        print(e);
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  bool _validate() {
    String errors = '';
    setState(() {
      switch (_mode) {
        case AuthMode.Reset:
          errors += _emailError = Validate.checkEmail(
            email: _email.text,
          );
          break;

        // Sign In Mode
        default:
          errors += _emailError = Validate.checkEmail(
            email: _email.text,
          );
          errors += _passwordError = Validate.checkPassword(
            password: _password.text,
          );
          break;
      }
    });
    return errors.isEmpty;
  }

  void submit() async {
    if (_validate()) {
      setState(() => _showSpinner = true);
      switch (_mode) {
        case AuthMode.Reset:
          try {
            await _auth.sendPasswordResetEmail(email: _email.text.trim());
            buttonLabel = 'Re-send';
            MessageBar(
              _scaffoldContext,
              message: 'Reset password email sent',
            ).show();
          } catch (e) {
            print(e);
          }
          break;

        // Sign In Mode
        default:
          try {
            UserCredential user = await _auth.signInWithEmailAndPassword(
              email: _email.text.trim(),
              password: _password.text,
            );
            if (user != null) {
              if (!_auth.currentUser.emailVerified) {
                await _auth.currentUser.sendEmailVerification();
                await _auth.signOut();
                _showConfirmEmailMessage();
              } else {
                _storeCredential();
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
          }
          break;
      }
      setState(() => _showSpinner = false);
    }
  }

  void _showConfirmEmailMessage() {
    MessageBar(
      _scaffoldContext,
      message: 'Please check your email for verification link',
    ).show();
  }

  @override
  void initState() {
    super.initState();

    _getCredential();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserCredential user = ModalRoute.of(context).settings.arguments;
      if (user != null && user.additionalUserInfo.isNewUser) {
        _showConfirmEmailMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
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
                    vertical: screen.height * 0.03,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      fairyLogo(),
                      SizedBox(height: screen.height * 0.03),
                      layoutMode(),
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
    Size screen = MediaQuery.of(context).size;
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: screen.width * 0.07,
        radius: screen.width * 0.15,
      ),
    );
  }

  Widget layoutMode() {
    Size screen = MediaQuery.of(context).size;
    switch (_mode) {
      case AuthMode.Reset:
        return Column(
          children: [
            Text(
              'Enter email for password reset:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kLabelColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screen.height * 0.02),
            emailInputField(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.05),
            signInLink(context),
          ],
        );
        break;

      case AuthMode.Phone:
        return Column(
          children: [
            phoneNumberField(),
            submitButton(context),
            SizedBox(height: screen.height * 0.05),
            signInLink(context),
          ],
        );
        break;

      // Sign In Mode
      default:
        return Column(
          children: [
            SizedBox(height: screen.height * 0.02),
            emailInputField(),
            SizedBox(height: screen.height * 0.01),
            passwordInputField(),
            optionTile(),
            SizedBox(height: screen.height * 0.02),
            submitButton(context),
            SizedBox(height: screen.height * 0.03),
            forgotPasswordLink(context),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screen.height * 0.01),
              child: Divider(color: kLabelColor, thickness: 2.0),
            ),
            phoneLink(context),
          ],
        );
        break;
    }
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

  Widget phoneNumberField() {
    return InputField(
      label: 'Phone Number',
      onChanged: (value) {},
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

  Widget submitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
      ),
      child: RoundedButton(
        label: buttonLabel,
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          submit();
        },
      ),
    );
  }

  Widget forgotPasswordLink(BuildContext context) {
    return LabelLink(
      label: 'Forgot Password?',
      onTap: () {
        setState(() {
          _mode = AuthMode.Reset;
          appBarLabel = 'Reset Password';
          buttonLabel = 'Send';
        });
      },
    );
  }

  Widget phoneLink(BuildContext context) {
    return LabelLink(
      label: 'Sign in with phone number',
      onTap: () {
        setState(() {
          _mode = AuthMode.Phone;
          appBarLabel = 'Sign In with Phone Number';
          buttonLabel = 'Continue';
        });
      },
    );
  }

  Widget signInLink(BuildContext context) {
    return LabelLink(
      label: 'Back to Sign In',
      onTap: () {
        setState(() {
          _mode = AuthMode.SignIn;
          appBarLabel = 'Sign In';
          buttonLabel = 'Sign In';
        });
      },
    );
  }
}

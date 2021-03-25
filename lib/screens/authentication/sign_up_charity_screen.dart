import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/validation.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class SignUpCharityScreen extends StatefulWidget {
  static const String id = 'signup_charity_screen';

  @override
  _SignUpCharityScreenState createState() => _SignUpCharityScreenState();
}

class _SignUpCharityScreenState extends State<SignUpCharityScreen> {
  final TextEditingController _ein = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();


  String _einError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  bool _showSpinner = false;
  bool _obscurePassword = true;

  bool _validate() {
    String errors = '';
    errors += _einError = Validate.name(
      label: 'EIN',
      name: _ein.text.trim(),
    );

    errors += _emailError = Validate.email(_email.text.trim());
    errors += _passwordError = Validate.password(_password.text);
    errors += _confirmPasswordError = Validate.confirmPassword(
      password: _password.text,
      confirmPassword: _confirmPassword.text,
    );
    return errors.isEmpty;
  }

  void _signUp() async {
    if (_validate()) {
      setState(() => _showSpinner = true);
      try {
        String email = _email.text.trim();
        String password = _password.text;
        FireAuthService auth = context.read<FireAuthService>();
        String notifyMessage = await auth.signUp(
          email: email,
          password: password,
          //TODO: make ein a parameter inside the the signUP method
          //EIN: _EIN.text.trim(),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          SignInScreen.id,
              (route) {
            return route.settings.name == SignOptionScreen.id;
          },
          arguments: {
            SignInScreen.email: email,
            SignInScreen.password: password,
            SignInScreen.message: notifyMessage,
          },
        );
      } catch (errorMessage) {
        MessageBar(context, message: errorMessage).show();
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        MessageBar(context).hide();
        return true;
      },
      child: GestureWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text('Sign Up')),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.06,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      einNameInputField(),
                      inputFieldSizeBox(),
                      emailInputField(),
                      inputFieldSizeBox(),
                      passwordInputField(),
                      inputFieldSizeBox(),
                      confirmPasswordInputField(),
                      SizedBox(height: screen.height * 0.05),
                      signUpButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputFieldSizeBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
  }

  Widget einNameInputField() {
    return InputField(
      label: 'EIN',
      controller: _ein,
      errorMessage: _einError,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _einError = Validate.name(
            label: 'first name',
            name: _ein.text.trim(),
          );
        });
      },
    );
  }
  Widget emailInputField() {
    return InputField(
      label: 'Email',
      controller: _email,
      errorMessage: _emailError,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _emailError = Validate.email(_email.text.trim());
        });
      },
    );
  }

  Widget passwordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Password',
          controller: _password,
          keyboardType: TextInputType.visiblePassword,
          errorMessage: _passwordError,
          obscureText: _obscurePassword,
          onChanged: (value) {
            setState(() {
              String password = _password.text;
              String confirmPassword = _confirmPassword.text;
              _passwordError = Validate.password(password);
              if (confirmPassword.isNotEmpty) {
                _confirmPasswordError = Validate.confirmPassword(
                  password: password,
                  confirmPassword: confirmPassword,
                );
              }
            });
          },
        ),
        Positioned(
          top: 12.0,
          right: 12.0,
          child: ObscureIcon(
            obscure: _obscurePassword,
            onTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      controller: _confirmPassword,
      errorMessage: _confirmPasswordError,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          _confirmPasswordError = Validate.confirmPassword(
            password: _password.text,
            confirmPassword: _confirmPassword.text,
          );
        });
      },
    );
  }

  Widget signUpButton(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.15,
      ),
      child: RoundedButton(
        label: 'Sign Up',
        onPressed: () {
          setState(() {
            _signUp();
          });
        },
      ),
    );
  }
}

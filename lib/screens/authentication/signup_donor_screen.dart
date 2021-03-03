import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/obscure_icon.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpDonorScreen extends StatefulWidget {
  static const String id = 'signup_donor_screen';

  @override
  _SignUpDonorScreenState createState() => _SignUpDonorScreenState();
}

class _SignUpDonorScreenState extends State<SignUpDonorScreen> {
  bool _showSpinner = false;
  bool _obscurePassword = true;

  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  String _firstNameError = '';
  String _lastNameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  BuildContext _scaffoldContext;

  bool _validate() {
    String errors = '';
    errors += _firstNameError = Validate.name(
      label: 'First Name',
      name: _firstName.text.trim(),
    );
    errors += _lastNameError = Validate.name(
      label: 'Last Name',
      name: _lastName.text.trim(),
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
        AuthService auth = context.read<AuthService>();
        String notifyMessage = await auth.signUp(
          email: email,
          password: password,
        );
        FireStoreService fireStore = context.read<FireStoreService>();
        fireStore.uid(auth.user.uid);
        await fireStore.addUser(
          email: email,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
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
      } catch (e) {
        MessageBar(
          _scaffoldContext,
          message: e,
        ).show();
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Sign Up'),
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
                    vertical: screen.height * 0.06,
                    horizontal: screen.width * 0.15,
                  ),
                  child: Column(
                    children: [
                      firstNameInputField(),
                      inputFieldSizeBox(),
                      lastNameInputField(),
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
          );
        },
      ),
    );
  }

  Widget inputFieldSizeBox() {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(height: screen.height * 0.01);
  }

  Widget firstNameInputField() {
    return InputField(
      label: 'First Name',
      controller: _firstName,
      errorMessage: _firstNameError,
      maxLength: Validate.maxNameLength,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _firstNameError = Validate.name(
            label: 'First Name',
            name: _firstName.text.trim(),
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget lastNameInputField() {
    return InputField(
      label: 'Last Name',
      controller: _lastName,
      errorMessage: _lastNameError,
      maxLength: Validate.maxNameLength,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _lastNameError = Validate.name(
            label: 'Last Name',
            name: _lastName.text.trim(),
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
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
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget passwordInputField() {
    return Stack(
      children: [
        InputField(
          label: 'Password',
          controller: _password,
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
          onTap: () {
            MessageBar(_scaffoldContext).hide();
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
      onTap: () {
        MessageBar(_scaffoldContext).hide();
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
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          setState(() {
            _signUp();
          });
        },
      ),
    );
  }
}

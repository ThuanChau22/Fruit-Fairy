import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/utils/validation.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SignUpDonorScreen extends StatefulWidget {
  static const String id = 'signup_donor_screen';

  @override
  _SignUpDonorScreenState createState() => _SignUpDonorScreenState();
}

class _SignUpDonorScreenState extends State<SignUpDonorScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showSpinner = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  String _firstNameError = '';
  String _lastNameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  BuildContext _scaffoldContext;

  bool _validate() {
    String errors = '';
    setState(() {
      errors += _firstNameError = Validate.name(
        label: 'First Name',
        name: _firstName,
      );
      errors += _lastNameError = Validate.name(
        label: 'Last Name',
        name: _lastName,
      );
      errors += _emailError = Validate.email(
        email: _email,
      );
      errors += _passwordError = Validate.password(
        password: _password,
      );
      errors += _confirmPasswordError = Validate.confirmPassword(
        password: _password,
        confirmPassword: _confirmPassword,
      );
    });
    return errors.isEmpty;
  }

  void _signUp() async {
    if (_validate()) {
      setState(() => _showSpinner = true);
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        if (userCredential != null) {
          await userCredential.user.sendEmailVerification();
          await _firestore
              .collection(kUserDB)
              .doc(userCredential.user.uid)
              .set({
            kEmailField: _email,
            kFirstNameField: _firstName,
            kLastNameField: _lastName,
          });
          Navigator.of(context).pushNamedAndRemoveUntil(
            SignInScreen.id,
            (route) => route.settings.name == SignOptionScreen.id,
            arguments: userCredential,
          );
        }
      } catch (e) {
        MessageBar(
          _scaffoldContext,
          message: e.message,
        ).show();
      } finally {
        setState(() => _showSpinner = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    horizontal: MediaQuery.of(context).size.width * 0.15,
                    vertical: 50,
                  ),
                  child: Column(
                    children: [
                      firstNameInputField(),
                      SizedBox(height: 10.0),
                      lastNameInputField(),
                      SizedBox(height: 10.0),
                      emailInputField(),
                      SizedBox(height: 10.0),
                      passwordInputField(),
                      SizedBox(height: 10.0),
                      confirmPasswordInputField(),
                      SizedBox(height: 15.0),
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

  Widget firstNameInputField() {
    return InputField(
      label: 'First Name',
      errorMessage: _firstNameError,
      maxLength: Validate.maxNameLength,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _firstName = value.trim();
          _firstNameError = Validate.name(
            label: 'First Name',
            name: _firstName,
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
      errorMessage: _lastNameError,
      maxLength: Validate.maxNameLength,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _lastName = value.trim();
          _lastNameError = Validate.name(
            label: 'Last Name',
            name: _lastName,
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
      errorMessage: _emailError,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        setState(() {
          _email = value.trim();
          _emailError = Validate.email(
            email: _email,
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
      errorMessage: _passwordError,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          _password = value;
          _passwordError = Validate.password(
            password: _password,
          );
          if (_confirmPassword.isNotEmpty) {
            _confirmPasswordError = Validate.confirmPassword(
              password: _password,
              confirmPassword: _confirmPassword,
            );
          }
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      errorMessage: _confirmPasswordError,
      obscureText: true,
      onChanged: (value) {
        setState(() {
          _confirmPassword = value;
          _confirmPasswordError = Validate.confirmPassword(
            password: _password,
            confirmPassword: _confirmPassword,
          );
        });
      },
      onTap: () {
        MessageBar(_scaffoldContext).hide();
      },
    );
  }

  Widget signUpButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
      ),
      child: RoundedButton(
        label: 'Sign Up',
        labelColor: kPrimaryColor,
        backgroundColor: kLabelColor,
        onPressed: () {
          _signUp();
        },
      ),
    );
  }
}

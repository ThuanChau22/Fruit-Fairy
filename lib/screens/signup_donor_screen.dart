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

  int _firstNameCount = 0;
  int _lastNameCount = 0;

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
          scaffoldContext: _scaffoldContext,
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
      backgroundColor: kBackroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sign Up'),
        backgroundColor: kAppBarColor,
      ),
      body: Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;
          return SafeArea(
            child: ModalProgressHUD(
              opacity: 0.5,
              inAsyncCall: _showSpinner,
              child: ScrollableLayout(
                child: Container(
                  padding: EdgeInsets.all(50.0),
                  child: Column(
                    children: [
                      firstNameInputField(),
                      SizedBox(height: 5.0),
                      lastNameInputField(),
                      SizedBox(height: 5.0),
                      emailInputField(),
                      SizedBox(height: 5.0),
                      passwordInputField(),
                      SizedBox(height: 5.0),
                      confirmPasswordInputField(),
                      SizedBox(height: 15.0),
                      signUpButton(context),
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

  InputField firstNameInputField() {
    return InputField(
      label: 'First Name',
      value: _firstName,
      errorMessage: _firstNameError,
      characterCount: _firstNameCount,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _firstName = value.trim();
          _firstNameCount = _firstName.length;
          _firstNameError = Validate.name(
            label: 'First Name',
            name: _firstName,
          );
        });
      },
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  InputField lastNameInputField() {
    return InputField(
      label: 'Last Name',
      value: _lastName,
      errorMessage: _lastNameError,
      characterCount: _lastNameCount,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          _lastName = value.trim();
          _lastNameCount = _lastName.length;
          _lastNameError = Validate.name(
            label: 'Last Name',
            name: _lastName,
          );
        });
      },
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  InputField emailInputField() {
    return InputField(
      label: 'Email',
      value: _email,
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
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  InputField passwordInputField() {
    return InputField(
      label: 'Password',
      value: _password,
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
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  InputField confirmPasswordInputField() {
    return InputField(
      label: 'Confirm Password',
      value: _confirmPassword,
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
      onTap: () => MessageBar(scaffoldContext: _scaffoldContext).hide(),
    );
  }

  Padding signUpButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Sign Up',
        labelColor: kBackroundColor,
        backgroundColor: kLabelColor,
        onPressed: () {
          _signUp();
        },
      ),
    );
  }
}

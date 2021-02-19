import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/utils/Validation.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _signUpError = '';

  int _firstNameCount = 0;
  int _lastNameCount = 0;

  bool _isValid() {
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
    if (!_isValid()) {
      return;
    }

    setState(() => _showSpinner = true);
    try {
      UserCredential newUser = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      if (newUser != null) {
        await _firestore.collection(kUserDB).doc(newUser.user.uid).set({
          kEmailField: _email,
          kFirstNameField: _firstName,
          kLastNameField: _lastName,
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(HomeScreen.id);
      }
    } catch (e) {
      setState(() {
        _signUpError = e.message;
      });
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        centerTitle: true,
        title: Text('Sign Up'),
      ),
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ModalProgressHUD(
          opacity: 0.5,
          inAsyncCall: _showSpinner,
          child: ScrollableLayout(
            child: Container(
              padding: EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputField(
                    label: 'First Name',
                    value: _firstName,
                    errorMessage: _firstNameError,
                    characterCount: _firstNameCount,
                    keyboardType: TextInputType.name,
                    onChanged: (value) => setState(() {
                      _firstName = value.trim();
                      _firstNameCount = _firstName.length;
                      _firstNameError = Validate.name(
                        label: 'First Name',
                        name: _firstName,
                      );
                    }),
                  ),
                  SizedBox(height: 15.0),
                  InputField(
                    label: 'Last Name',
                    value: _lastName,
                    errorMessage: _lastNameError,
                    characterCount: _lastNameCount,
                    keyboardType: TextInputType.name,
                    onChanged: (value) => setState(() {
                      _lastName = value.trim();
                      _lastNameCount = _lastName.length;
                      _lastNameError = Validate.name(
                        label: 'Last Name',
                        name: _lastName,
                      );
                    }),
                  ),
                  SizedBox(height: 15.0),
                  InputField(
                    label: 'Email',
                    value: _email,
                    errorMessage: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => setState(() {
                      _email = value.trim();
                      _emailError = Validate.email(
                        email: _email,
                      );
                    }),
                  ),
                  SizedBox(height: 15.0),
                  InputField(
                    label: 'Password',
                    value: _password,
                    errorMessage: _passwordError,
                    obscureText: true,
                    onChanged: (value) => setState(() {
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
                    }),
                  ),
                  SizedBox(height: 15.0),
                  InputField(
                    label: 'Confirm Password',
                    value: _confirmPassword,
                    errorMessage: _confirmPasswordError,
                    obscureText: true,
                    onChanged: (value) => setState(() {
                      _confirmPassword = value;
                      _confirmPasswordError = Validate.confirmPassword(
                        password: _password,
                        confirmPassword: _confirmPassword,
                      );
                    }),
                  ),
                  SizedBox(height: 15.0),
                  RoundedButton(
                    label: 'Sign Up',
                    onPressed: _signUp,
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    _signUpError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset_password_screen';
  @override
  _ResetPasswordScreen createState() => _ResetPasswordScreen();
}

class _ResetPasswordScreen extends State<ResetPasswordScreen> {
  String _email = '';
  String _emailError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ScrollableLayout(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Column(children: [
              Text(
                'Enter email for password reset:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.0),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.15),
                child: InputField(
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  errorMessage: _emailError,
                  onChanged: (value) {
                    setState(() {
                      //TODO: Validate email
                    });
                  },
                ),
              ),
              //SizedBox(height: 100.0),
              RoundedButton(
                label: 'Send',
                labelColor: kBackgroundColor,
                backgroundColor: kLabelColor,
                //TODO: Send a reset password email to the email
                onPressed: null,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

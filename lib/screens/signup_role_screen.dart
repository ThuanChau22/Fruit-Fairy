import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/signup_donor_screen.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class SignUpRoleScreen extends StatelessWidget {
  static const String id = 'signup_role_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Account'),
        backgroundColor: kAppBarColor,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundedButton(
                label: 'Donor',
                color: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, SignUpDonorScreen.id);
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                label: 'Charity',
                color: Colors.white,
                //TODO: redirect to sign up charity screen
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

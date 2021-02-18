import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/screens/signup_donor_screen.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class SignUpRoleScreen extends StatelessWidget {
  static const String id = 'signup_role_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Account'),
        backgroundColor: kAppBarColor,
      ),
      body: SafeArea(
        child: ScrollableLayout(
          child: Center(
            child: Column(
              children: [
                Hero(
                  tag: FruitFairyLogo.id,
                  child: FruitFairyLogo(
                    fontSize: 25.0,
                    radius: 60.0,
                  ),
                ),
                SizedBox(height: 24.0),
                RoundedButton(
                  label: 'Donor',
                  labelColor: kBackroundColor,
                  backgroundColor: kLabelColor,
                  onPressed: () {
                    Navigator.pushNamed(context, SignUpDonorScreen.id);
                  },
                ),
                RoundedButton(
                  label: 'Charity',
                  labelColor: kBackroundColor,
                  backgroundColor: kLabelColor,
                  //ToDo: redirect to sign up charity screen
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

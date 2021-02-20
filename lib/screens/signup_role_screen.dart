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
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ScrollableLayout(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.15,
            ),
            child: Center(
              child: Column(
                children: [
                  fairyLogo(context),
                  SizedBox(height: 24.0),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.12,
                    ),
                    child: Column(
                      children: [
                        donorButton(context),
                        charityButton(context),
                      ],
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

  Widget fairyLogo(context) {
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: MediaQuery.of(context).size.width * 0.07,
        radius: MediaQuery.of(context).size.width * 0.15,
      ),
    );
  }

  Widget donorButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RoundedButton(
        label: 'Donor',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        labelCenter: false,
        leading: Icon(
          Icons.person,
          size: MediaQuery.of(context).size.width * 0.1,
          color: kPrimaryColor,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(SignUpDonorScreen.id);
        },
      ),
    );
  }

  Widget charityButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RoundedButton(
        label: 'Charity',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        labelCenter: false,
        leading: Icon(
          Icons.group,
          size: MediaQuery.of(context).size.width * 0.1,
          color: kPrimaryColor,
        ),
        //ToDo: redirect to sign up charity screen
        onPressed: null,
      ),
    );
  }
}

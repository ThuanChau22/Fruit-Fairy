import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/authentication/signup_donor_screen.dart';
import 'package:fruitfairy/widgets/fruit_fairy_logo.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignUpRoleScreen extends StatelessWidget {
  static const String id = 'signup_role_screen';

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
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
              vertical: screen.height * 0.03,
              horizontal: screen.width * 0.15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fairyLogo(context),
                SizedBox(height: screen.height * 0.03),
                Text(
                  'Solve Food Waste\nOne Donation\nAt A Time',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kLabelColor,
                    fontSize: 25.0,
                    fontFamily: 'Pacifico',
                  ),
                ),
                SizedBox(height: screen.height * 0.04),
                // SizedBox(height: screen.height * 0.15),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.12,
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
    );
  }

  Widget fairyLogo(context) {
    return Hero(
      tag: FruitFairyLogo.id,
      child: FruitFairyLogo(
        fontSize: 30,
        radius: 65,
      ),
    );
  }

  Widget donorButton(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.025),
      child: RoundedButton(
        label: 'Donor',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        leading: Icon(
          Icons.person,
          size: 40.0,
          color: kPrimaryColor,
        ),
        trailing: SizedBox(
          width: 40.0,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(SignUpDonorScreen.id);
        },
      ),
    );
  }

  Widget charityButton(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screen.height * 0.025),
      child: RoundedButton(
        label: 'Charity',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        leading: Icon(
          FontAwesomeIcons.handHoldingHeart,
          size: 35.0,
          color: kPrimaryColor,
        ),
        trailing: SizedBox(width: 35.0),
        //ToDo: redirect to sign up charity screen
        onPressed: null,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/charity_selection_screen.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class ConfirmationDonationScreen extends StatefulWidget {
  static const String id = 'confirmation_donation_screen';

  @override
  _ConfirmationDonationScreenState createState() =>
      _ConfirmationDonationScreenState();
}

class _ConfirmationDonationScreenState
    extends State<ConfirmationDonationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Address Confirmation')),
      body: SafeArea(
        child: Container(child: fillInFields()),
      ),
    );
  }

  Widget fillInFields() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.15),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screen.height * 0.02),
          Text(
            'Address:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screen.height * 0.02),
          InputField(
            label: 'Street',
            onChanged: null,
            controller: null,
          ),
          InputField(
            label: 'City',
            onChanged: null,
            controller: null,
          ),
          InputField(
            label: 'Zip Code',
            onChanged: null,
            controller: null,
          ),
          InputField(
            label: 'State',
            onChanged: null,
            controller: null,
          ),
          InputField(
            label: 'Phone number',
            onChanged: null,
            controller: null,
          ),
          SizedBox(height: screen.height * 0.1),
          RoundedButton(
            label: 'Next',
            onPressed: () {
              Navigator.of(context).pushNamed(CharitySelectionScreen.id);
            },
            labelColor: kPrimaryColor,
          ),
        ],
      ),
    );
  }
}

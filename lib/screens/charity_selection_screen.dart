import 'package:flutter/material.dart';
import 'package:fruitfairy/widgets/charity_selection_button.dart';

import '../constant.dart';

class CharitySelectionScreen extends StatefulWidget {
  static const String id = 'charity_selection_screen';

  @override
  _CharitySelectionScreenState createState() => _CharitySelectionScreenState();
}

class _CharitySelectionScreenState extends State<CharitySelectionScreen> {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: screen.height * 0.03,
            ),
            Text(
              'Charity Selection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            SizedBox(
              height: screen.height * 0.03,
            ),
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 5.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            SizedBox(
              height: screen.height * 0.03,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Select the top 3 charities to donate to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),

            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: CharityButton(label: 'Charity #1', leading: circle, onPressed: (){},),
            ),
          ],
        ),
      ),
    );
  }

  Widget circle = new Container(
    width: 40.0,
    height: 40.0,
    decoration: new BoxDecoration(
      border: Border.all(
        color: kPrimaryColor,
        width: 3,
      ),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        '1',
        style: TextStyle(
          color: kPrimaryColor,
          fontSize: 30,
        ),
      ),
    ),
  );
}

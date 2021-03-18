import 'package:flutter/material.dart';
import 'package:fruitfairy/widgets/charity_selection_button.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

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
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.05),
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
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: CharityButton(
                  label: 'Charity #1',
                  onPressed: () {},
                  leading: circleWithNumber(1)),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: CharityButton(
                label: 'short',
                onPressed: () {},
                leading: circleWithNumber(2),
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: CharityButton(
                label: 'verylongnamecharity',
                onPressed: () {},
                leading: circleWithNumber(3),
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: CharityButton(
                label: 'CHARITY 4',
                onPressed: () {},
                leading: circleWithNumber(4),
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: CharityButton(
                label: 'verylongnamecharity',
                onPressed: () {},
                leading: circleWithNumber(5),
              ),
            ),
            SizedBox(
              height: screen.height * 0.1,
            ),
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 5.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.1),
              child: RoundedButton(label: 'Next', onPressed: (){}),
            )
          ],
        ),
      ),
    );
  }

  Widget circleWithNumber(int number) {
    return Container(
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
          number.toString(),
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

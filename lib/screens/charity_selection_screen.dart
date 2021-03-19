import 'package:flutter/material.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

import '../constant.dart';

class CharitySelectionScreen extends StatefulWidget {
  static const String id = 'charity_selection_screen';

  @override
  _CharitySelectionScreenState createState() => _CharitySelectionScreenState();
}

class _CharitySelectionScreenState extends State<CharitySelectionScreen> {

  bool circleVisible1 = false;
  bool circleVisible2 = false;
  bool circleVisible3 = false;
  bool circleVisible4 = false;
  bool circleVisible5 = false;


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
                'Select 3 charities to donate to:',
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
            //TODO: make a charity button
            GestureDetector(
                onTap:(){
                  setState(() {
                    circleVisible1 =! circleVisible1;
                  });
                },
                child: charityButton('Charity #1', 1,circleVisible1)),
            SizedBox(
              height: screen.height * 0.02,
            ),
            GestureDetector(
                onTap:(){
                  setState(() {
                    circleVisible2 =! circleVisible2;
                  });
                },
                child: charityButton('Charity #2', 2, circleVisible2)),
            SizedBox(
              height: screen.height * 0.02,
            ),
            charityButton('Charity #3', 3, circleVisible3),
            SizedBox(
              height: screen.height * 0.02,
            ),
            charityButton('Charity #4', 4, circleVisible4),
            SizedBox(
              height: screen.height * 0.02,
            ),
            charityButton('Charity #5', 5,circleVisible5),
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
              padding: EdgeInsets.symmetric(horizontal: screen.width * 0.2),
              child: RoundedButton(label: 'Next', onPressed: () {}),
            )
          ],
        ),
      ),
    );
  }

  Widget charityButton(String charityName, int number, bool circleVisible) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      height: 50.0,
      width: 300.0,
      decoration: BoxDecoration(
        color: kObjectBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: circleWithNumber(number, circleVisible)),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: screen.width * 0.1,
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50.0,
              width: 200.0,
              child: Text(charityName, style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
          ),
        ],
      ),
    );
  }

  Widget circleWithNumber(int number, bool circleVisible) {
    return Visibility(
      visible: circleVisible,
      child: Container(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }
}

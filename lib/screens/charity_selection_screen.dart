import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'donation_confirm_screen.dart';

class CharitySelectionScreen extends StatefulWidget {
  static const String id = 'charity_selection_screen';

  @override
  _CharitySelectionScreenState createState() => _CharitySelectionScreenState();
}

class _CharitySelectionScreenState extends State<CharitySelectionScreen> {
  List<String> selectedCharity = [
    'charity1',
    'charity2',
    'charity3',
    'charity4',
    'charity5'
  ];
  List<String> numbers = [];

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
              thickness: 3.0,
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
            Column(
              children: charities(),
            ),
            SizedBox(
              height: screen.height * 0.175,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.05,
              ),
              child: Column(
                children: [
                  Column(
                    children: [
                      Divider(
                        color: kLabelColor,
                        height: 5.0,
                        thickness: 3.0,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screen.height * 0.03,
                          horizontal: screen.width * 0.2,
                        ),
                        child: RoundedButton(
                          label: 'Next',
                          onPressed: () {
                            Navigator.of(context).pushNamed(DonationConfirmScreen.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> charities() {
    List<Widget> list = [];
    for (String name in selectedCharity) {
      list.add(charityButton(
          charityName: name,
          onTap: () {
            setState(() {
              if (numbers.contains(name)) {
                numbers.remove(name);
              } else {
                if (numbers.length < 3) {
                  numbers.add(name);
                }
              }
            });
          }));
    }
    return list;
  }

  Widget charityButton({
    @required String charityName,
    @required VoidCallback onTap,
  }) {
    Size screen = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: screen.height * 0.02,
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 50.0,
            width: 300.0,
            decoration: BoxDecoration(
              color: kObjectColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: circleWithNumber(charityName)),
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
                    child: Text(
                      charityName,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget circleWithNumber(String charityName) {
    return Visibility(
      visible: numbers.contains(charityName),
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
            '${numbers.indexOf(charityName) + 1}',
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

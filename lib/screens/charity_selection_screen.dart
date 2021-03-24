import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/donation_confirm_screen.dart';
import 'package:fruitfairy/widgets/charity_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

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
    'charity5',
  ];
  List<String> numbers = [];

  void confirm() {
    Navigator.of(context).pushNamed(DonationConfirmScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Donation')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.05,
          ),
          child: Column(
            children: [
              titleLabel(),
              divider(),
              instructionLabel(),
              charityOptions(),
              divider(),
              nextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget titleLabel() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
        bottom: screen.height * 0.02,
      ),
      child: Text(
        'Charity Selection',
        style: TextStyle(
          color: kLabelColor,
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 5.0,
      thickness: 3.0,
    );
  }

  Widget instructionLabel() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.height * 0.05,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select 3 charities:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kLabelColor,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
            ),
          ),
          helpButton(),
        ],
      ),
    );
  }

  Widget charityOptions() {
    List<Widget> charityList = charityTiles();
    Size screen = MediaQuery.of(context).size;
    return Expanded(
      child: ListView.builder(
        itemCount: charityList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: screen.height * 0.01,
              horizontal: screen.width * 0.1,
            ),
            child: charityList[index],
          );
        },
      ),
    );
  }

  List<Widget> charityTiles() {
    List<Widget> charityList = [];
    selectedCharity.forEach((charityName) {
      bool selected = numbers.contains(charityName);
      charityList.add(CharityTile(
        charityName: charityName,
        selectedOrder: selected ? '${numbers.indexOf(charityName) + 1}' : '',
        onTap: () {
          setState(() {
            if (selected) {
              numbers.remove(charityName);
            } else if (numbers.length < 3) {
              numbers.add(charityName);
            }
          });
        },
      ));
    });
    return charityList;
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          confirm();
        },
      ),
    );
  }

  Widget helpButton() {
    return RoundedIconButton(
      radius: 25.0,
      icon: Icon(
        Icons.help_outline,
        color: kLabelColor,
        size: 25.0,
      ),
      buttonColor: Colors.transparent,
      onPressed: () {
        showHelpDialog();
      },
    );
  }

  void showHelpDialog() {
    Alert(
      context: context,
      title: '',
      style: AlertStyle(
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: kLabelColor,
        titleStyle: TextStyle(fontSize: 0.0),
        overlayColor: Colors.black.withOpacity(0.25),
        isCloseButton: false,
      ),
      content: Text(
        'Please select the top three charities to donate to. If your first prioritized charity does not accept your donation, it will be offered to the second prioritized charity and so on.',
        style: TextStyle(
          color: kPrimaryColor,
          fontSize: 20.0,
          decoration: TextDecoration.none,
        ),
      ),
      buttons: [],
    ).show();
  }
}

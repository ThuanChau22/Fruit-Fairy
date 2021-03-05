import 'package:flutter/material.dart';

import 'package:fruitfairy/utils/constant.dart';
import 'package:fruitfairy/widgets/fruit_image_with_remove_button.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class DonationCartScreen extends StatefulWidget {
  static const String id = 'donation_cart_screen';

  @override
  _DonationCartScreenState createState() => _DonationCartScreenState();
}

enum YesOrNoSelection {
  yes,
  no,
}

class _DonationCartScreenState extends State<DonationCartScreen> {
  YesOrNoSelection selectedOption;

  List<Widget> getSelectedFruits() {
    List<Widget> selectedFruitsList = [];
    int i = 0;
    while (i < kFruitImages.length) {
      List<Widget> rowItems = [fruitItem(i++)];
      while (i % 2 != 0) {
        rowItems.add(fruitItem(i++));
      }
      selectedFruitsList.add(Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowItems,
        ),
      ));
    }
    return selectedFruitsList;
  }

  Widget fruitItem(int index) {
    return FruitImageWithRemove(
      fruitImage: AssetImage(kFruitImages[index]),
      fruitName: Text(kFruitNames[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Donation Cart'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: myColumn(screen),
      ),
    );
  }

  Widget myColumn(Size screen) {
    return Column(
      children: [
        SizedBox(height: screen.height * 0.02),
        Text(
          'Do you need help collecting?',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: screen.height * 0.02),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.08),
                child: RoundedButton(
                  label: 'Yes',
                  labelColor: kPrimaryColor,
                  onPressed: () {
                    setState(() {
                      selectedOption == YesOrNoSelection.yes
                          ? selectedOption = null
                          : selectedOption = YesOrNoSelection.yes;
                    });
                  },
                  backgroundColor: selectedOption == YesOrNoSelection.yes
                      ? Colors.green.shade100
                      : Colors.white,
                ),
              ),

              SizedBox(height: screen.height * 0.02),
              Expanded(
                //Already scrollable
                child: GridView.count(
                  primary: false,
                  padding: EdgeInsets.all(8),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  crossAxisCount: 2,
                  children: [
                    for (int i = 0; i < kFruitImages.length; i++)
                      FruitImageWithRemove(
                          fruitImage: AssetImage(kFruitImages[i]),
                          fruitName: Text(kFruitNames[i])),
                  ],

            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.08),
                child: RoundedButton(
                  label: 'No',
                  labelColor: kPrimaryColor,
                  onPressed: () {
                    setState(() {
                      selectedOption == YesOrNoSelection.no
                          ? selectedOption = null
                          : selectedOption = YesOrNoSelection.no;
                    });
                  },
                  backgroundColor: selectedOption == YesOrNoSelection.no
                      ? Colors.green.shade100
                      : Colors.white,

                ),
              ),
            )
          ],
        ),
        SizedBox(height: screen.height * 0.02),
        kDivider(),
        SizedBox(height: screen.height * 0.02),
        Text(
          'Fruits selected to donate:',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: screen.height * 0.01),
        selectedFruits(),
        SizedBox(height: screen.height * 0.02),
        kDivider(),
        Container(
          height: screen.height * 0.325,
          child: ListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: screen.height * 0.02),
              fillInFields(),
              button(),
              SizedBox(height: screen.height * 0.02),
            ],
          ),
        ),
      ],
    );
  }

  Widget selectedFruits() {
    // return Expanded(
    //   child: Column(
    //     children: getSelectedFruits(),
    //   ),
    // );
    return Expanded(
      child: GridView.count(
        primary: false,
        padding: EdgeInsets.all(8),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        children: [
          for (int i = 0; i < 1; i++)
            FruitImageWithRemove(
              fruitImage: AssetImage(kFruitImages[i]),
              fruitName: Text(kFruitNames[i]),
            ),
        ],
      ),
    );
  }

  Widget fillInFields() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.15),
      child: Column(
        children: [
          Text(
            'Your Information:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
          ),
          InputField(label: 'City', onChanged: null),
          InputField(label: 'Zip Code', onChanged: null),
          InputField(label: 'State', onChanged: null),
          Text(
            'Phone Number:',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          InputField(label: 'Phone number', onChanged: null),
        ],
      ),
    );
  }

  Widget button() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.3),
      child: RoundedButton(
        label: 'Confirm',
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          //Navigator.of(context).pushNamed(DonationCartScreen.id);
        },
      ),
    );
  }
}

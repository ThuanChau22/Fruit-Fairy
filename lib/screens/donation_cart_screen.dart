import 'package:flutter/material.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/widgets/fruit_image_with_remove_button.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/screens/temp_fruit_with_quantity.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donation')),
      body: SafeArea(
        child: myColumn(),
      ),
    );
  }

  Widget myColumn() {
    Size screen = MediaQuery.of(context).size;
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
                  backgroundColor: selectedOption == YesOrNoSelection.yes
                      ? Colors.green.shade100
                      : Colors.white,
                  onPressed: () {
                    setState(() {
                      selectedOption == YesOrNoSelection.yes
                          ? selectedOption = null
                          : selectedOption = YesOrNoSelection.yes;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.width * 0.08),
                child: RoundedButton(
                  label: 'No',
                  backgroundColor: selectedOption == YesOrNoSelection.no
                      ? Colors.green.shade100
                      : Colors.white,
                  onPressed: () {
                    setState(() {
                      selectedOption == YesOrNoSelection.no
                          ? selectedOption = null
                          : selectedOption = YesOrNoSelection.no;
                    });
                  },
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
        Expanded(
          child: GridView.count(
            primary: false,
            padding: EdgeInsets.all(8),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: 2,
            children: selectedFruits(),
          ),
        ),
        SizedBox(height: screen.height * 0.02),
        kDivider(),
        button(),
        SizedBox(height: screen.height * 0.02),
      ],
    );
  }

  List<Widget> selectedFruits() {
    List<Widget> selectedFruits = [];
    Basket basket = context.read<Basket>();
    List<int> list = basket.selectedFruits;
    for (int i = 0; i < list.length; i++) {
      selectedFruits.add(
        FruitImageWithRemove(
          fruitImage: AssetImage(basket.fruitImages[list[i]]),
          fruitName: Text(
            basket.fruitNames[list[i]],
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
          ),
          removeFunction: () {
            setState(() {
              basket.remove(list[i]);
            });
          },
        ),
      );
    }
    return selectedFruits;
  }

  Widget button() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.3),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          Navigator.of(context).pushNamed(FruitQuantity.id);
        },
      ),
    );
  }
}

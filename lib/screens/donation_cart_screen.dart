import 'package:flutter/material.dart';

import 'package:fruitfairy/utils/constant.dart';
import 'package:fruitfairy/widgets/fruit_image_with_remove_button.dart';
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
        child: Center(
          child: Column(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: screen.width * 0.08),
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
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screen.width * 0.08),
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
                'Fruits selected to donate',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              ),
              SizedBox(height: screen.height * 0.02),
              kDivider(),
              SizedBox(height: screen.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

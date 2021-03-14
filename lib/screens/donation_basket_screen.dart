import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:provider/provider.dart';

import 'package:fruitfairy/widgets/temp_fruit_with_quantity.dart';

class DonationBasketScreen extends StatefulWidget {
  static const String id = 'donation_basket_screen';

  @override
  _DonationBasketScreenState createState() => _DonationBasketScreenState();
}

enum CollectOption { Yes, No }

class _DonationBasketScreenState extends State<DonationBasketScreen> {
  final Color _selectedColor = Colors.green.shade100;
  CollectOption _selectedOption = CollectOption.No;

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Donation')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screen.height * 0.03,
            horizontal: screen.width * 0.05,
          ),
          child: Column(
            children: [
              sectionLabel('Do you need help collecting?'),
              collectOptionTile(),
              divider(),
              SizedBox(height: screen.height * 0.02),
              sectionLabel('Adjust percentage of produce you want to donate:'),
              SizedBox(height: screen.height * 0.02),
              selectedFruit(),
              divider(),
              SizedBox(height: screen.height * 0.03),
              nextButton(),
            ],
          ),
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

  Widget sectionLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.1,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget collectOptionTile() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.02,
      ),
      child: Row(
        children: [
          collectOptionButton(
            label: 'Yes',
            option: CollectOption.Yes,
          ),
          collectOptionButton(
            label: 'No',
            option: CollectOption.No,
          ),
        ],
      ),
    );
  }

  Widget collectOptionButton({
    @required String label,
    @required CollectOption option,
  }) {
    Size screen = MediaQuery.of(context).size;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.08,
        ),
        child: RoundedButton(
          label: label,
          backgroundColor: _selectedOption == option
              ? _selectedColor
              : kObjectBackgroundColor,
          onPressed: () {
            setState(() {
              _selectedOption = option;
            });
          },
        ),
      ),
    );
  }

  Widget selectedFruit() {
    if (_selectedOption == CollectOption.Yes) {
      return collectNeedHelp();
    }
    return collectWithoutHelp();
  }

  Widget collectWithoutHelp() {
    List<Widget> fruitTiles = [];
    Basket basket = context.read<Basket>();
    Map<String, Fruit> fruits = basket.fruits;
    basket.selectedFruits.forEach((fruitId) {
      fruitTiles.add(
        removableFruitTile(
          fruitName: fruits[fruitId].name,
          fruitImage: fruits[fruitId].imageURL,
          onPress: () {
            setState(() {
              basket.removeFruit(fruitId);
            });
          },
        ),
      );
    });
    Size screen = MediaQuery.of(context).size;
    int axisCount = 2;
    if (screen.width >= 600) {
      axisCount = 4;
    }
    return Expanded(
      child: GridView.count(
        primary: false,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        crossAxisCount: axisCount,
        children: fruitTiles,
      ),
    );
  }

  //Todo: the images dont shwo up, need to work on it a little bit?
  Widget collectNeedHelp() {
    Size screen = MediaQuery.of(context).size;
    Basket basket = context.read<Basket>();
    Map<String, Fruit> fruits = basket.fruits;
    List<String> selectedFruit = basket.selectedFruits;
    return Expanded(
      child: SizedBox(
        height: screen.height * 0.02,
        child: ListView.builder(
          itemBuilder: (context, index) {
            Fruit fruit = fruits[selectedFruit[index]];
            return Container(
              width: 350.0,
              height: 200.0,
              //a testing color
              color: Colors.white70,
              child: Row(
                children: [
                  SizedBox(
                    width: screen.width * 0.05,
                  ),
                  SizedBox(width: screen.width * 0.2),
                  FruitTile(
                    fruitName: fruit.name,
                    fruitImage: fruit.imageURL,
                  ),
                  SizedBox(width: screen.width * 0.1),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3.0),
                        ),
                        child: Text(
                          'Number' + ' %',
                          style: TextStyle(
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                      SizedBox(height: screen.height * 0.03),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.add_circle,
                              size: 35.0,
                            ),
                          ),
                          SizedBox(width: screen.width * 0.075),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.remove_circle,
                              size: 35.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          itemCount: selectedFruit.length,
        ),
      ),
    );
  }

  // Widget fruitsSelected() {
  //   List<Widget> fruitTiles = [];
  //   Basket basket = context.watch<Basket>();
  //   Map<String, Fruit> fruits = basket.fruits;
  //   basket.selectedFruits.forEach((fruitId) {
  //     fruitTiles.add(
  //       removableFruitTile(
  //         fruitName: fruits[fruitId].name,
  //         fruitImage: fruits[fruitId].imageURL,
  //         onPress: () {
  //           setState(() {
  //             basket.removeFruit(fruitId);
  //           });
  //         },
  //       ),
  //     );
  //   });
  //   Size screen = MediaQuery.of(context).size;
  //   int axisCount = 2;
  //   if (screen.width >= 600) {
  //     axisCount = 4;
  //   }
  //   return Expanded(
  //     child: GridView.count(
  //       primary: false,
  //       crossAxisSpacing: 15,
  //       mainAxisSpacing: 15,
  //       crossAxisCount: axisCount,
  //       children: fruitTiles,
  //     ),
  //   );
  // }

  Widget removableFruitTile({
    @required String fruitName,
    @required String fruitImage,
    @required VoidCallback onPress,
  }) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: kObjectBackgroundColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: FruitTile(
              fruitName: fruitName,
              fruitImage: fruitImage,
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: removeButton(
            onPressed: onPress,
          ),
        ),
      ],
    );
  }

  Widget removeButton({
    @required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Ink(
          decoration: ShapeDecoration(
            shape: CircleBorder(),
            color: kAppBarColor,
          ),
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: IconButton(
              padding: EdgeInsets.all(0.0),
              splashRadius: 10.0,
              icon: Icon(
                Icons.close,
                color: kLabelColor,
                size: 16.0,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          Navigator.of(context).pushNamed(FruitQuantity.id);
        },
      ),
    );
  }
}

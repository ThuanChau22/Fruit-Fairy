import 'package:flutter/material.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/screens/donation_cart_screen.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:provider/provider.dart';

class PickingFruitScreen extends StatefulWidget {
  static const String id = 'picking_fruit_screen';

  @override
  _PickingFruitScreenState createState() => _PickingFruitScreenState();
}

class _PickingFruitScreenState extends State<PickingFruitScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    Basket basket = context.watch<Basket>();
    return Scaffold(
      appBar: AppBar(title: Text('Donation')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: screen.height * 0.02),
              Text(
                'Choose fruit to donate:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
              ),
              SizedBox(height: screen.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.height * 0.05),
                child: TextField(
                    onChanged: (value) {},
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: kTextFieldInputDecoration),
              ),
              SizedBox(height: screen.height * 0.02),
              Expanded(
                //Already scrollable
                child: GridView.count(
                  primary: false,
                  padding: EdgeInsets.all(10),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  crossAxisCount: 3,
                  children: fruitList(basket),
                ),
              ),
              SizedBox(height: screen.height * 0.02),
              kDivider(),
              SizedBox(height: screen.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15,
                ),
                child: RoundedButton(
                    label: 'Go To Cart',
                    labelColor: kPrimaryColor,
                    backgroundColor: kObjectBackgroundColor,
                    onPressed: () {
                      Navigator.pushNamed(context, DonationCartScreen.id);
                    }),
              ),
              SizedBox(height: screen.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> fruitList(Basket basket) {
    List<Widget> list = [];
    for (int i = 0; i < basket.fruitImages.length; i++) {
      list.add(
        Container(
          decoration: BoxDecoration(
            color: kObjectBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(20),
              ),
          ),
          child: FruitTile(
            fruitImage: AssetImage(basket.fruitImages[i]),
            fruitName: Text(
              basket.fruitNames[i],
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            index: i,
            selected: basket.selectedFruits.contains(i),
            onTap: (index) {
              setState(() {
                //add the selected fruit into the list
                if (basket.selectedFruits.contains(i)) {
                  basket.remove(i);
                } else {
                  basket.pickFruit(i);
                }
              });
            },
          ),
        ),
      );
    }
    return list;
  }
}

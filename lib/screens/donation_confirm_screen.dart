import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:fruitfairy/models/fruit.dart';

import '../constant.dart';

class DonationConfirmScreen extends StatefulWidget {
  static const String id = 'donation_confirm_screen';

  @override
  _DonationConfirmScreenState createState() => _DonationConfirmScreenState();
}

class _DonationConfirmScreenState extends State<DonationConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      //TODO: no style yet, need to do that after

      appBar: AppBar(title: Text('DONATION')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Produce",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 5.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            //TODO: need to set the size for the gridview
            Container(
              child: fruitTileSection(),
            ),

            Text(
              "Charity Selected",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 5.0,
              indent: 20.0,
              endIndent: 20.0,
            ),
            Container(
              width: 100.0,
              height: 100.0,
              //TODO: need a charity class then watch the change
              child: Text("charity selected list"),
            ),
            Text(
              "Contact information",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),

            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 5.0,
              indent: 20.0,
              endIndent: 20.0,
            ),

            contactInformation(),
            SizedBox(
              height: screen.height * 0.03,
            ),
            Text(
              "Thank you",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
            RoundedButton(
              label: "Confirm",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget fruitTileSection() {
    Basket basket = context.watch<Basket>();
    Map<String, Fruit> fruits = basket.fruits;
    return Expanded(
      flex: 2,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: [
          for (String fruitId in basket.selectedFruits)
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kObjectBackgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: FruitTile(
                    fruitName: fruits[fruitId].name,
                    fruitImage: fruits[fruitId].imageURL,
                  ),
                ),
                Visibility(
                  visible: fruits[fruitId].selectedOption,
                  child: Align(
                    child: Text(
                      '${fruits[fruitId].amount}%',
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget contactInformation() {
    Account account = context.watch<Account>();
    print(account.phone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          account.address['street'],
        ),
        Text(
          '${account.address['city']}, ${account.address['state']},${account.address['zip']}',
        ),
        Text('Phone: ${account.phone['number']}'),

      ],
    );
  }
}

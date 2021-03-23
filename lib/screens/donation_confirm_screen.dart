import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

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
    Donation donation = context.read<Donation>();
    Map<String, Fruit> produce = context.watch<Produce>().fruits;
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
          for (String fruitId in donation.produce)
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kObjectColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: FruitTile(
                    fruitName: produce[fruitId].name,
                    fruitImage: produce[fruitId].imageURL,
                    percentage: context.read<Donation>().needCollected
                        ? '${produce[fruitId].amount}'
                        : '',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget contactInformation() {
    Donation donation = context.watch<Donation>();
    Map<String, String> address = donation.address;
    Map<String, String> phone = donation.phone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address[FireStoreService.kAddressStreet],
        ),
        Text(
          '${address[FireStoreService.kAddressCity]}, ${address[FireStoreService.kAddressState]},${address[FireStoreService.kAddressZip]}',
        ),
        Text(
            'Phone: ${phone[FireStoreService.kPhoneDialCode]}${phone[FireStoreService.kPhoneNumber]}'),
      ],
    );
  }
}

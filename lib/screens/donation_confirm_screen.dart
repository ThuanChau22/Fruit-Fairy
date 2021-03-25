import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class DonationConfirmScreen extends StatefulWidget {
  static const String id = 'donation_confirm_screen';

  @override
  _DonationConfirmScreenState createState() => _DonationConfirmScreenState();
}

class _DonationConfirmScreenState extends State<DonationConfirmScreen> {
  void confirm() {
    // Do not call setState on clear
    context.read<Donation>().clear();
    Navigator.of(context).popUntil((route) {
      return route.settings.name == HomeScreen.id;
    });
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
              reviewDetails(),
              divider(),
              confirmButton(),
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
        'Review and Confirm',
        textAlign: TextAlign.center,
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

  Widget reviewDetails() {
    Size screen = MediaQuery.of(context).size;
    List<Widget> widgets = [
      groupLabel('Produce Selected'),
      selectedFruits(),
      groupLabel('Charity Selected'),
      selectedCharities(),
      groupLabel('Contact Information'),
      contactInfo(),
      appreciation(),
    ];
    return Expanded(
      child: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.1,
            ),
            child: widgets[index],
          );
        },
      ),
    );
  }

  Widget groupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              color: kLabelColor,
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(
            color: kLabelColor,
            height: 2.0,
            thickness: 2.0,
          ),
        ],
      ),
    );
  }

  Widget fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: kLabelColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
    );
  }

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = screen.width >= 600 ? 4 : 2;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
      ),
      child: CustomGrid(
        padding: EdgeInsets.all(10.0),
        assistPadding: screen.width * 0.15,
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitList = [];
    Map<String, Fruit> produce = context.read<Produce>().fruits;
    Donation donation = context.read<Donation>();
    donation.produce.forEach((fruitId) {
      int amount = produce[fruitId].amount;
      fruitList.add(Container(
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: FruitTile(
          fruitName: produce[fruitId].name,
          fruitImage: produce[fruitId].imageURL,
          percentage: donation.needCollected ? '$amount' : '',
        ),
      ));
    });
    return fruitList;
  }

  Widget selectedCharities() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel('\u2022 Chariry #1'),
          fieldLabel('\u2022 Chariry #2'),
          fieldLabel('\u2022 Chariry #3'),
        ],
      ),
    );
  }

  Widget contactInfo() {
    Donation donation = context.read<Donation>();
    Map<String, String> address = donation.address;
    String street = address[FireStoreService.kAddressStreet];
    String city = address[FireStoreService.kAddressCity];
    String state = address[FireStoreService.kAddressState];
    String zip = address[FireStoreService.kAddressZip];
    Map<String, String> phone = donation.phone;
    String intlPhoneNumber = phone[FireStoreService.kPhoneDialCode];
    String phoneNumber = phone[FireStoreService.kPhoneNumber];
    intlPhoneNumber += ' (${phoneNumber.substring(0, 3)})';
    intlPhoneNumber += ' ${phoneNumber.substring(3, 6)}';
    intlPhoneNumber += ' ${phoneNumber.substring(6, 10)}';
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel('$street'),
          fieldLabel('$city, $state, $zip'),
          fieldLabel('Phone: $intlPhoneNumber'),
        ],
      ),
    );
  }

  Widget appreciation() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
      ),
      child: Text(
        'Thank You!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kLabelColor,
          fontSize: 30.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget confirmButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Confirm',
        onPressed: () {
          confirm();
        },
      ),
    );
  }
}

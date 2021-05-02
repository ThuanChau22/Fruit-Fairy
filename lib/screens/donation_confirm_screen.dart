import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/charity_tile.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class DonationConfirmScreen extends StatefulWidget {
  static const String id = 'donation_confirm_screen';

  @override
  _DonationConfirmScreenState createState() => _DonationConfirmScreenState();
}

class _DonationConfirmScreenState extends State<DonationConfirmScreen> {
  bool _showSpinner = false;

  void confirm() async {
    setState(() => _showSpinner = true);
    FireStoreService firestore = context.read<FireStoreService>();
    Donation donation = context.read<Donation>();
    await firestore.addDonation(donation);
    donation.reset();
    context.read<Account>().cancelLastSubscription();
    Navigator.of(context).popUntil((route) {
      return route.settings.name == HomeScreen.id;
    });
    setState(() => _showSpinner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review and Confirm')),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
          ),
          child: Stack(
            children: [
              reviewDetails(),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: buttonSection(),
              ),
            ],
          ),
        ),
      ),
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
      bottomPadding(),
    ];
    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.1,
          ),
          child: widgets[index],
        );
      },
    );
  }

  Widget groupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
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
        assistPadding: screen.width * 0.1,
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitList = [];
    Donation donation = context.watch<Donation>();
    for (ProduceItem produceItem in donation.produce.values) {
      fruitList.add(Container(
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: FruitTile(
          fruitName: produceItem.name,
          fruitImage: produceItem.imageURL,
          percentage: donation.needCollected ? '${produceItem.amount}' : '',
        ),
      ));
    }
    return fruitList;
  }

  Widget selectedCharities() {
    List<Widget> selectedCharity = [];
    int priority = 1;
    Donation donation = context.read<Donation>();
    for (Charity charity in donation.charities) {
      selectedCharity.add(Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: CharityTile(
          charityName: charity.name,
          selectedOrder: '${priority++}',
          onTap: () {},
          disabled: true,
        ),
      ));
    }
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.02,
      ),
      child: Column(
        children: selectedCharity,
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
    if (phoneNumber != null) {
      intlPhoneNumber += ' (${phoneNumber.substring(0, 3)})';
      intlPhoneNumber += ' ${phoneNumber.substring(3, 6)}';
      intlPhoneNumber += ' ${phoneNumber.substring(6, 10)}';
    }
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

  Widget bottomPadding() {
    Size screen = MediaQuery.of(context).size;
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: SizedBox(height: 60 + screen.height * 0.03),
    );
  }

  Widget buttonSection() {
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: Container(
        color: kPrimaryColor.withOpacity(0.75),
        child: Column(
          children: [
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 2.0,
            ),
            confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget confirmButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.015,
        horizontal: screen.width * 0.25,
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

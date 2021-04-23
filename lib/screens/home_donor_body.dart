import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/donation_produce_selection_screen.dart';
import 'package:fruitfairy/screens/donor_donation_detail_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class HomeDonorBody extends StatefulWidget {
  @override
  _HomeDonorBodyState createState() => _HomeDonorBodyState();
}

class _HomeDonorBodyState extends State<HomeDonorBody> {
  @override
  void initState() {
    super.initState();
    FireStoreService fireStore = context.read<FireStoreService>();
    fireStore.donationStreamDonor(context.read<Donations>());
    Donation donation = context.read<Donation>();
    donation.onEmptyBasket(() {
      Navigator.of(context).popUntil((route) {
        return route.settings.name == DonationProduceSelectionScreen.id;
      });
    });
    Produce produce = context.read<Produce>();
    fireStore.produceStream(produce, onChange: () {
      bool removed = false;
      List<String>.from(donation.produce.keys).forEach((produceId) {
        if (!produce.map.containsKey(produceId)) {
          donation.removeProduce(produceId);
          removed = true;
        }
      });
      if (removed) {
        MessageBar(
          context,
          message:
              'One or more produce on your basket are no longer available!',
        ).show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Column(
      children: [
        greeting(),
        donateButton(),
        //TODO: Donation tracking status
        Text(
          'Donation History',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: kLabelColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 50.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Today',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: kLabelColor,
              ),
            ),
          ),
        ),
        SizedBox(height: screen.height * 0.02),
        HistoryTile(),
        SizedBox(height: screen.height * 0.02),
        HistoryTile(),
        SizedBox(height: screen.height * 0.02),
        HistoryTile(),
      ],
    );
  }

  Widget greeting() {
    Account account = context.read<Account>();
    String firstName = camelize(account.firstName);
    return Text(
      'Welcome $firstName',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40.0,
        height: 1.5,
        color: kLabelColor,
        fontFamily: 'Pacifico',
      ),
    );
  }

  Padding donateButton() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: size.width * 0.25,
      ),
      child: RoundedButton(
        label: 'Donate',
        onPressed: () {
          Navigator.of(context).pushNamed(DonationProduceSelectionScreen.id);
        },
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pushNamed(DonorDonationDetailScreen.id);
      },
      child: Container(
        height: screen.height * 0.15,
        width: screen.width * 0.8,
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TODO future for loop to see how many donations were done on either today or yesterday or 2 days ago
            //SizedBox(height: screen.height * 0.02),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Donation #23',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: screen.height * 0.02),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Date: 02/30/2021',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                  ),

                  //TODO get status from db
                  Expanded(
                    flex: 1,
                    child: Text(
                      'In Progress',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

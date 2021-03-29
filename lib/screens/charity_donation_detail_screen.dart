import 'package:flutter/material.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class CharityDonationDetailScreen extends StatelessWidget {
  static const String id = "charity_donation_detail_screen";

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
        child: ScrollableLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screen.height * 0.05),
              subtitle(screen, "Donation Details"),
              divider(),
              donationDetail(screen, "Donation# & Date"),
              subtitle(screen, "Donor Information"),
              divider(),
              donationDetail(screen, "Donor name, address& phone"),
              donationDetail(screen, "need assistance or not"),
              subtitle(screen, "Produce"),
              fruitTile(screen),
              divider(),
              SizedBox(height: screen.height * 0.04),
              Padding(
                padding: EdgeInsets.fromLTRB(50.0, 0, 50.0, 0),
                child: RoundedButton(
                    label: "Marked as Completed", onPressed: null),
              ),
              SizedBox(height: screen.height * 0.1),
              Container(
                width: screen.height * 0.2,
                height: screen.height * 0.08,
                child: RoundedButton(
                  label: "Decline",
                  onPressed: null,
                ),
              ),
              SizedBox(height: screen.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 2.0,
      thickness: 2.0,
      indent: 35.0,
      endIndent: 35.0,
    );
  }

  Widget subtitle(Size screen, String label) {
    return Container(
      height: screen.height * 0.05,
      width: screen.width * 0.8,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //TODO: should pass the object from donor's donation also, not string
  Widget donationDetail(Size screen, String label) {
    return Container(
      height: screen.height * 0.1,
      width: screen.width * 0.8,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget fruitTile(Size screen) {
    return Container(
      height: screen.height * 0.3,
      width: screen.width * 0.8,
      child: Expanded(
        child: GridView.count(
          primary: false,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          crossAxisCount: 2,
          children: [
            Container(
              decoration: BoxDecoration(
                color: kObjectColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: screen.height * 0.08,
              width: screen.height * 0.05,
              child: Column(
                children: [
                  Text(
                    'Fruit Name', //TODO: get fruit name from database
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: screen.height * 0.1,
                  ),
                  Text(
                    'Number %',
                    //TODO: get percentage from database
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ], //TODO: get correct fruit pictures from database and add them to container and also get the percentage from the database
              ),
            ),
          ],
        ),
      ),
    );
  }
}

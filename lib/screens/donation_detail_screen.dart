import 'package:flutter/material.dart';
//
import 'package:fruitfairy/constant.dart';

//TODO This screen needs to get the corresponding data from the database of a chosen donation. It needs the donation number,data,status,charity name, and the picture of fruit and percentage donated

class DonationDetailScreen extends StatelessWidget {
  static const String id = 'donation_detail_screen';

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: screen.height * 0.05,
            ),
            Text(
              'Donation Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            divider(screen),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Container(
              //TODO get the data of donation number, date and status
              height: 200.0,
              width: 300.0,
              color: Colors.white,
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected Charity:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screen.height * 0.02,
            ),
            //TODO get charity name from DB
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Charity Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screen.height * 0.04,
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screen.height * 0.04,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Produce:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget divider(Size screen) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: screen.height * 0.03,
      ),
      child: Divider(
        color: kLabelColor,
        height: 5.0,
        thickness: 4.0,
        indent: 35.0,
        endIndent: 35.0,
      ),
    );
  }
}

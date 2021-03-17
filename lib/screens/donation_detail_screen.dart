import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import 'home_screen.dart';

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
            Container(
              child: HistoryTile(),
            ),
            SizedBox(
              height: screen.height * 0.04,
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
                  //TODO: get status from database
                  'Status: From Database',
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
            SizedBox(
              height: screen.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //TODO: refactor to a separate class ?
                Container(
                  decoration: BoxDecoration(
                    color: kObjectBackgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 125.0,
                  width: 125.0,
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
                      SizedBox(height: screen.height * 0.1,),
                      Text('Number %', //TODO: get percentage from database
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),)
                      //TODO: get correct fruit pictures from database and add them to container and also get the percentage from the database
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kObjectBackgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 125.0,
                  width: 125.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kObjectBackgroundColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  height: 125.0,
                  width: 125.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget divider(Size screen) {
    return Divider(
      color: kLabelColor,
      height: 1.0,
      thickness: 4.0,
      indent: 35.0,
      endIndent: 35.0,
    );
  }
}

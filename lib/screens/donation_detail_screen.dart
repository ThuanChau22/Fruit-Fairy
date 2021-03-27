import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

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
        child: ScrollableLayout(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Donation Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screen.height * 0.02),
              divider(),
              SizedBox(height: screen.height * 0.02),
              HistoryTile(),
              SizedBox(height: screen.height * 0.04),
              subtitle("Selected Charity:"),
              SizedBox(height: screen.height * 0.02),
              //TODO get charity name from DB
              subtitle("charity Name"),
              SizedBox(height: screen.height * 0.04),
              subtitle("Status: From Database"),
              SizedBox(height: screen.height * 0.04),
             subtitle("Produce"),
              SizedBox(height: screen.height * 0.04),
              fruitTile(screen),
            ],
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 1.0,
      thickness: 4.0,
      indent: 35.0,
      endIndent: 35.0,
    );
  }

  Widget subtitle(String label){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget fruitTile(Size screen){
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

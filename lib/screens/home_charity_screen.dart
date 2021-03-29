import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/profile_charity_screen.dart';
import 'package:fruitfairy/screens/charity_wishlist_screen.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:provider/provider.dart';

import 'charity_donation_detail_screen.dart';

enum Options { Edit, SignOut, WishList }

class HomeCharityScreen extends StatefulWidget {
  static const String id = 'home_charity_screen';

  @override
  _HomeCharityScreenState createState() => _HomeCharityScreenState();
}

class _HomeCharityScreenState extends State<HomeCharityScreen> {
  bool _showSpinner = false;
  StreamSubscription<QuerySnapshot> _produceStream;

  @override
  void initState() {
    super.initState();
    Donation donation = context.read<Donation>();
    _produceStream = context.read<FireStoreService>().produceStream((data) {
      Produce produce = context.read<Produce>();
      produce.fromDB(data);
      List.from(donation.produce).forEach((fruitId) {
        if (!produce.fruits.containsKey(fruitId)) {
          donation.removeFruit(fruitId);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [settingsIcon()],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
          ),
          child: ScrollableLayout(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screen.height * 0.03,
              ),
              child: Column(
                children: [
                  greeting(),
                  wishListButton(),
                  //TODO: Donation tracking status
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Review Incoming Donations',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(CharityDonationDetailScreen.id);
                            },
                            child: HistoryTile()),
                        HistoryTile(),
                        HistoryTile(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screen.height * 0.01,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Donations In Progress',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        HistoryTile(),
                        HistoryTile(),
                        HistoryTile(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screen.height * 0.01,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Donations Completed',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        HistoryTile(),
                        HistoryTile(),
                        HistoryTile(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsIcon() {
    return Container(
      width: 50.0,
      child: PopupMenuButton<Options>(
        offset: Offset(0.0, 25.0),
        icon: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 0.0,
              ),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.settings,
              size: 25.0,
              color: kPrimaryColor,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: Options.Edit,
            child: Text("Profile"),
            textStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuItem(
            value: Options.SignOut,
            child: Text("Sign Out"),
            textStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        onSelected: (action) {
          switch (action) {
            case Options.Edit:
              HapticFeedback.mediumImpact();
              Navigator.of(context).pushNamed(ProfileCharityScreen.id);
              //arguments: {ProfileScreen.signOut: _signOut},
              break;

            case Options.SignOut:
              HapticFeedback.mediumImpact();
              //TODO signout method and lead to charity sign in
              // _signOut();
              break;
            default:
          }
        },
      ),
    );
  }

  Widget greeting() {
    return Text(
      'Welcome Charity',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40.0,
        color: Colors.white,
        // fontWeight: FontWeight.bold,
        fontFamily: 'Pacifico',
      ),
    );
  }

  Padding wishListButton() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: size.width * 0.25,
      ),
      child: RoundedButton(
        label: 'Wish List',
        onPressed: () {
          Navigator.of(context).pushNamed(CharityWishListScreen.id);
        },
      ),
    );
  }
}

class HistoryTile extends StatefulWidget {
  @override
  _HistoryTileState createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        height: screen.height * 0.15,
        width: screen.width * 0.8,
        color: kPrimaryColor,
        child: Column(
          children: [
            //TODO future for loop to see how many donations were done on either today or yesterday or 2 days ago
            Expanded(
              child: SizedBox(
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: screen.height * 0.02),
                    Container(
                      height: screen.height * 0.13,
                      width: screen.width * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Donation #23',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                              SizedBox(width: screen.width * 0.1),
                              //TODO get status from db
                              Container(
                                height: 50.0,
                                width: 100.0,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    'Assistance Needed',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screen.height * 0.01),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                //TODO: get donation date from db
                                child: Text(
                                  'Date: 02/30/2021',
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screen.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

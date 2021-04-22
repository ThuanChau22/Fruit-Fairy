import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/screens/charity_donation_detail_screen.dart';
import 'package:fruitfairy/screens/charity_wishlist_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class HomeCharityBody extends StatefulWidget {
  @override
  _HomeCharityBodyState createState() => _HomeCharityBodyState();
}

class _HomeCharityBodyState extends State<HomeCharityBody> {
  @override
  void initState() {
    super.initState();
    FireStoreService fireStore = context.read<FireStoreService>();
    WishList wishlist = context.read<WishList>();
    wishlist.addStream(fireStore.userStream((data) {
      if (data != null) {
        wishlist.fromDB(data);
      }
    }));
    Produce produce = context.read<Produce>();
    produce.addStream(fireStore.produceStream((data) {
      if (data != null) {
        produce.fromDB(data);
        bool removed = false;
        List<String>.from(wishlist.produceIds).forEach((produceId) {
          if (!produce.map.containsKey(produceId)) {
            wishlist.removeProduce(produceId);
            removed = true;
          }
        });
        fireStore.updateWishList(wishlist.produceIds);
        if (removed) {
          MessageBar(
            context,
            message:
                'One or more produce on your wish list are no longer available!',
          ).show();
        }
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Column(
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
                color: kLabelColor,
              ),
            ),
          ),
        ),
        Container(
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
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
                color: kLabelColor,
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
                color: kLabelColor,
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
    );
  }

  Widget greeting() {
    Account account = context.read<Account>();
    String charityName = camelize(account.charityName);
    return Text(
      charityName,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40.0,
        height: 1.5,
        color: kLabelColor,
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
            //TODO: load donations
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
                        color: kObjectColor,
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

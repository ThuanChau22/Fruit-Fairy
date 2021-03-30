import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/donation_produce_selection_screen.dart';
import 'package:fruitfairy/screens/donor_donation_detail_screen.dart';
import 'package:fruitfairy/screens/profile_donor_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

enum Profile { Edit, SignOut }

class HomeDonorScreen extends StatefulWidget {
  final Future<void> Function() signOut;

  HomeDonorScreen(this.signOut);

  @override
  _HomeDonorScreenState createState() => _HomeDonorScreenState();
}

class _HomeDonorScreenState extends State<HomeDonorScreen> {
  bool _showSpinner = false;
  String _initialName = '';
  String _name = '';

  StreamSubscription<QuerySnapshot> _produceStream;

  void _fetchData() {
    _showSpinner = true;
    Account account = context.read<Account>();
    String firstName = account.firstName;
    String lastName = account.lastName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      _initialName = '${firstName[0] + lastName[0]}'.toUpperCase();
      _name = camelize(firstName);
      _showSpinner = false;
    }
    Produce produce = context.watch<Produce>();
    _showSpinner = produce.fruits.isEmpty;
  }

  void _signOut() async {
    setState(() => _showSpinner = true);
    await widget.signOut();
    _produceStream.cancel();
    context.read<Produce>().clear();
    context.read<Donation>().clear();
    Navigator.of(context).pushNamedAndRemoveUntil(
      SignOptionScreen.id,
      (route) => false,
    );
    Navigator.of(context).pushNamed(SignInScreen.id);
    setState(() => _showSpinner = false);
  }

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
    donation.onEmptyBasket(() {
      Navigator.of(context).popUntil((route) {
        return route.settings.name == DonationProduceSelectionScreen.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _fetchData();
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [initialIcon()],
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget initialIcon() {
    return Container(
      width: 50.0,
      child: PopupMenuButton<Profile>(
        offset: Offset(0.0, 25.0),
        icon: Container(
          decoration: ShapeDecoration(
            color: kObjectColor,
            shape: CircleBorder(
              side: BorderSide.none,
            ),
          ),
          child: Center(
            child: Text(
              _initialName,
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: Profile.Edit,
            child: Text("Profile"),
            textStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuItem(
            value: Profile.SignOut,
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
            case Profile.Edit:
              HapticFeedback.mediumImpact();
              Navigator.of(context).pushNamed(
                ProfileDonorScreen.id,
                arguments: {ProfileDonorScreen.signOut: _signOut},
              );
              break;

            case Profile.SignOut:
              HapticFeedback.mediumImpact();
              _signOut();
              break;
            default:
          }
        },
      ),
    );
  }

  Widget greeting() {
    return Text(
      'Welcome $_name',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40.0,
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

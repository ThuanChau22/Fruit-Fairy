import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:strings/strings.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/edit_profile_screen.dart';
import 'package:fruitfairy/screens/picking_fruit_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

enum Profile { Edit, SignOut }

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSpinner = false;
  String _name = '';
  String _initialName = '';

  void _signOut() async {
    setState(() => _showSpinner = true);
    try {
      await context.read<FireAuthService>().signOut();
      context.read<FireStoreService>().setUID(null);
      context.read<Account>().clear();
      Navigator.of(context).pushNamedAndRemoveUntil(
        SignOptionScreen.id,
        (route) => false,
      );
      Navigator.of(context).pushNamed(SignInScreen.id);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Consumer<Account>(
      builder: (context, account, child) {
        String firstName = account.firstName;
        String lastName = account.lastName;
        _showSpinner = true;
        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          _initialName = '${firstName[0] + lastName[0]}'.toUpperCase();
          _name = camelize(firstName);
          _showSpinner = false;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: [initialIcon()],
          ),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kAppBarColor),
              ),
              child: ScrollableLayout(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screen.height * 0.05,
                  ),
                  child: Column(
                    children: [
                      greeting(),
                      donateButton(),
                      //TODO: Donation tracking status
                      Text(
                        'Donation History',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.8,
                        color: Colors.white,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text('1'),
                            ),
                            ListTile(
                              title: Text('2'),
                            ),
                            ListTile(
                              title: Text('3'),
                            ),
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
      },
    );
  }

  Widget initialIcon() {
    return Container(
      width: 50.0,
      child: PopupMenuButton<Profile>(
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
            child: Text(
              _initialName,
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20.0,
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
              Navigator.of(context).pushNamed(EditProfileScreen.id);
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
        color: Colors.white,
        // fontWeight: FontWeight.bold,
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
        labelColor: kPrimaryColor,
        backgroundColor: kObjectBackgroundColor,
        onPressed: () {
          Navigator.of(context).pushNamed(PickingFruitScreen.id);
        },
      ),
    );
  }
}

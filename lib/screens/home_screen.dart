import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/picking_fruit_screen.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:strings/strings.dart';
import 'package:fruitfairy/screens/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String firstName = '';
String lastName = '';

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService(FirebaseAuth.instance);
  bool _showSpinner = false;
  String _initialName = '';
  String _name = '';

  void _getCurrentUser() async {
    setState(() => _showSpinner = true);
    try {
      User user = _auth.currentUser();
      if (user != null) {
        Map<String, dynamic> userData =
            await FireStoreService.getUserData(user.uid);
        setState(() {
          String firstName = userData[kDBFirstNameField];
          String lastName = userData[kDBLastNameField];
          _name = camelize(firstName);
          _initialName = '${firstName[0] + lastName[0]}'.toUpperCase();
        });
      }
    } catch (e) {
      print(e.message);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  void _signOut() async {
    setState(() => _showSpinner = true);
    try {
      await _auth.signOut();
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
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
          backgroundColor: kAppBarColor,
          title: Text('Profile Page'),
          centerTitle: true,
          actions: [
            Container(
              width: 100.0,
              child: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(EditProfileScreen.id);
                      },
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: GestureDetector(
                      onTap: () {
                        _signOut();
                      },
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
                icon: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.white, width: 0),
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
              ),
            ),
          ]),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kAppBarColor),
          ),
          child: ScrollableLayout(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Welcome $_name!',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: RoundedButton(
                      onPressed: (){
                        Navigator.of(context).pushNamed(PickingFruitScreen.id);
                      },
                      label: 'Donate',
                      labelColor: kPrimaryColor,
                      backgroundColor: kObjectBackgroundColor,
                    ),
                  ),
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
  }
}

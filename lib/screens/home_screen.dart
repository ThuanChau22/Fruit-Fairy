import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:strings/strings.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _showSpinner = false;
  String _initialName = '';
  String _name = '';

  void getCurrentUser() async {
    setState(() => _showSpinner = true);
    try {
      User user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> data =
            (await _firestore.collection(kUserDB).doc(user.uid).get()).data();
        setState(() {
          String firstName = data[kFirstNameField];
          String lastName = data[kLastNameField];
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
    getCurrentUser();
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
            width: 40.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              //TODO: add drop down menu with sign out and edit profile option
              onPressed: () {
                _signOut();
              },
              child: Text(
                '$_initialName',
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
                    'Welcome $_name',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  RoundedButton(
                    onPressed: null,
                    label: 'Donate',
                    labelColor: kPrimaryColor,
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

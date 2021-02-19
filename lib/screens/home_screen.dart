import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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
  BuildContext _scaffoldContext;

  void getCurrentUser() async {
    setState(() => _showSpinner = true);
    try {
      User user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> data =
            (await _firestore.collection(kUserDB).doc(user.uid).get()).data();
        setState(() {
          _initialName = data[kFirstNameField][0] + data[kLastNameField][0];
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
    MessageBar(
      scaffoldContext: _scaffoldContext,
      message: 'Signing out',
    ).show();
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
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kAppBarColor,
        title: Text('Profile Page'),
        actions: [
          Container(
            height: 40.0,
            width: 40.0,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              //TODO: add drop down menu with sign out and edit profile option
              onPressed: signOut,
              child: Text(
                '$_initialName',
                style: TextStyle(
                  color: kBackgroundColor,
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
          opacity: 0.5,
          inAsyncCall: _showSpinner,
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
                      onPressed: null, label: 'Donate', color: Colors.white),
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
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
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
  String _name = '';

  void getCurrentUser() async {
    setState(() => _showSpinner = true);
    try {
      User user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> data =
            (await _firestore.collection(kUserDB).doc(user.uid).get()).data();
        setState(() {
          _name = data[kFirstNameField] + data[kLastNameField];
        });
      }
    } catch (e) {
      print(e.message);
    } finally {
      setState(() => _showSpinner = false);
    }
  }

  void signOut() async {
    setState(() => _showSpinner = true);
    try {
      await _auth.signOut();
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(SignOptionScreen.id);
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
      body: SafeArea(
        child: ModalProgressHUD(
          opacity: 0.5,
          inAsyncCall: _showSpinner,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi, $_name',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                FlatButton(
                  child: Text('Sign Out'),
                  onPressed: signOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

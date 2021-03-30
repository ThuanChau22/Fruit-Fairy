import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/screens/home_charity_screen.dart';
import 'package:fruitfairy/screens/home_donor_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSpinner = false;

  StreamSubscription<DocumentSnapshot> _userStream;

  Future<void> _signOut() async {
    await context.read<FireAuthService>().signOut();
    _userStream.cancel();
    context.read<FireStoreService>().clear();
    context.read<Account>().clear();
  }

  @override
  void initState() {
    super.initState();
    _userStream = context.read<FireStoreService>().userStream((data) {
      if (data != null) {
        context.read<Account>().fromDB(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _showSpinner = true;
    Account account = context.watch<Account>();
    if (account.firstName.isNotEmpty && account.lastName.isNotEmpty) {
      _showSpinner = false;
      return HomeDonorScreen(_signOut);
    }
    if (account.ein.isNotEmpty && account.charityName.isNotEmpty) {
      _showSpinner = false;
      return HomeCharityScreen(_signOut);
    }
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('Home')),
      ),
    );
  }
}

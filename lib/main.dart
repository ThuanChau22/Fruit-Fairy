import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/route_generator.dart';

void main() async {
  // Initialize app with Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FruitFairy());
}

class FruitFairy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FireAuthService>(create: (_) => FireAuthService()),
        Provider<FireStoreService>(create: (_) => FireStoreService()),
        ChangeNotifierProvider<Account>(create: (_) => Account()),
        ChangeNotifierProvider<Basket>(create: (_) => Basket()),
        ChangeNotifierProvider<Donation>(create: (_) => Donation()),
      ],
      child: Authentication(),
    );
  }
}

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check user authentication status
    User user = context.read<FireAuthService>().user;
    bool signedIn = user != null && user.emailVerified;
    context.read<FireStoreService>().uid(signedIn ? user.uid : null);
    return MaterialApp(
      initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
      onGenerateRoute: RouteGenerator.generate,
      theme: Theme.of(context).copyWith(
        scaffoldBackgroundColor: kPrimaryColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          backgroundColor: kAppBarColor,
          centerTitle: true,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kAppBarColor,
          actionTextColor: kLabelColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentTextStyle: TextStyle(
            color: kLabelColor,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

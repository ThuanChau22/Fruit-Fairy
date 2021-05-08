import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/charities.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firefunctions_service.dart';
import 'package:fruitfairy/services/firemessaging_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/services/route_generator.dart';

void main() async {
  // Initialize app with Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Listen to notification on background
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  runApp(FruitFairy());
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {}

class FruitFairy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FireAuthService>(create: (_) => FireAuthService()),
        Provider<FireFunctionsService>(create: (_) => FireFunctionsService()),
        Provider<FireMessagingService>(create: (_) => FireMessagingService()),
        Provider<FireStoreService>(create: (_) => FireStoreService()),
        ChangeNotifierProvider<Account>(create: (_) => Account()),
        ChangeNotifierProvider<Charities>(create: (_) => Charities()),
        ChangeNotifierProvider<Donation>(create: (_) => Donation('')),
        ChangeNotifierProvider<Donations>(create: (_) => Donations()),
        ChangeNotifierProvider<Produce>(create: (_) => Produce()),
        ChangeNotifierProvider<WishList>(create: (_) => WishList()),
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
    if (signedIn) {
      FireStoreService fireStore = context.read<FireStoreService>();
      fireStore.setUID(user.uid);
      fireStore.updateLastSignedIn();
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
      onGenerateRoute: RouteGenerator.generate,
      theme: Theme.of(context).copyWith(
        accentColor: kDarkPrimaryColor,
        scaffoldBackgroundColor: kPrimaryColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          backgroundColor: kDarkPrimaryColor,
          centerTitle: true,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: kSnackbarBackground.withOpacity(0.9),
          actionTextColor: kLabelColor,
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:fruitfairy/models/account.dart';
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
    return GestureDetector(
      onTap: () {
        // Dismiss on screen keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: MultiProvider(
        providers: [
          Provider<FireAuthService>(create: (_) => FireAuthService()),
          Provider<FireStoreService>(create: (_) => FireStoreService()),
          ChangeNotifierProvider<Account>(create: (_) => Account()),
        ],
        child: Authentication(),
      ),
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
      FireStoreService fireStoreService = context.read<FireStoreService>();
      fireStoreService.setUID(user.uid);
      fireStoreService.userData.then((userData) {
        context.read<Account>().fromMap(userData);
      });
    }
    return MaterialApp(
      theme: Theme.of(context).copyWith(brightness: Brightness.dark),
      onGenerateRoute: RouteGenerator.generate,
      initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
    );
  }
}

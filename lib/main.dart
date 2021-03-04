import 'package:flutter/material.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/route_generator.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FireStoreService>(create: (_) => FireStoreService()),
        ChangeNotifierProvider<Account>(create: (_) => Account()),
      ],
      child: Authentication(),
    );
  }
}

class Authentication extends StatelessWidget {
  void _fetchAccount(BuildContext context) async {
    FireStoreService fireStoreService = context.read<FireStoreService>();
    fireStoreService.uid(context.read<AuthService>().user.uid);
    context.read<Account>().fromMap(await fireStoreService.userData);
  }

  @override
  Widget build(BuildContext context) {
    // Check user authentication status
    User user = context.read<AuthService>().user;
    bool signedIn = user != null && user.emailVerified;
    if (signedIn) {
      _fetchAccount(context);
    }
    return GestureDetector(
      onTap: () {
        // Dismiss on screen keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: MaterialApp(
        onGenerateRoute: RouteGenerator.generate,
        initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/firestore_service.dart';
import 'package:fruitfairy/utils/route_generator.dart';
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
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
      ],
      child: Authentication(),
    );
  }
}

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check user authentication status
    User user = context.read<AuthService>().user;
    bool signedIn = user != null && user.emailVerified;
    context.read<FireStoreService>().uid = signedIn ? user.uid : null;
    return GestureWapper(
      child: MaterialApp(
        onGenerateRoute: RouteGenerator.generate,
        initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
      ),
    );
  }
}

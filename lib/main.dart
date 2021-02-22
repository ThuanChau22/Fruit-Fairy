import 'package:flutter/material.dart';
import 'package:fruitfairy/utils/auth_service.dart';
import 'package:fruitfairy/utils/route_generator.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Initialize app with Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FruitFairy());
}

class FruitFairy extends StatelessWidget {
  final AuthService _auth = AuthService(FirebaseAuth.instance);
  @override
  Widget build(BuildContext context) {
    // Check user authentication status
    User user = _auth.currentUser();
    bool signedIn = user != null && user.emailVerified;
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

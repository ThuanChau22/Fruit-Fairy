import 'package:flutter/material.dart';
import 'package:fruitfairy/screens/sign_option_screen.dart';
import 'package:fruitfairy/screens/signin_screen.dart';
import 'package:fruitfairy/screens/signup_donor_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/screens/signup_role_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FruitFairy());
}

class FruitFairy extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    bool signedIn = user != null && user.emailVerified;
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: MaterialApp(
        initialRoute: signedIn ? HomeScreen.id : SignOptionScreen.id,
        // routes: {
        //   HomeScreen.id: (context) => HomeScreen(),
        //   SignOptionScreen.id: (context) => SignOptionScreen(),
        //   SignInScreen.id: (context) => SignInScreen(),
        //   ResetPasswordScreen.id: (context) => ResetPasswordScreen(),
        //   SignUpRoleScreen.id: (context) => SignUpRoleScreen(),
        //   SignUpDonorScreen.id: (context) => SignUpDonorScreen(),
        // },
        onGenerateRoute: (settings) {
          Map<String, Widget> routes = {
            SignOptionScreen.id: SignOptionScreen(),
            SignInScreen.id: SignInScreen(),
            SignUpRoleScreen.id: SignUpRoleScreen(),
            SignUpDonorScreen.id: SignUpDonorScreen(),
            HomeScreen.id: HomeScreen(),
          };
          String screenName = settings.name;
          if (screenName == SignOptionScreen.id ||
              screenName == SignInScreen.id ||
              screenName == SignUpRoleScreen.id) {
            return MaterialPageRoute(builder: (context) => routes[screenName]);
          }
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return routes[screenName];
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              Animatable<Offset> tween = Tween(
                begin: Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

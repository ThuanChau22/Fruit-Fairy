import 'package:flutter/material.dart';

import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_role_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_donor_screen.dart';
import 'package:fruitfairy/screens/charity_selection_screen.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
import 'package:fruitfairy/screens/donation_detail_screen.dart';
import 'package:fruitfairy/screens/profile_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/screens/picking_fruit_screen.dart';
import 'package:fruitfairy/screens/contact_confirmation.dart';


// A class that generate screen routes associate with screen names
// including animation and passing arguments in transition
class RouteGenerator {
  // Map screen names with screen widgets
  static Map<String, Widget> _routes = {
    SignOptionScreen.id: SignOptionScreen(),
    SignInScreen.id: SignInScreen(),
    SignUpRoleScreen.id: SignUpRoleScreen(),
    SignUpDonorScreen.id: SignUpDonorScreen(),
    HomeScreen.id: HomeScreen(),
    ProfileScreen.id: ProfileScreen(),
    PickingFruitScreen.id: PickingFruitScreen(),
    DonationBasketScreen.id: DonationBasketScreen(),
    ContactConfirmationScreen.id: ContactConfirmationScreen(),
    DonationDetailScreen.id: DonationDetailScreen(),
    CharitySelectionScreen.id: CharitySelectionScreen(),
  };

  static Route<dynamic> generate(RouteSettings settings) {
    String screenName = settings.name;
    Object arguments = settings.arguments;

    // Screens with default transition animation
    if (screenName == SignOptionScreen.id ||
        screenName == SignInScreen.id ||
        screenName == SignUpRoleScreen.id) {
      return MaterialPageRoute(
        settings: RouteSettings(name: screenName, arguments: arguments),
        builder: (context) => _routes[screenName],
      );
    }

    // Screen with custom transition animation
    return PageRouteBuilder(
      settings: RouteSettings(name: screenName, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _routes[screenName];
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }
}

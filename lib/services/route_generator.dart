import 'package:flutter/material.dart';
//
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_role_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_donor_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_charity_screen.dart';
import 'package:fruitfairy/screens/charity_picking_fruit_screen.dart';
import 'package:fruitfairy/screens/charity_wishlist_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/screens/charity_home_screen.dart';
import 'package:fruitfairy/screens/profile_screen.dart';
import 'package:fruitfairy/screens/charity_profile_screen.dart';
import 'package:fruitfairy/screens/picking_fruit_screen.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
import 'package:fruitfairy/screens/donation_contact_screen.dart';
import 'package:fruitfairy/screens/charity_selection_screen.dart';
import 'package:fruitfairy/screens/donation_confirm_screen.dart';
import 'package:fruitfairy/screens/donation_detail_screen.dart';

// A class that generate screen routes associate with screen names
// including animation and passing arguments in transition
class RouteGenerator {
  // Map screen names with screen widgets
  static Map<String, Widget> _routes = {
    SignOptionScreen.id: SignOptionScreen(),
    SignInScreen.id: SignInScreen(),
    SignUpRoleScreen.id: SignUpRoleScreen(),
    SignUpDonorScreen.id: SignUpDonorScreen(),
    SignUpCharityScreen.id: SignUpCharityScreen(),
    HomeScreen.id: HomeScreen(),
    CharityHomeScreen.id: CharityHomeScreen(),
    ProfileScreen.id: ProfileScreen(),
    CharityProfileScreen.id: CharityProfileScreen(),
    PickingFruitScreen.id: PickingFruitScreen(),
    DonationBasketScreen.id: DonationBasketScreen(),
    DonationContactScreen.id: DonationContactScreen(),
    CharitySelectionScreen.id: CharitySelectionScreen(),
    DonationConfirmScreen.id: DonationConfirmScreen(),
    DonationDetailScreen.id: DonationDetailScreen(),
    CharityPickingFruitScreen.id: CharityPickingFruitScreen(),
    CharityWishListScreen.id: CharityWishListScreen(),
  };

  static List<String> defaultScreens = [
    SignOptionScreen.id,
    SignInScreen.id,
    SignUpRoleScreen.id,
  ];

  static Route<dynamic> generate(RouteSettings settings) {
    String screenName = settings.name;
    Object arguments = settings.arguments;

    // Screens with default transition animation
    if (defaultScreens.contains(screenName)) {
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

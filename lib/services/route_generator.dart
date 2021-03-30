import 'package:flutter/material.dart';
//
import 'package:fruitfairy/screens/authentication/sign_option_screen.dart';
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_role_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_donor_screen.dart';
import 'package:fruitfairy/screens/authentication/signup_charity_screen.dart';
import 'package:fruitfairy/screens/charity_donation_detail_screen.dart';
import 'package:fruitfairy/screens/charity_produce_selection_screen.dart';
import 'package:fruitfairy/screens/charity_wishlist_screen.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
import 'package:fruitfairy/screens/donation_charity_selection_screen.dart';
import 'package:fruitfairy/screens/donation_confirm_screen.dart';
import 'package:fruitfairy/screens/donation_contact_screen.dart';
import 'package:fruitfairy/screens/donation_produce_selection_screen.dart';
import 'package:fruitfairy/screens/donor_donation_detail_screen.dart';
import 'package:fruitfairy/screens/profile_charity_screen.dart';
import 'package:fruitfairy/screens/profile_donor_screen.dart';
import 'package:fruitfairy/screens/home_screen.dart';

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
    CharityDonationDetailScreen.id: CharityDonationDetailScreen(),
    CharityProduceSelectionScreen.id: CharityProduceSelectionScreen(),
    CharityWishListScreen.id: CharityWishListScreen(),
    DonationBasketScreen.id: DonationBasketScreen(),
    DonationCharitySelectionScreen.id: DonationCharitySelectionScreen(),
    DonationConfirmScreen.id: DonationConfirmScreen(),
    DonationContactScreen.id: DonationContactScreen(),
    DonationProduceSelectionScreen.id: DonationProduceSelectionScreen(),
    DonorDonationDetailScreen.id: DonorDonationDetailScreen(),
    ProfileCharityScreen.id: ProfileCharityScreen(),
    ProfileDonorScreen.id: ProfileDonorScreen(),
    HomeScreen.id: HomeScreen(),
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

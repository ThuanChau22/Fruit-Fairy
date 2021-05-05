import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
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
import 'package:fruitfairy/screens/authentication/signin_screen.dart';
import 'package:fruitfairy/screens/home_charity_body.dart';
import 'package:fruitfairy/screens/home_donor_body.dart';
import 'package:fruitfairy/screens/profile_charity_screen.dart';
import 'package:fruitfairy/screens/profile_donor_screen.dart';
import 'package:fruitfairy/services/fireauth_service.dart';
import 'package:fruitfairy/services/firestore_service.dart';

enum Profile { Edit, SignOut }
enum Role { Donor, Charity }

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSpinner = false;

  Future<void> _signOut() async {
    setState(() => _showSpinner = true);
    context.read<Account>().clear();
    context.read<Charities>().clear();
    context.read<Donation>().clear();
    context.read<Donations>().clear();
    context.read<Produce>().clear();
    context.read<WishList>().clear();
    context.read<FireStoreService>().clear();
    await context.read<FireAuthService>().signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
      SignOptionScreen.id,
      (route) => false,
    );
    Navigator.of(context).pushNamed(SignInScreen.id);
    setState(() => _showSpinner = false);
  }

  @override
  void initState() {
    super.initState();
    FireStoreService fireStore = context.read<FireStoreService>();
    fireStore.accountStream(context.read<Account>());
  }

  @override
  Widget build(BuildContext context) {
    _showSpinner = true;
    Role role;
    Account account = context.watch<Account>();
    if (account.firstName.isNotEmpty && account.lastName.isNotEmpty) {
      role = Role.Donor;
      _showSpinner = false;
    }
    if (account.ein.isNotEmpty && account.charityName.isNotEmpty) {
      role = Role.Charity;
      _showSpinner = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [profileIcon(role)],
      ),
      body: SafeArea(
        child: Container(
          decoration: kGradientBackground,
          child: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAccentColor),
            ),
            child: roleLayout(role),
          ),
        ),
      ),
    );
  }

  Widget profileIcon(Role role) {
    String initialName = '';
    if (role == Role.Donor) {
      Account account = context.read<Account>();
      String firstName = account.firstName;
      String lastName = account.lastName;
      initialName = '${firstName[0] + lastName[0]}'.toUpperCase();
    }
    return Container(
      width: 50.0,
      child: PopupMenuButton<Profile>(
        offset: Offset(0.0, 25.0),
        icon: Container(
          decoration: ShapeDecoration(
            color: kObjectColor,
            shape: CircleBorder(
              side: BorderSide.none,
            ),
          ),
          child: Center(
            child: role == Role.Donor
                ? Text(
                    initialName,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.person_sharp,
                    size: 25.0,
                    color: kPrimaryColor,
                  ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: Profile.Edit,
            child: Text("Profile"),
            textStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuItem(
            value: Profile.SignOut,
            child: Text("Sign Out"),
            textStyle: TextStyle(
              color: kPrimaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        onSelected: (action) {
          switch (action) {
            case Profile.Edit:
              HapticFeedback.mediumImpact();
              switch (role) {
                case Role.Donor:
                  Navigator.of(context).pushNamed(ProfileDonorScreen.id);
                  break;
                case Role.Charity:
                  Navigator.of(context).pushNamed(ProfileCharityScreen.id);
                  break;
                default:
              }
              break;

            case Profile.SignOut:
              HapticFeedback.mediumImpact();
              _signOut();
              break;
          }
        },
      ),
    );
  }

  Widget roleLayout(Role role) {
    switch (role) {
      case Role.Donor:
        return HomeDonorBody();
      case Role.Charity:
        return HomeCharityBody();
      default:
        return Container();
    }
  }
}

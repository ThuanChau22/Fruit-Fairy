import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/charities.dart';
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/screens/donation_confirm_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/charity_tile.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/popup_diaglog.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

enum ViewMode { Init, Empty, Suggestion }

class DonationCharitySelectionScreen extends StatefulWidget {
  static const String id = 'donation_charity_selection_screen';

  @override
  _DonationCharitySelectionScreenState createState() =>
      _DonationCharitySelectionScreenState();
}

class _DonationCharitySelectionScreenState
    extends State<DonationCharitySelectionScreen> {
  ViewMode _mode = ViewMode.Init;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _showSpinner = true);
      FireStoreService fireStore = context.read<FireStoreService>();
      Charities charities = context.read<Charities>();
      Donation donation = context.read<Donation>();
      if (donation.isUpdated) {
        charities.clear();
        charities.setList(await fireStore.charitySuggestions(
          donation: donation,
          limitDistance: Charities.MaxDistance,
          limitCharity: Charities.MaxCharity,
        ));
        donation.clearUpdated();
      }
      _mode = charities.list.isEmpty ? ViewMode.Empty : ViewMode.Suggestion;
      setState(() => _showSpinner = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MessageBar(context).hide();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Charity Selection'),
          actions: [helpButton()],
        ),
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
            ),
            child: Column(
              children: [
                layoutMode(),
                buttonSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget layoutMode() {
    switch (_mode) {
      case ViewMode.Init:
        return Expanded(
          child: Container(),
        );
        break;

      case ViewMode.Empty:
        return Expanded(
          child: Center(
            child: Text(
              //TODO: Message for no suggestion
              '(No Suggestion)',
              style: TextStyle(
                color: kLabelColor,
                fontSize: 25.0,
              ),
            ),
          ),
        );
        break;

      default:
        return charityOptions();
        break;
    }
  }

  Widget charityOptions() {
    List<Widget> widgets = [instructionSection()];
    widgets.addAll(charityTiles());
    Size screen = MediaQuery.of(context).size;
    return Expanded(
      child: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: screen.height * 0.01,
              horizontal: screen.width * 0.1,
            ),
            child: widgets[index],
          );
        },
      ),
    );
  }

  Widget instructionSection() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.02,
      ),
      child: Text(
        'Select 3 charities:',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kLabelColor,
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
        ),
      ),
    );
  }

  Widget helpButton() {
    return RoundedIconButton(
      radius: 30.0,
      icon: Icon(
        Icons.help_outline,
        color: kLabelColor,
        size: 30.0,
      ),
      hitBoxPadding: 5.0,
      buttonColor: Colors.transparent,
      onPressed: () {
        PopUpDialog(
          context,
          message:
              'Please select the top three charities to donate to. If your first prioritized charity does not accept your donation, it will be offered to the second prioritized charity and so on.',
        ).show();
      },
    );
  }

  List<Widget> charityTiles() {
    List<Widget> charityTiles = [];
    Donation donation = context.read<Donation>();
    List<Charity> selectedCharities = donation.charities;
    Charities charities = context.read<Charities>();
    charities.list.forEach((charity) {
      bool selected = selectedCharities.contains(charity);
      int selectedOrder = selectedCharities.indexOf(charity) + 1;
      charityTiles.add(CharityTile(
        charityName: charity.name,
        selectedOrder: selected ? '$selectedOrder' : '',
        onTap: () {
          MessageBar(context).hide();
          setState(() {
            if (selected) {
              donation.removeCharity(charity);
            } else {
              donation.pickCharity(charity);
            }
          });
        },
      ));
    });
    return charityTiles;
  }

  Widget buttonSection() {
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: Column(
        children: [
          Divider(
            color: kLabelColor,
            height: 5.0,
            thickness: 2.0,
          ),
          nextButton(),
        ],
      ),
    );
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
        horizontal: screen.width * 0.25,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          if (context.read<Donation>().charities.isNotEmpty) {
            Navigator.of(context).pushNamed(DonationConfirmScreen.id);
          } else {
            MessageBar(
              context,
              message: 'Please select at least one charity',
            ).show();
          }
        },
      ),
    );
  }
}

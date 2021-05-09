import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/status.dart';
import 'package:fruitfairy/screens/home_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class CharityDonationDetailScreen extends StatefulWidget {
  static const String id = "charity_donation_detail_screen";

  @override
  _CharityDonationDetailScreenState createState() =>
      _CharityDonationDetailScreenState();
}

class _CharityDonationDetailScreenState
    extends State<CharityDonationDetailScreen> {
  bool _showSpinner = false;
  Donation _donation;

  @override
  Widget build(BuildContext context) {
    FireStoreService fireStore = context.read<FireStoreService>();
    Donations donations = context.watch<Donations>();
    Map<String, dynamic> donationStorage = donations.map;
    String donationId = ModalRoute.of(context).settings.arguments;
    if (!donationStorage.containsKey(donationId)) {
      fireStore.loadDonationDetails(
        donationId,
        donations,
        isCharity: true,
        notify: (removed) {
          Navigator.of(context).popUntil((route) {
            return route.settings.name == HomeScreen.id;
          });
        },
      );
    } else {
      _donation = donationStorage[donationId];
    }
    Produce produce = context.watch<Produce>();
    bool loadingDonation = _donation == null || produce.isLoading;
    if (!loadingDonation) {
      context.read<FireStoreService>().loadDonationProduce(_donation, produce);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Donation Details')),
      body: SafeArea(
        child: Container(
          decoration: kGradientBackground,
          child: ModalProgressHUD(
            inAsyncCall: _showSpinner || loadingDonation,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAccentColor),
            ),
            child: loadingDonation ? Container() : donationDetails(),
          ),
        ),
      ),
    );
  }

  Widget donationDetails() {
    List<Widget> widgets = [
      groupLabel('Status'),
      statusTile(),
      groupLabel('Donor Information'),
      donorInfo(),
      assistanceNeeded(),
      groupLabel('Produce'),
      selectedFruits(),
      buttonSection(),
    ];
    Size screen = MediaQuery.of(context).size;
    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.1,
          ),
          child: widgets[index],
        );
      },
    );
  }

  Widget groupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              color: kLabelColor,
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(
            color: kLabelColor,
            height: 2.0,
            thickness: 2.0,
          ),
        ],
      ),
    );
  }

  Widget fieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: kLabelColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
    );
  }

  Widget statusTile() {
    DateTime dateTime = _donation.createdAt;
    Status status = _donation.status;
    Color statusColor;
    if (status.isPennding) {
      statusColor = kPendingStatus;
    }
    if (status.isInProgress) {
      statusColor = kInProgressStatus;
    }
    if (status.isDeclined) {
      statusColor = kDeniedStatus;
    }
    if (status.isCompleted) {
      statusColor = kCompletedStatus;
    }
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.02,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fieldLabel('Created on'),
                  fieldLabel(DateFormat.yMMMd().add_Hm().format(dateTime)),
                ],
              ),
              Container(
                width: 125,
                decoration: BoxDecoration(
                  color: kObjectColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    status.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget donorInfo() {
    Map<String, String> address = _donation.address;
    String street = address[FireStoreService.kAddressStreet];
    String city = address[FireStoreService.kAddressCity];
    String state = address[FireStoreService.kAddressState];
    String zip = address[FireStoreService.kAddressZip];
    Map<String, String> phone = _donation.phone;
    String intlPhoneNumber = phone[FireStoreService.kPhoneDialCode];
    String phoneNumber = phone[FireStoreService.kPhoneNumber];
    if (phoneNumber != null) {
      intlPhoneNumber += ' (${phoneNumber.substring(0, 3)})';
      intlPhoneNumber += ' ${phoneNumber.substring(3, 6)}';
      intlPhoneNumber += ' ${phoneNumber.substring(6, 10)}';
    }
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel('${_donation.donorName}'),
          fieldLabel('$street'),
          fieldLabel('$city, $state, $zip'),
          fieldLabel('Phone: $intlPhoneNumber'),
        ],
      ),
    );
  }

  Widget assistanceNeeded() {
    Size screen = MediaQuery.of(context).size;
    return Visibility(
      visible: _donation.needCollected,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screen.height * 0.01,
          horizontal: screen.width * 0.05,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kObjectColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Assistance Requested',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kCompletedStatus,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = screen.width >= 600 ? 4 : 2;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
      ),
      child: CustomGrid(
        padding: EdgeInsets.all(10.0),
        assistPadding: screen.width * 0.1,
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitList = [];
    Produce produce = context.read<Produce>();
    Map<String, ProduceItem> produceStorage = produce.map;
    _donation.produce.forEach((produceId, produceItem) {
      if (produceStorage.containsKey(produceId)) {
        fruitList.add(Container(
          decoration: BoxDecoration(
            color: kObjectColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: FruitTile(
            fruitName: produceStorage[produceId].name,
            fruitImage: produceStorage[produceId].imageURL,
            isLoading: produceStorage[produceId].isLoading,
            percentage: _donation.needCollected ? '${produceItem.amount}' : '',
          ),
        ));
      }
    });
    return fruitList;
  }

  Widget buttonSection() {
    Status status = _donation.status;
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
      ),
      child: status.isPennding || status.isInProgress
          ? Column(
              children: [
                Divider(
                  color: kLabelColor,
                  height: 2.0,
                  thickness: 2.0,
                ),
                status.isPennding ? pendingState() : inProgressState(),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  //TODO: Handle donation status from charity's action
  Widget pendingState() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.05,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.03,
              ),
              child: RoundedButton(
                label: 'Accept',
                onPressed: () {},
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.03,
              ),
              child: RoundedButton(
                label: 'Decline',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inProgressState() {
    Size screen = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: screen.height * 0.03,
            horizontal: screen.width * 0.05,
          ),
          child: RoundedButton(
            label: 'Mark as Completed',
            onPressed: () {},
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: screen.height * 0.03,
            horizontal: screen.width * 0.2,
          ),
          child: RoundedButton(
            label: 'Decline',
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

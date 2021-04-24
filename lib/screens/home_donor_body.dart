import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/status.dart';
import 'package:fruitfairy/screens/donation_produce_selection_screen.dart';
import 'package:fruitfairy/screens/donor_donation_detail_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/donation_tile.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/scrollable_layout.dart';

class HomeDonorBody extends StatefulWidget {
  @override
  _HomeDonorBodyState createState() => _HomeDonorBodyState();
}

class _HomeDonorBodyState extends State<HomeDonorBody> {
  final ScrollController _scrollController = new ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = true;

  @override
  void initState() {
    super.initState();
    FireStoreService fireStore = context.read<FireStoreService>();
    Donations donations = context.read<Donations>();
    fireStore.donationStreamDonor(donations, onComplete: () {
      setState(() => _isLoading = false);
    });
    _scrollController.addListener(() {
      ScrollPosition pos = _scrollController.position;
      if (pos.pixels == pos.maxScrollExtent) {
        // setState(() => _isLoadingMore = true);
        int currentSize = donations.map.length;
        fireStore.donationStreamDonor(donations, onComplete: () {
          setState(() => _isLoadingMore = currentSize != donations.map.length);
        });
      }
    });
    Donation donation = context.read<Donation>();
    donation.onEmptyBasket(() {
      Navigator.of(context).popUntil((route) {
        return route.settings.name == DonationProduceSelectionScreen.id;
      });
    });
    Produce produce = context.read<Produce>();
    fireStore.produceStream(produce, onComplete: () {
      bool removed = false;
      List<String>.from(donation.produce.keys).forEach((produceId) {
        if (!produce.map.containsKey(produceId)) {
          donation.removeProduce(produceId);
          removed = true;
        }
      });
      if (removed) {
        MessageBar(
          context,
          message:
              'One or more produce on your basket are no longer available!',
        ).show();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return ScrollableLayout(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          top: screen.height * 0.03,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              greeting(),
              donateButton(),
              donationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget greeting() {
    Account account = context.read<Account>();
    String firstName = camelize(account.firstName);
    return Text(
      'Welcome $firstName',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40.0,
        height: 1.5,
        color: kLabelColor,
        fontFamily: 'Pacifico',
      ),
    );
  }

  Widget donateButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: screen.width * 0.25,
      ),
      child: RoundedButton(
        label: 'Donate',
        onPressed: () {
          Navigator.of(context).pushNamed(DonationProduceSelectionScreen.id);
        },
      ),
    );
  }

  Widget donationSection() {
    Size screen = MediaQuery.of(context).size;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          top: screen.height * 0.02,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            border: Border.all(
              color: kObjectColor.withOpacity(0.3),
              width: 2.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screen.height * 0.03,
            ),
            child: Column(
              children: [
                Text(
                  'My Donations',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: kLabelColor,
                  ),
                ),
                donationLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget donationLayout() {
    Donations donations = context.watch<Donations>();
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
          ),
        ),
      );
    }
    if (donations.map.isEmpty) {
      // TODO: Message on empty donation
      return Expanded(
        child: Center(
          child: Text(
            '(Empty)',
            style: TextStyle(
              color: kLabelColor.withOpacity(0.5),
              fontSize: 20.0,
            ),
          ),
        ),
      );
    }
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.08,
      ),
      child: Column(children: donationTiles()),
    );
  }

  List<Widget> donationTiles() {
    List<Widget> donationTiles = [];
    Donations donations = context.read<Donations>();
    List<Donation> donationList = donations.map.values.toList();
    donationList.sort();
    bool hasActive = false;
    bool hasHistory = false;
    donationList.forEach((donation) {
      Status status = donation.status;
      if ((status.isPennding || status.isInProgress) && !hasActive) {
        donationTiles.add(groupLabel('Active'));
        hasActive = true;
      }
      if ((status.isDenied || status.isCompleted) && !hasHistory) {
        donationTiles.add(groupLabel('History'));
        hasHistory = true;
      }
      donationTiles.add(Padding(
        padding: EdgeInsets.only(
          top: 20.0,
        ),
        child: DonationTile(
          charityName: donation.charityName,
          dateTime: donation.createdAt.toDate(),
          status: donation.status,
          onTap: () {
            Navigator.of(context).pushNamed(DonorDonationDetailScreen.id);
            print(donation.id);
          },
        ),
      ));
    });
    if (donationList.length >= Donations.LOAD_LIMIT) {
      donationTiles.add(loadingTile());
    }
    return donationTiles;
  }

  Widget loadingTile() {
    return Visibility(
      visible: _isLoadingMore,
      child: Padding(
        padding: EdgeInsets.only(
          top: 20.0,
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
        ),
      ),
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
}

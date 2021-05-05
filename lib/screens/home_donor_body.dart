import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/produce.dart';
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
  final ScrollController _scroll = new ScrollController();
  final double _scrollOffset = 60.0;

  Timer _loadingTimer = Timer(Duration.zero, () {});
  bool _isLoadingInit = true;
  bool _isLoadingMore = true;

  void initProduce() async {
    FireStoreService fireStore = context.read<FireStoreService>();

    /// Init Produce
    Produce produce = context.read<Produce>();
    await fireStore.produceStream(produce, onData: () {
      if (mounted) {
        bool removed = false;
        Donation donation = context.read<Donation>();
        Map<String, ProduceItem> produceStorage = produce.map;
        for (String produceId in donation.produce.keys.toList()) {
          bool hasProduce = produceStorage.containsKey(produceId);
          if (hasProduce && !produceStorage[produceId].enabled) {
            donation.removeProduce(produceId);
            removed = true;
          }
        }
        String notifyMessage = 'One or more produce'
            ' on your basket are no longer available!';
        if (removed) {
          MessageBar(context, message: notifyMessage).show();
        }
      }
    });

    /// Init Donation
    Donation donation = context.read<Donation>();
    donation.onEmptyBasket(() {
      Navigator.of(context).popUntil((route) {
        return route.settings.name == DonationProduceSelectionScreen.id;
      });
    });
  }

  void initDonations() {
    FireStoreService fireStore = context.read<FireStoreService>();

    /// Init Donations
    Donations donations = context.read<Donations>();
    fireStore.donationStreamDonor(donations, onData: () {
      if (mounted) {
        setState(() => _isLoadingInit = false);
      }
    });

    /// Load Donations on Scroll
    _scroll.addListener(() {
      ScrollPosition pos = _scroll.position;
      bool loadTriggered = pos.pixels + _scrollOffset >= pos.maxScrollExtent;
      if (loadTriggered && !_loadingTimer.isActive) {
        _loadingTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
        int currentSize = donations.map.length;
        fireStore.donationStreamDonor(donations, onData: () {
          if (mounted && currentSize < donations.map.length) {
            setState(() => _isLoadingMore = true);
            _loadingTimer.cancel();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initProduce();
    initDonations();
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
    _loadingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return ScrollableLayout(
      controller: _scroll,
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
    if (_isLoadingInit) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kAccentColor),
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

  //TODO: Message on empty history
  List<Widget> donationTiles() {
    List<Widget> donationTiles = [];
    Donations donations = context.watch<Donations>();
    List<Donation> donationList = donations.map.values.toList();
    donationList.sort();
    donationTiles.add(groupLabel('Active'));
    int i = 0;
    while (i < donationList.length &&
        (donationList[i].status.isPennding ||
            donationList[i].status.isInProgress)) {
      donationTiles.add(donationTile(donationList[i++]));
    }
    if (i == 0) {
      donationTiles.add(emptyLabel('You have no active donation'));
    }
    donationTiles.add(groupLabel('History'));
    if (i == donationList.length) {
      donationTiles.add(emptyLabel('Empty History'));
    }
    while (i < donationList.length) {
      donationTiles.add(donationTile(donationList[i++]));
    }
    donationTiles.add(loadingTile());
    return donationTiles;
  }

  Widget groupLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
        bottom: 10.0,
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

  Widget emptyLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      height: screen.height * 0.1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screen.height * 0.025,
          horizontal: screen.width * 0.1,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kLabelColor.withOpacity(0.5),
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  Widget donationTile(Donation donation) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      child: DonationTile(
        status: donation.status,
        dateTime: donation.createdAt,
        userName: donation.charities.first.name,
        onTap: () {
          Navigator.of(context).pushNamed(
            DonorDonationDetailScreen.id,
            arguments: donation.id,
          );
        },
      ),
    );
  }

  Widget loadingTile() {
    Donations donations = context.read<Donations>();
    bool underLimit = donations.map.length < Donations.LoadLimit;
    return Visibility(
      visible: !underLimit && _isLoadingMore,
      child: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(kAccentColor),
        ),
      ),
    );
  }
}

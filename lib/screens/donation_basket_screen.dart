import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/donation_contact_screen.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

class DonationBasketScreen extends StatefulWidget {
  static const String id = 'donation_basket_screen';

  @override
  _DonationBasketScreenState createState() => _DonationBasketScreenState();
}

class _DonationBasketScreenState extends State<DonationBasketScreen> {
  final Color _selectedColor = Colors.green.shade100;

  bool _collectOption = true;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    Donation donation = context.read<Donation>();
    listener = () {
      if (donation.produce.isEmpty) {
        donation.removeListener(listener);
        Navigator.of(context).pop();
      }
    };
    donation.addListener(listener);
    _collectOption = donation.needCollected;
  }

  @override
  Widget build(BuildContext context) {
    Donation donation = context.read<Donation>();
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        donation.removeListener(listener);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Donation')),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screen.height * 0.03,
              horizontal: screen.width * 0.05,
            ),
            child: Column(
              children: [
                sectionLabel('Do you need help collecting?'),
                collectOptionTile(),
                divider(),
                Visibility(
                  visible: donation.needCollected,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screen.height * 0.01,
                        ),
                        child: sectionLabel(
                          'Adjust percentage of produce you want to donate:',
                        ),
                      ),
                    ],
                  ),
                ),
                selectedFruits(),
                divider(),
                SizedBox(height: screen.height * 0.03),
                nextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 5.0,
      thickness: 3.0,
    );
  }

  Widget sectionLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.1,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: kLabelColor,
        ),
      ),
    );
  }

  Widget collectOptionTile() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.02,
      ),
      child: Row(
        children: [
          collectOptionButton(
            label: 'Yes',
            needCollected: true,
          ),
          collectOptionButton(
            label: 'No',
            needCollected: false,
          ),
        ],
      ),
    );
  }

  Widget collectOptionButton({
    @required String label,
    @required bool needCollected,
  }) {
    Size screen = MediaQuery.of(context).size;
    bool selected = _collectOption == needCollected;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.08,
        ),
        child: RoundedButton(
          label: label,
          backgroundColor: selected ? _selectedColor : kObjectColor,
          onPressed: () {
            setState(() {
              _collectOption = needCollected;
              context.read<Donation>().setNeedCollected(_collectOption);
            });
          },
        ),
      ),
    );
  }

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = 2;
    if (screen.width >= 600) {
      axisCount = 4;
    }
    bool squeeze = screen.height < screen.width;
    bool needCollect = context.read<Donation>().needCollected;
    return Expanded(
      child: GridView.count(
        primary: false,
        childAspectRatio: needCollect ? (squeeze ? 5 : 2.5) : 1.0,
        crossAxisCount: needCollect ? 1 : axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> list = [];
    Map<String, Fruit> produce = context.watch<Produce>().fruits;
    Donation donation = context.watch<Donation>();
    donation.produce.forEach((fruitId) {
      list.add(
        removableFruitTile(
          fruit: produce[fruitId],
          onPressed: () {
            setState(() {
              produce[fruitId].clear();
              donation.removeFruit(fruitId);
            });
          },
        ),
      );
    });
    return list;
  }

  Widget removableFruitTile({
    @required Fruit fruit,
    @required VoidCallback onPressed,
  }) {
    Size screen = MediaQuery.of(context).size;
    bool squeeze = screen.height < screen.width;
    bool needCollect = context.read<Donation>().needCollected;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * (needCollect ? (squeeze ? 0.2 : 0.02) : 0.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              bottom: needCollect ? 0.0 : 20.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: kObjectColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: needCollect
                  ? adjustableFruitTile(fruit)
                  : FruitTile(
                      fruitName: fruit.name,
                      fruitImage: fruit.imageURL,
                    ),
            ),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: removeButton(onPressed),
          ),
        ],
      ),
    );
  }

  Widget removeButton(VoidCallback onPressed) {
    return RoundedIconButton(
      radius: 24.0,
      icon: Icon(
        Icons.close,
        color: kLabelColor,
        size: 16.0,
      ),
      buttonColor: kDarkPrimaryColor,
      onPressed: onPressed,
    );
  }

  Widget adjustableFruitTile(Fruit fruit) {
    Size screen = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: kObjectColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: SizedBox.shrink(),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(
                top: screen.height * 0.01,
              ),
              child: FruitTile(
                fruitName: fruit.name,
                fruitImage: fruit.imageURL,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(
                    '${fruit.amount}%',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    adjustButton(
                      icon: Icons.remove,
                      onPressed: () {
                        setState(() {
                          fruit.decrease(5);
                        });
                      },
                    ),
                    adjustButton(
                      icon: Icons.add,
                      onPressed: () {
                        setState(() {
                          fruit.increase(5);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget adjustButton({
    @required IconData icon,
    @required VoidCallback onPressed,
  }) {
    return RoundedIconButton(
      radius: 30.0,
      icon: Icon(
        icon,
        color: kLabelColor,
        size: 30.0,
      ),
      buttonColor: kPrimaryColor,
      onPressed: onPressed,
    );
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'Next',
        onPressed: () {
          if (context.read<Donation>().produce.isNotEmpty) {
            Navigator.of(context).pushNamed(DonationContactScreen.id);
          }
        },
      ),
    );
  }
}

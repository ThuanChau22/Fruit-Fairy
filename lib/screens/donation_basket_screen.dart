import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/screens/donation_contact_screen.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

class DonationBasketScreen extends StatefulWidget {
  static const String id = 'donation_basket_screen';

  @override
  _DonationBasketScreenState createState() => _DonationBasketScreenState();
}

enum CollectOption { Yes, No }

class _DonationBasketScreenState extends State<DonationBasketScreen> {
  final Color _selectedColor = Colors.green.shade100;
  CollectOption _collectOption = CollectOption.Yes;

  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    Basket basket = context.read<Basket>();
    listener = () {
      if (basket.selectedFruits.isEmpty) {
        basket.removeListener(listener);
        Navigator.of(context).pop();
      }
    };
    basket.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Basket basket = context.read<Basket>();
        basket.removeListener(listener);
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
                  visible: _collectOption == CollectOption.Yes,
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
            option: CollectOption.Yes,
          ),
          collectOptionButton(
            label: 'No',
            option: CollectOption.No,
          ),
        ],
      ),
    );
  }

  Widget collectOptionButton({
    @required String label,
    @required CollectOption option,
    Fruit fruit,
  }) {
    Size screen = MediaQuery.of(context).size;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.08,
        ),
        child: RoundedButton(
          label: label,
          backgroundColor:
              _collectOption == option ? _selectedColor : kObjectColor,
          onPressed: () {
            setState(() {
              _collectOption = option;
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
    bool needCollect = _collectOption == CollectOption.Yes;
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
    Basket basket = context.watch<Basket>();
    Map<String, Fruit> fruits = basket.fruits;
    basket.selectedFruits.forEach((fruitId) {
      list.add(
        removableFruitTile(
          fruit: fruits[fruitId],
          onPressed: () {
            setState(() {
              basket.removeFruit(fruitId);
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
    bool needCollect = _collectOption == CollectOption.Yes;
    fruit.changeOption(false);
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
              child: _collectOption == CollectOption.Yes
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
    fruit.changeOption(true);
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
          if (context.read<Basket>().selectedFruits.isNotEmpty) {
            Navigator.of(context).pushNamed(DonationContactScreen.id);
          }
        },
      ),
    );
  }
}

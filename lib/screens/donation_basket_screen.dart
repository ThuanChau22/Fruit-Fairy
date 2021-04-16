import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/donation_contact_screen.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
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

  @override
  void initState() {
    super.initState();
    _collectOption = context.read<Donation>().needCollected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Basket')),
      body: SafeArea(
        child: Column(
          children: [
            basketSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  Widget basketSection() {
    Size screen = MediaQuery.of(context).size;
    List<Widget> widgets = [
      SizedBox(height: screen.height * 0.02),
      instructionLabel('Do you need help collecting?'),
      collectOptionTile(),
      Divider(
        color: kLabelColor,
        height: 2.0,
        thickness: 2.0,
      ),
      Visibility(
        visible: context.read<Donation>().needCollected,
        child: instructionLabel(
          'Adjust percentage of produce you want to donate:',
        ),
      ),
      selectedFruits(),
    ];
    return Expanded(
      child: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screen.width * 0.1,
            ),
            child: widgets[index],
          );
        },
      ),
    );
  }

  Widget instructionLabel(String label) {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.01,
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
          horizontal: screen.width * 0.05,
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
    int axisCount = screen.width >= 600 ? 4 : 2;
    bool squeeze = screen.height <= screen.width;
    bool needCollect = context.read<Donation>().needCollected;
    return CustomGrid(
      padding: EdgeInsets.only(top: 5.0),
      assistPadding: screen.width * 0.1,
      childAspectRatio: needCollect ? (squeeze ? 3.5 : 2.5) : 1.0,
      crossAxisCount: needCollect ? 1 : axisCount,
      children: fruitTiles(),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitTiles = [];
    Produce produce = context.read<Produce>();
    Map<String, ProduceItem> produceMap = produce.map;
    Donation donation = context.watch<Donation>();
    donation.produce.forEach((produceId) {
      fruitTiles.add(removableFruitTile(
        produceItem: produceMap[produceId],
        onPressed: () {
          setState(() {
            produceMap[produceId].clear();
            donation.removeProduce(produceId);
          });
        },
      ));
    });
    return fruitTiles;
  }

  Widget removableFruitTile({
    @required ProduceItem produceItem,
    @required VoidCallback onPressed,
  }) {
    Size screen = MediaQuery.of(context).size;
    bool squeeze = screen.height <= screen.width;
    bool needCollect = context.read<Donation>().needCollected;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * (needCollect && squeeze ? 0.1 : 0.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              bottom: 5.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: kObjectColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: needCollect
                  ? adjustableFruitTile(produceItem)
                  : FruitTile(
                      fruitName: produceItem.name,
                      fruitImage: produceItem.imageURL,
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

  Widget adjustableFruitTile(ProduceItem produceItem) {
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
                fruitName: produceItem.name,
                fruitImage: produceItem.imageURL,
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
                    '${produceItem.amount}%',
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
                          produceItem.decrease();
                        });
                      },
                    ),
                    adjustButton(
                      icon: Icons.add,
                      onPressed: () {
                        setState(() {
                          produceItem.increase();
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
      hitBoxPadding: 10.0,
      onPressed: onPressed,
    );
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
          if (context.read<Donation>().produce.isNotEmpty) {
            Navigator.of(context).pushNamed(DonationContactScreen.id);
          }
        },
      ),
    );
  }
}

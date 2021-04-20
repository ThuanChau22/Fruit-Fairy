import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class DonationProduceSelectionScreen extends StatefulWidget {
  static const String id = 'donation_produce_selection_screen';

  @override
  _DonationProduceSelectionScreenState createState() =>
      _DonationProduceSelectionScreenState();
}

class _DonationProduceSelectionScreenState
    extends State<DonationProduceSelectionScreen> {
  final Color _selectedColor = Colors.grey.shade700.withOpacity(0.5);
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Produce produce = context.watch<Produce>();
    return WillPopScope(
      onWillPop: () async {
        MessageBar(context).hide();
        return true;
      },
      child: GestureWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text('Produce Selection')),
          body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: produce.map.isEmpty,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      instructionLabel(),
                      searchInputField(),
                      produceOptions(),
                    ],
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: buttonSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget instructionLabel() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: screen.height * 0.03,
        left: screen.width * 0.05,
        right: screen.width * 0.05,
      ),
      child: Text(
        'Choose produce to donate:',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kLabelColor,
          fontWeight: FontWeight.bold,
          fontSize: 25.0,
        ),
      ),
    );
  }

  Widget searchInputField() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.01,
        horizontal: screen.width * 0.05,
      ),
      child: InputField(
        label: 'Enter Produce Name',
        controller: _search,
        helperText: null,
        prefixIcon: Icon(
          Icons.search,
          color: kLabelColor,
          size: 30.0,
        ),
        onChanged: (value) {
          // Rebuild with search term
          setState(() {});
        },
      ),
    );
  }

  Widget produceOptions() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = 2;
    if (screen.width >= 600) {
      axisCount = 5;
    } else if (screen.width >= 320) {
      axisCount = 3;
    }
    double padding = screen.width * 0.03;
    List<Widget> widgets = [
      CustomGrid(
        padding: EdgeInsets.all(10.0),
        assistPadding: padding,
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
      SizedBox(height: 60 + screen.height * 0.03),
    ];
    return Expanded(
      child: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
            ),
            child: widgets[index],
          );
        },
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitTiles = [];
    Donation donation = context.watch<Donation>();
    Produce produce = context.read<Produce>();
    produce.map.forEach((produceId, produceItem) {
      if (RegExp(
        '^${_search.text.trim()}',
        caseSensitive: false,
      ).hasMatch(produceItem.name)) {
        bool selected = donation.produce.containsKey(produceId);
        fruitTiles.add(selectableFruitTile(
          produceItem: produceItem,
          selected: selected,
          onTap: () {
            setState(() {
              if (selected) {
                donation.removeProduce(produceId);
              } else {
                donation.pickProduce(produceId, produceItem);
              }
            });
          },
        ));
      }
    });
    return fruitTiles;
  }

  Widget selectableFruitTile({
    @required ProduceItem produceItem,
    @required bool selected,
    @required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        FocusScope.of(context).unfocus();
        MessageBar(context).hide();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            FruitTile(
              fruitName: produceItem.name,
              fruitImage: produceItem.imageURL,
            ),
            Container(
              decoration: BoxDecoration(
                color: selected ? _selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonSection() {
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: Container(
        color: kPrimaryColor.withOpacity(0.75),
        child: Column(
          children: [
            Divider(
              color: kLabelColor,
              height: 5.0,
              thickness: 2.0,
            ),
            basketButton(),
          ],
        ),
      ),
    );
  }

  Widget basketButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.015,
        horizontal: screen.width * 0.25,
      ),
      child: RoundedButton(
        label: 'My Basket',
        onPressed: () {
          if (context.read<Donation>().produce.isNotEmpty) {
            Navigator.of(context).pushNamed(DonationBasketScreen.id);
          } else {
            MessageBar(context, message: 'Your basket is empty!').show();
          }
        },
      ),
    );
  }
}

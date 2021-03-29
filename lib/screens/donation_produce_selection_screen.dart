import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
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

  bool _showSpinner = false;

  @override
  void dispose() {
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              inAsyncCall: _showSpinner,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
              ),
              child: Column(
                children: [
                  instructionLabel(),
                  searchInputField(),
                  fruitOptions(),
                  buttonSection(),
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
      padding: EdgeInsets.only(
        top: screen.height * 0.01,
        bottom: screen.height * 0.02,
        left: screen.width * 0.05,
        right: screen.width * 0.05,
      ),
      child: InputField(
        label: 'Enter Fruit Name',
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

  Widget fruitOptions() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = 2;
    if (screen.width >= 600) {
      axisCount = 5;
    } else if (screen.width >= 320) {
      axisCount = 3;
    }
    return Expanded(
      child: GridView.count(
        primary: false,
        padding: EdgeInsets.symmetric(
          horizontal: screen.width * 0.05,
        ),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitList = [];
    Produce produce = context.watch<Produce>();
    produce.fruits.forEach((id, fruit) {
      if (RegExp(
        '^${_search.text.trim()}',
        caseSensitive: false,
      ).hasMatch(fruit.id)) {
        Donation donation = context.watch<Donation>();
        bool selected = donation.produce.contains(fruit.id);
        fruitList.add(selectableFruitTile(
          fruit: fruit,
          selected: selected,
          onTap: () {
            setState(() {
              if (selected) {
                donation.removeFruit(fruit.id);
              } else {
                donation.pickFruit(fruit.id);
              }
            });
          },
        ));
      }
    });
    return fruitList;
  }

  Widget selectableFruitTile({
    @required Fruit fruit,
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
              fruitName: fruit.name,
              fruitImage: fruit.imageURL,
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
      child: Column(
        children: [
          divider(),
          basketButton(),
        ],
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 5.0,
      thickness: 2.0,
    );
  }

  Widget basketButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
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

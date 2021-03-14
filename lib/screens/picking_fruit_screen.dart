import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/basket.dart';
import 'package:fruitfairy/screens/donation_basket_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';

class PickingFruitScreen extends StatefulWidget {
  static const String id = 'picking_fruit_screen';

  @override
  _PickingFruitScreenState createState() => _PickingFruitScreenState();
}

class _PickingFruitScreenState extends State<PickingFruitScreen> {
  final Color _selectedColor = Colors.grey.shade700.withOpacity(0.5);
  final TextEditingController _search = TextEditingController();
  bool _showSpinner = false;

  void initBasket() async {
    setState(() => _showSpinner = true);
    Basket basket = context.read<Basket>();
    if (basket.fruits.isEmpty) {
      basket.fromDB(await context.read<FireStoreService>().fruits());
    }
    setState(() => _showSpinner = false);
  }

  @override
  void initState() {
    super.initState();
    initBasket();
  }

  @override
  void dispose() {
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return GestureWrapper(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('Donation')),
        body: SafeArea(
          child: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAppBarColor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: screen.height * 0.03,
                horizontal: screen.width * 0.05,
              ),
              child: Column(
                children: [
                  instructionLabel(),
                  searchInputField(),
                  fruitOptions(),
                  divider(),
                  basketButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget divider() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        bottom: screen.height * 0.03,
      ),
      child: Divider(
        color: kLabelColor,
        height: 5.0,
        thickness: 3.0,
      ),
    );
  }

  Widget instructionLabel() {
    return Text(
      'Choose fruit to donate:',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 30.0,
      ),
    );
  }

  Widget searchInputField() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.02,
        horizontal: screen.width * 0.05,
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
    List<Widget> fruitTiles = [];
    Basket basket = context.watch<Basket>();
    basket.fruits.forEach((id, fruit) {
      if (RegExp(
        '^${_search.text.trim()}',
        caseSensitive: false,
      ).hasMatch(fruit.id)) {
        bool selected = basket.selectedFruits.contains(fruit);
        fruitTiles.add(selectableFruitTile(
          fruitName: fruit.name,
          fruitImage: fruit.url,
          selected: selected,
          onTap: () {
            setState(() {
              if (selected) {
                basket.removeFruit(fruit);
              } else {
                basket.pickFruit(fruit);
              }
            });
          },
        ));
      }
    });
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
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        crossAxisCount: axisCount,
        children: fruitTiles,
      ),
    );
  }

  Widget selectableFruitTile({
    @required String fruitName,
    @required String fruitImage,
    @required bool selected,
    @required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        FocusScope.of(context).unfocus();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: kObjectBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            FruitTile(
              fruitName: fruitName,
              fruitImage: fruitImage,
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

  Widget basketButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.width * 0.2,
      ),
      child: RoundedButton(
        label: 'My Basket',
        onPressed: () {
          Navigator.of(context).pushNamed(DonationBasketScreen.id);
        },
      ),
    );
  }
}

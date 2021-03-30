import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/screens/charity_produce_selection_screen.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/popup_diaglog.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

class CharityWishListScreen extends StatefulWidget {
  static const String id = 'charity_wishlist_screen';

  @override
  _CharityWishListScreenState createState() => _CharityWishListScreenState();
}

class _CharityWishListScreenState extends State<CharityWishListScreen> {
  String _buttonLabel = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wish List'),
        actions: [helpButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            layoutMode(),
            divider(),
            nextButton(),
          ],
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
        //TODO: Briefly explain why we need wish list
        PopUpDialog(
          context,
          message: 'We want your data',
        ).show();
      },
    );
  }

  Widget layoutMode() {
    WishList wishList = context.watch<WishList>();
    bool isEmpty = wishList.produce.isEmpty;
    _buttonLabel = isEmpty ? 'Create' : 'Edit';
    return isEmpty ? emptyWishList() : selectedFruits();
  }

  Widget emptyWishList() {
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

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = screen.width >= 600 ? 5 : 3;
    return Expanded(
      child: GridView.count(
        primary: false,
        padding: EdgeInsets.only(
          top: screen.height * 0.03,
          left: screen.width * 0.02,
          right: screen.width * 0.02,
        ),
        crossAxisCount: axisCount,
        children: fruitTiles(),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitList = [];
    Map<String, Fruit> produce = context.read<Produce>().fruits;
    WishList wishList = context.watch<WishList>();
    wishList.produce.forEach((fruitId) {
      fruitList.add(removableFruitTile(
        fruit: produce[fruitId],
        onPressed: () {
          setState(() {
            produce[fruitId].clear();
            wishList.removeFruit(fruitId);
          });
        },
      ));
    });
    return fruitList;
  }

  Widget removableFruitTile({
    @required Fruit fruit,
    @required VoidCallback onPressed,
  }) {
    return Stack(
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
            child: FruitTile(
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

  Widget divider() {
    return Divider(
      color: kLabelColor,
      height: 5.0,
      thickness: 2.0,
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
        label: _buttonLabel,
        onPressed: () {
          Navigator.of(context).pushNamed(CharityProduceSelectionScreen.id);
        },
      ),
    );
  }
}
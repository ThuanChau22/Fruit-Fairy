import 'package:flutter/material.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/screens/charity_picking_fruit_screen.dart';
import 'package:provider/provider.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

class CharityWishListScreen extends StatefulWidget {

  static const String id = 'charity_wishlist_screen';

  @override
  _CharityWishListScreenState createState() => _CharityWishListScreenState();
}

class _CharityWishListScreenState extends State<CharityWishListScreen> {
  final Color _selectedColor = Colors.green.shade100;


  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WishList wishList = context.watch<WishList>();
    bool notEmpty = wishList.produce.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text('My Wish List')),
      body: SafeArea(
        child: notEmpty ? Column(
          children: [
            selectedFruits(),
            divider(),
            nextButton(),
         ],
        ) :
        Center(child: nextButton()),
      ),
    );
  }

  Widget basketSection() {
    Size screen = MediaQuery.of(context).size;
    List<Widget> widgets = [
      SizedBox(height: screen.height * 0.03),
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

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = screen.width >= 600 ? 5 : 3;
    return Expanded(
      child: Padding(
        padding:EdgeInsets.only(
          top: screen.height*0.03,
          left: screen.width*0.02,
          right:  screen.width*0.02,
        ),
        child: GridView.count(
          primary: false,
          crossAxisCount: axisCount,
          children: fruitTiles(),
        ),
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
    Size screen = MediaQuery.of(context).size;
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
            child:  FruitTile(
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
      thickness: 4.0,
      indent: 25.0,
      endIndent: 25.0,
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
        label: 'Create Wish List',
        onPressed: () {
          Navigator.of(context).pushNamed(CharityPickingFruitScreen.id);
        },
      ),
    );
  }
}
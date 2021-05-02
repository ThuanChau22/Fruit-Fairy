import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/screens/charity_produce_selection_screen.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
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
    Produce produce = context.watch<Produce>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Wish List'),
        actions: [helpButton()],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: produce.map.isEmpty,
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
          ),
          child: Stack(
            children: [
              layoutMode(),
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
        PopUpDialog(
          context,
          message:
              'The purpose of a wish list is to match donors to charities based on a charity\'s needs. If your needs change, you can manage your wish list accordingly.',
        ).show();
      },
    );
  }

  Widget layoutMode() {
    WishList wishList = context.watch<WishList>();
    bool isEmpty = wishList.produceIds.isEmpty;
    _buttonLabel = '${isEmpty ? 'Create' : 'Edit'} Wish List';
    return isEmpty ? emptyWishList() : selectedFruits();
  }

  Widget emptyWishList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '(Empty)',
            style: TextStyle(
              color: kLabelColor.withOpacity(0.5),
              fontSize: 20.0,
            ),
          ),
          bottomPadding(),
        ],
      ),
    );
  }

  Widget selectedFruits() {
    Size screen = MediaQuery.of(context).size;
    int axisCount = screen.width >= 600 ? 5 : 3;
    double padding = screen.width * 0.02;
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(top: screen.height * 0.03),
        child: CustomGrid(
          assistPadding: padding,
          crossAxisCount: axisCount,
          children: fruitTiles(),
        ),
      ),
      bottomPadding(),
    ];
    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding,
          ),
          child: widgets[index],
        );
      },
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitTiles = [];
    FireStoreService fireStore = context.read<FireStoreService>();
    Produce produce = context.read<Produce>();
    Map<String, ProduceItem> produceMap = produce.map;
    WishList wishList = context.read<WishList>();
    for (String produceId in wishList.produceIds) {
      if (produceMap.containsKey(produceId)) {
        fruitTiles.add(removableFruitTile(
          produceItem: produceMap[produceId],
          onPressed: () {
            setState(() {
              wishList.removeProduce(produceId);
              fireStore.updateWishList(wishList.produceIds);
            });
          },
        ));
      }
    }
    return fruitTiles;
  }

  Widget removableFruitTile({
    @required ProduceItem produceItem,
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

  Widget bottomPadding() {
    Size screen = MediaQuery.of(context).size;
    EdgeInsets view = MediaQuery.of(context).viewInsets;
    return Visibility(
      visible: view.bottom == 0.0,
      child: SizedBox(height: 60 + screen.height * 0.03),
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
            nextButton(),
          ],
        ),
      ),
    );
  }

  Widget nextButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.015,
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

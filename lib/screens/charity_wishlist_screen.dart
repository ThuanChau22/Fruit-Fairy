import 'dart:async';
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
  final ScrollController _scroll = new ScrollController();
  final double _scrollOffset = 0.75;

  Timer _loadingTimer = Timer(Duration.zero, () {});
  bool _isLoadingInit = true;
  bool _isLoadingMore = true;

  String _buttonLabel = '';

  void _initWishList() {
    FireStoreService fireStore = context.read<FireStoreService>();
    WishList wishList = context.read<WishList>();
    Produce produce = context.read<Produce>();
    _scroll.addListener(() {
      ScrollPosition pos = _scroll.position;
      bool loadTriggered = pos.pixels > _scrollOffset * pos.maxScrollExtent;
      if (loadTriggered && !_loadingTimer.isActive) {
        _loadingTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
        int currentSize = wishList.produceIds.length;
        fireStore.loadWishListProduce(wishList, produce, onData: () {
          if (mounted) {
            if (currentSize < wishList.produceIds.length) {
              _loadingTimer.cancel();
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initWishList();
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.dispose();
    _loadingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    WishList wishList = context.watch<WishList>();
    _isLoadingInit = wishList.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text('Wish List'),
        actions: [helpButton()],
      ),
      body: SafeArea(
        child: Container(
          decoration: kGradientBackground,
          child: ModalProgressHUD(
            inAsyncCall: _isLoadingInit,
            progressIndicator: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(kAccentColor),
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
          message: 'The purpose of a wish list is to'
              ' match donors to charities based on a'
              ' charity\'s needs. If your needs change,'
              ' you can manage your wish list accordingly.',
        ).show();
      },
    );
  }

  Widget layoutMode() {
    if (_isLoadingInit) return Container();
    WishList wishList = context.read<WishList>();
    bool isEmpty = wishList.produceIds.isEmpty;
    _buttonLabel = '${isEmpty ? 'Create' : 'Edit'} Wish List';
    if (isEmpty) {
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
    return selectedFruits();
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
      loadingTile(),
      bottomPadding(),
    ];
    return ListView.builder(
      controller: _scroll,
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

  Widget loadingTile() {
    WishList wishList = context.read<WishList>();
    bool underLimit = wishList.produceIds.length < Produce.LoadLimit;
    return Visibility(
      visible: !_isLoadingInit && !underLimit && _isLoadingMore,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(kAccentColor),
          ),
        ),
      ),
    );
  }

  List<Widget> fruitTiles() {
    List<Widget> fruitTiles = [];
    FireStoreService fireStore = context.read<FireStoreService>();
    Produce produce = context.watch<Produce>();
    Map<String, ProduceItem> produceMap = produce.map;
    WishList wishList = context.read<WishList>();
    List<String> produceIdList = wishList.produceIds;
    for (int i = 0; i < wishList.endCursor && i < produceIdList.length; i++) {
      String produceId = produceIdList[i];
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
              isLoading: produceItem.isLoading,
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
        color: kDarkPrimaryColor.withOpacity(0.75),
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

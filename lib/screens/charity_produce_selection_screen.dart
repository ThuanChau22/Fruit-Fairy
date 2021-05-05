import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
import 'package:fruitfairy/services/firestore_service.dart';
import 'package:fruitfairy/widgets/custom_grid.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';
import 'package:fruitfairy/widgets/gesture_wrapper.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/rounded_icon_button.dart';

class CharityProduceSelectionScreen extends StatefulWidget {
  static const String id = 'charity_produce_selection_screen';

  @override
  _CharityProduceSelectionScreenState createState() =>
      _CharityProduceSelectionScreenState();
}

class _CharityProduceSelectionScreenState
    extends State<CharityProduceSelectionScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = new ScrollController();
  final double _scrollOffset = 135.0;

  Timer _selectAllTimer = Timer(Duration.zero, () {});
  Timer _searchTimer = Timer(Duration.zero, () {});
  Timer _loadingTimer = Timer(Duration.zero, () {});
  bool _isLoadingInit = true;
  bool _isLoadingMore = true;

  void initProduce() {
    FireStoreService fireStore = context.read<FireStoreService>();
    Produce produce = context.read<Produce>();
    _scroll.addListener(() {
      ScrollPosition pos = _scroll.position;
      bool loadTriggered = pos.pixels + _scrollOffset >= pos.maxScrollExtent;
      if (loadTriggered && !_loadingTimer.isActive) {
        _loadingTimer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
        int currentSize = produce.set.length;
        fireStore.loadProduce(produce, onData: () {
          if (mounted) {
            if (currentSize < produce.set.length) {
              _loadingTimer.cancel();
            }
          }
        });
      }
    });
  }

  void searchProduce() {
    setState(() => _isLoadingMore = true);
    _searchTimer.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      FireStoreService fireStore = context.read<FireStoreService>();
      Produce produce = context.read<Produce>();
      String searchTerm = _search.text.trim();
      if (searchTerm.isNotEmpty) {
        fireStore.searchProduce(searchTerm, produce, onData: () {
          if (mounted) {
            checkWishListAvailability();
            setState(() => _isLoadingMore = false);
          }
        });
      }
    });
  }

  void checkWishListAvailability() {
    bool removed = false;
    WishList wishlist = context.read<WishList>();
    Produce produce = context.read<Produce>();
    Map<String, ProduceItem> produceStorage = produce.map;
    for (String produceId in wishlist.produceIds.toList()) {
      bool hasProduce = produceStorage.containsKey(produceId);
      if (hasProduce && !produceStorage[produceId].enabled) {
        wishlist.removeProduce(produceId);
        removed = true;
      }
    }
    FireStoreService fireStore = context.read<FireStoreService>();
    fireStore.updateWishList(wishlist.produceIds);
    String notifyMessage = 'One or more produce'
        ' on your wish list are no longer available!';
    if (removed) {
      MessageBar(context, message: notifyMessage).show();
    }
  }

  void selectAll() async {
    if (!_selectAllTimer.isActive) {
      _selectAllTimer = Timer(Duration(seconds: 2), () {});
      FireStoreService fireStore = context.read<FireStoreService>();
      WishList wishList = context.read<WishList>();
      wishList.removeAllProduce();
      if (!wishList.isAllSelected) {
        for (String produceId in await fireStore.getAllProduceId()) {
          wishList.pickProduce(produceId);
        }
        wishList.isAllSelected = true;
      } else {
        wishList.isAllSelected = false;
      }
      await fireStore.updateWishList(wishList.produceIds);
      _selectAllTimer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    initProduce();
  }

  @override
  void dispose() {
    super.dispose();
    _search.dispose();
    _scroll.dispose();
    _selectAllTimer.cancel();
    _searchTimer.cancel();
    _loadingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Produce produce = context.watch<Produce>();
    _isLoadingInit = produce.map.isEmpty;
    return GestureWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Produce Selection'),
          actions: [selectAllButton()],
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

  Widget selectAllButton() {
    WishList wishList = context.watch<WishList>();
    return RoundedIconButton(
      radius: 30.0,
      icon: Icon(
        wishList.isAllSelected ? Icons.close : Icons.done_all,
        color: kLabelColor,
        size: 30.0,
      ),
      hitBoxPadding: 5.0,
      buttonColor: Colors.transparent,
      onPressed: () {
        selectAll();
      },
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
        'Add produce to wish list',
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
      child: Stack(
        children: [
          InputField(
            label: 'Enter Produce Name',
            controller: _search,
            helperText: null,
            prefixIcon: Icon(
              Icons.search,
              color: kLabelColor,
              size: 30.0,
            ),
            suffixWidget: SizedBox(width: 20.0),
            onChanged: (value) {
              searchProduce();
            },
          ),
          Positioned(
            top: 9.0,
            right: 10.0,
            child: Visibility(
              visible: _search.text.isNotEmpty,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _search.clear());
                },
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: kLabelColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
      loadingTile(),
      bottomPadding(),
    ];
    return Expanded(
      child: ListView.builder(
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
      ),
    );
  }

  Widget loadingTile() {
    Produce produce = context.read<Produce>();
    bool underLimit = produce.set.length < Produce.LoadLimit;
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
    Produce produce = context.read<Produce>();
    List<ProduceItem> produceList = produce.map.values.toList();
    produceList.sort();
    for (ProduceItem produceItem in produceList) {
      bool loaded = produce.set.contains(produceItem.id);
      String searchTerm = _search.text.trim();
      if (searchTerm.isEmpty && loaded) {
        fruitTiles.add(selectableFruitTile(produceItem));
      }
      if (searchTerm.isNotEmpty) {
        bool searched = produce.searches.contains(produceItem.id);
        bool searchMatch = RegExp(
          '^$searchTerm',
          caseSensitive: false,
        ).hasMatch(produceItem.name);
        if (searchMatch && (searched || loaded)) {
          fruitTiles.add(selectableFruitTile(produceItem));
        }
      }
    }
    return fruitTiles;
  }

  Widget selectableFruitTile(ProduceItem produceItem) {
    FireStoreService fireStore = context.read<FireStoreService>();
    WishList wishList = context.read<WishList>();
    bool selected = wishList.produceIds.contains(produceItem.id);
    return GestureDetector(
      onTap: () {
        if (!_selectAllTimer.isActive) {
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus();
          setState(() {
            if (selected) {
              wishList.removeProduce(produceItem.id);
            } else {
              wishList.pickProduce(produceItem.id);
            }
            fireStore.updateWishList(wishList.produceIds);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? kAccentColor : kObjectColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: FruitTile(
          fruitName: produceItem.name,
          fruitImage: produceItem.imageURL,
          isLoading: produceItem.isLoading,
        ),
      ),
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
            backButton(),
          ],
        ),
      ),
    );
  }

  Widget backButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.015,
        horizontal: screen.width * 0.25,
      ),
      child: RoundedButton(
        label: 'Back to Wish List',
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

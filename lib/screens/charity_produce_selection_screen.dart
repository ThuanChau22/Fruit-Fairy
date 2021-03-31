import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/models/produce.dart';
import 'package:fruitfairy/models/wish_list.dart';
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
          appBar: AppBar(
            title: Text('Produce Selection'),
            actions: [actionButton()],
          ),
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

  Widget actionButton() {
    Produce produce = context.read<Produce>();
    WishList wishList = context.read<WishList>();
    bool isAllSelected = produce.fruits.length == wishList.produce.length;
    return RoundedIconButton(
      radius: 30.0,
      icon: Icon(
        !isAllSelected ? Icons.fact_check : Icons.close,
        color: kLabelColor,
        size: 30.0,
      ),
      hitBoxPadding: 5.0,
      buttonColor: Colors.transparent,
      onPressed: () {
        setState(() {
          wishList.clear();
          if (!isAllSelected) {
            produce.fruits.forEach((fruitId, fruit) {
              wishList.pickFruit(fruitId);
            });
          }
        });
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
        'Add produce to wish list:',
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
        WishList wishList = context.read<WishList>();
        bool selected = wishList.produce.contains(fruit.id);
        fruitList.add(selectableFruitTile(
          fruit: fruit,
          selected: selected,
          onTap: () {
            setState(() {
              if (selected) {
                wishList.removeFruit(fruit.id);
              } else {
                wishList.pickFruit(fruit.id);
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
          backButton(),
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

  Widget backButton() {
    Size screen = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screen.height * 0.03,
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

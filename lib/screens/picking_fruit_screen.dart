import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/rounded_button.dart';
import 'package:fruitfairy/widgets/fruit_tile.dart';

class PickingFruitScreen extends StatefulWidget {
  static const String id = 'picking_fruit_screen';

  @override
  _PickingFruitScreenState createState() => _PickingFruitScreenState();
}

class _PickingFruitScreenState extends State<PickingFruitScreen> {
  List<bool> selectedFruits = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < kFruitImages.length; i++) {
      selectedFruits.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text('Donation Page'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: screen.height * 0.02),
              Text(
                'Choose fruit to donate:',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
              ),
              SizedBox(height: screen.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screen.height * 0.05),
                child: TextField(
                    onChanged: (value) {},
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: kTextFieldInputDecoration),
              ),
              SizedBox(height: screen.height * 0.02),
              Expanded(
                //Already scrollable
                child: GridView.count(
                  primary: false,
                  padding: EdgeInsets.all(10),
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  crossAxisCount: 3,
                  children: [
                    for (int i = 0; i < kFruitImages.length; i++)
                      FruitTile(
                        fruitImage: kFruitImages[i],
                        index: i,
                        selected: selectedFruits[i],
                        onTap: (index) {
                          setState(() {
                            selectedFruits[index] = !selectedFruits[index];
                          });
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: screen.height * 0.02),
              divider(),
              SizedBox(height: screen.height * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.15,
                ),
                child: RoundedButton(
                  label: 'Go To Cart',
                  labelColor: kPrimaryColor,
                  backgroundColor: kObjectBackgroundColor,
                  onPressed: () {},
                ),
              ),
              SizedBox(height: screen.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

Widget divider() {
  return Divider(
    color: kLabelColor,
    thickness: 3.0,
    indent: 20.0,
    endIndent: 20.0,
  );
}
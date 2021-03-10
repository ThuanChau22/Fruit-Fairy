import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

class FruitQuantity extends StatefulWidget {
  static const String id = 'temp_fruit_with_quantity';

  @override
  _FruitQuantityState createState() => _FruitQuantityState();
}

class _FruitQuantityState extends State<FruitQuantity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: fruitLayoutWithQuantity(),
        ),
      ),
    );
  }

  Widget fruitLayoutWithQuantity() {
    Size screen = MediaQuery.of(context).size;
    return Container(
      width: 350.0,
      height: 200.0,
      color: kPrimaryColor,
      child: Row(
        children: [
          SizedBox(
            width: screen.width * 0.05,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: screen.width * 0.2),
              Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('images/Peach.png'),
                  ),
                ),
              ),
              Text(
                'Peach',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(width: screen.width * 0.1),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3.0),
                ),
                child: Text(
                  'Number' + ' %',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
              SizedBox(height: screen.height * 0.03),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.add_circle,
                      size: 35.0,
                    ),
                  ),
                  SizedBox(width: screen.width * 0.075),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.remove_circle,
                      size: 35.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

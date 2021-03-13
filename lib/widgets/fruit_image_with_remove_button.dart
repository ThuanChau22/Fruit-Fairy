import 'package:flutter/material.dart';

import 'package:fruitfairy/widgets/remove_fruit_button.dart';

import '../constant.dart';

class FruitImageWithRemove extends StatelessWidget {
  final AssetImage fruitImage;
  final Text fruitName;
  final Function removeFunction;

  FruitImageWithRemove({
    this.fruitName,
    this.fruitImage,
    this.removeFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 10.0,
            right: 10.0,
          ),
          child: Container(
            decoration: BoxDecoration(
                color: kObjectBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(20),
                ),
              ),
            child: Column(
              children: [
                fruitName,
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: fruitImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: Container(
            color: Colors.transparent,
            child: kRemoveButton(
              onPressed: removeFunction,
            ),
          ),
        ),
      ],
    );
  }
}

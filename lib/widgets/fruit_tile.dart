import 'package:flutter/material.dart';

class FruitTile extends StatelessWidget {
  final AssetImage fruitImage;
  final bool selected;
  final int index;
  final void Function(int index) onTap;
  final Text fruitName;

  FruitTile({
    this.fruitImage,
    this.selected = false,
    this.index,
    this.onTap,
    this.fruitName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
          Container(
            color: Colors.grey.shade700.withOpacity(selected ? 0.5 : 0),
          ),
        ],
      ),
    );
  }
}

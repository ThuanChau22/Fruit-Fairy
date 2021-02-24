import 'package:flutter/material.dart';

class FruitTile extends StatelessWidget {
  final Widget fruitImage;
  final bool selected;
  final int index;
  final void Function(int index) onTap;

  FruitTile({
    this.fruitImage,
    this.selected = false,
    this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: () {
            onTap(index);
          },
        child: Stack(
          children: [
            fruitImage,
            Container(
              color: Colors.green.shade500.withOpacity(selected ? 0.5 : 0),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fruitfairy/constant.dart';

class FruitTile extends StatelessWidget {
  final String fruitName;
  final String fruitImage;

  FruitTile({
    @required this.fruitName,
    @required this.fruitImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        label(fruitName),
        Expanded(
          child: CachedNetworkImage(
              imageUrl: fruitImage,
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
              placeholder: (context, url) {
                return Center(
                  child: label('loading...'),
                );
              }),
        ),
      ],
    );
  }

  Widget label(String label) {
    return Text(
      camelize(label),
      style: TextStyle(
        color: kPrimaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),
    );
  }
}

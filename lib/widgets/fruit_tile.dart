import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:fruitfairy/constant.dart';

class FruitTile extends StatelessWidget {
  final String fruitName;
  final String fruitImage;
  final String donatedPercentage;

  FruitTile({
    @required this.fruitName,
    @required this.fruitImage,
    this.donatedPercentage = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          camelize(fruitName),
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        Expanded(
          child: CachedNetworkImage(
            imageUrl: fruitImage,
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            placeholder: (context, url) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(kAppBarColor),
                  strokeWidth: 1.5,
                ),
              );
            },
          ),
        ),
        Visibility(
          visible: donatedPercentage.isNotEmpty,
          child: Text(
            '$donatedPercentage%',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }
}

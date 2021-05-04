import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
//
import 'package:fruitfairy/constant.dart';

class FruitTile extends StatelessWidget {
  final String fruitName;
  final String fruitImage;
  final bool isLoading;
  final String percentage;

  FruitTile({
    @required this.fruitName,
    @required this.fruitImage,
    @required this.isLoading,
    this.percentage = '',
  });

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screen.width * 0.005,
          ),
          child: Text(
            camelize(fruitName),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kDarkPrimaryColor),
                    strokeWidth: 1.5,
                  ),
                )
              : fruitImage.isNotEmpty
                  ? CachedNetworkImage(
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
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(kDarkPrimaryColor),
                            strokeWidth: 1.5,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Image Not Found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
        ),
        Visibility(
          visible: percentage.isNotEmpty,
          child: Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

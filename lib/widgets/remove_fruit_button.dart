import 'package:flutter/material.dart';

import 'package:fruitfairy/constant.dart';

Widget kRemoveButton({Function onPressed}) {
  //declare a onpressed function for remove button
  return Material(
    color: Colors.transparent,
    child: Center(
      child: Ink(
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: kAppBarColor,
        ),
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: IconButton(
            padding: EdgeInsets.all(0.0),
            splashRadius: 10.0,
            icon: Icon(
              Icons.close,
              color: kLabelColor,
              size: 16.0,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    ),
  );
}

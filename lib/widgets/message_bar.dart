import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

class MessageBar {
  final BuildContext scaffoldContext;
  final String message;

  MessageBar(
    this.scaffoldContext, {
    this.message,
  });

  void show() {
    hide();
    Scaffold.of(scaffoldContext).showSnackBar(
      SnackBar(
        backgroundColor: kAppBarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        duration: Duration(seconds: 5),
        content: Text(
          message,
          style: TextStyle(
            color: kLabelColor,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: kLabelColor,
          onPressed: () {
            hide();
          },
        ),
      ),
    );
  }

  void hide() {
    Scaffold.of(scaffoldContext).hideCurrentSnackBar();
  }
}

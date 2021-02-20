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
        duration: Duration(seconds: 5),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kLabelColor,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void hide() {
    Scaffold.of(scaffoldContext).hideCurrentSnackBar();
  }
}

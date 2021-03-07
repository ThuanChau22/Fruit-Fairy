import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fruitfairy/constant.dart';

class MessageBar {
  final BuildContext context;
  final String message;

  MessageBar(
    this.context, {
    this.message,
  });

  void show() {
    hide();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kAppBarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        duration: Duration(seconds: 5),
        content: Text(
          message,
          textAlign: TextAlign.center,
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
            HapticFeedback.mediumImpact();
            hide();
          },
        ),
      ),
    );
  }

  void hide() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

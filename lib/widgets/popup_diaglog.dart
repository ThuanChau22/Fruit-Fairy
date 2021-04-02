import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
//
import 'package:fruitfairy/constant.dart';

class PopUpDialog {
  final BuildContext context;
  final String message;

  PopUpDialog(
    this.context, {
    this.message,
  });

  show() {
    Alert(
      context: context,
      title: '',
      style: AlertStyle(
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: kObjectColor,
        titleStyle: TextStyle(fontSize: 0.0),
        overlayColor: Colors.black.withOpacity(0.25),
        isCloseButton: false,
      ),
      content: Text(
        message,
        style: TextStyle(
          color: kPrimaryColor,
          fontSize: 20.0,
          decoration: TextDecoration.none,
        ),
      ),
      buttons: [],
    ).show();
  }
}

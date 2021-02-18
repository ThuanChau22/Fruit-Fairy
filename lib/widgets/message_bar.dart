import 'package:flutter/material.dart';

class MessageBar {
  final String message;
  final BuildContext scaffoldContext;

  MessageBar({
    @required this.scaffoldContext,
    @required this.message,
  });

  void show() {
    Scaffold.of(scaffoldContext).showSnackBar(
      SnackBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.25),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

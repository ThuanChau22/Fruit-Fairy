import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        duration: Duration(seconds: 5),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        action: SnackBarAction(
          label: 'Dismiss',
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

import 'package:flutter/material.dart';

class GestureWrapper extends StatelessWidget {
  final Widget child;

  GestureWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () {
        // Dismiss on screen keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
    );
  }
}

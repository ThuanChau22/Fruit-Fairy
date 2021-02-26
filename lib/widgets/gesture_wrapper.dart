import 'package:flutter/material.dart';

class GestureWapper extends StatelessWidget {
  final Widget child;

  GestureWapper({this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss on screen keyboard
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: child,
    );
  }
}

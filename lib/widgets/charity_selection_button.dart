import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';

class CharityButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Widget leading;
  final VoidCallback onPressed;

  CharityButton({
    @required this.label,
    @required this.onPressed,
    this.backgroundColor,
    @required this.leading,
    Color labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      color: backgroundColor ?? kObjectBackgroundColor,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        height: 48.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus();
          onPressed();
        },
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

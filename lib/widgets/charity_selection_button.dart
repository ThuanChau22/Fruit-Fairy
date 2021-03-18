import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';

class CharityButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget leading;

  CharityButton({
    @required this.label,
    @required this.onPressed,
    this.backgroundColor,
    Color labelColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
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
        //TODO: make the circle with number appear only after clicking on a charity button
        child: Row(
          children: [
            leading,
            SizedBox(
              width: screen.width * 0.15,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

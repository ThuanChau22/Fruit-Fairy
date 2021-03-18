import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruitfairy/constant.dart';

class CharityButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final String number;

  CharityButton({
    @required this.label,
    @required this.onPressed,
    this.backgroundColor,
    this.number,
    Color labelColor,
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
        child: Row(
          children: [
            circleWithNumber(),
            SizedBox(width: screen.width * 0.15,),
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

  Widget circleWithNumber() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        border: Border.all(
          color: kPrimaryColor,
          width: 3,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 30,
          ),
        ),
      ),
    );
  }


}

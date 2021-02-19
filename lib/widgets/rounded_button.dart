import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Function onPressed;

  RoundedButton({
    this.label,
    this.labelColor,
    this.backgroundColor,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 50.0,
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

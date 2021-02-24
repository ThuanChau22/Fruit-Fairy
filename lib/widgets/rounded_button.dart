import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color backgroundColor;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onPressed;

  RoundedButton({
    @required this.label,
    @required this.onPressed,
    this.labelColor,
    this.backgroundColor,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            leading ?? SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing ?? SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

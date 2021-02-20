import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final bool labelCenter;
  final Color labelColor;
  final Color backgroundColor;
  final Widget leading;
  final Function onPressed;

  RoundedButton({
    @required this.label,
    @required this.onPressed,
    this.labelCenter = true,
    this.labelColor,
    this.backgroundColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        elevation: 5.0,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          child: ListTile(
            leading: leading,
            title: Text(
              label,
              textAlign: labelCenter ? TextAlign.center : null,
              style: TextStyle(
                color: labelColor,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

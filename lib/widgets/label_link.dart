import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

class LabelLink extends StatelessWidget {
  final String label;
  final GestureTapCallback onTap;

  LabelLink({
    @required this.label,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: kLabelColor,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

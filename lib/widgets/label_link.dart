import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
        FocusScope.of(context).unfocus();
      },
      child: Text(
        label,
        style: TextStyle(
          color: kLabelColor,
          fontSize: 18,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

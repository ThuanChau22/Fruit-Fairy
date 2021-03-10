import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fruitfairy/constant.dart';

class ObscureIcon extends StatelessWidget {
  final bool obscure;
  final GestureTapCallback onTap;
  ObscureIcon({
    @required this.obscure,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        obscure ? Icons.visibility_off : Icons.visibility,
        color: kLabelColor,
      ),
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
    );
  }
}

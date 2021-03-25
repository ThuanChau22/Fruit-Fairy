import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
import 'package:fruitfairy/constant.dart';

class RoundedIconButton extends StatefulWidget {
  final double radius;
  final Icon icon;
  final Color buttonColor;
  final double hitBoxPadding;
  final VoidCallback onPressed;

  RoundedIconButton({
    @required this.radius,
    @required this.icon,
    @required this.onPressed,
    this.buttonColor = kObjectColor,
    this.hitBoxPadding = 0.0,
  });

  @override
  _RoundedIconButtonState createState() => _RoundedIconButtonState();
}

class _RoundedIconButtonState extends State<RoundedIconButton> {
  Timer timer;

  @override
  Widget build(BuildContext context) {
    Color shadowColor = widget.buttonColor == Colors.transparent
        ? Colors.transparent
        : Colors.black;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
      onTapDown: (details) {
        timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
          HapticFeedback.mediumImpact();
          widget.onPressed();
        });
      },
      onTapUp: (details) {
        timer.cancel();
      },
      onTapCancel: () {
        timer.cancel();
      },
      child: Padding(
        padding: EdgeInsets.all(widget.hitBoxPadding),
        child: Material(
          shadowColor: shadowColor,
          shape: CircleBorder(),
          color: widget.buttonColor,
          elevation: 2.0,
          child: SizedBox(
            width: widget.radius,
            height: widget.radius,
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

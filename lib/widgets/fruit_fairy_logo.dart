import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text.dart';

class FruitFairyLogo extends StatelessWidget {
  static const String id = 'fruit_fairy_logo';

  final double fontSize;
  final double radius;

  FruitFairyLogo({
    @required this.fontSize,
    @required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: fontSize * 1.5,
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CircularText(
            children: [
              TextItem(
                text: Text(
                  'Fruit Fairy',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                ),
                space: 10,
                startAngle: 270,
                startAngleAlignment: StartAngleAlignment.center,
                direction: CircularTextDirection.clockwise,
              ),
            ],
            radius: radius * 1.1,
            position: CircularTextPosition.outside,
            backgroundPaint: Paint()..color = Colors.transparent,
          ),
          CircleAvatar(
            radius: radius,
            backgroundImage: AssetImage('images/Logo-Dark.png'),
            backgroundColor: Colors.green.shade100,
          ),
        ],
      ),
    );
  }
}

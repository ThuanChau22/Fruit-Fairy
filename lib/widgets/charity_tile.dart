import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//
import 'package:fruitfairy/constant.dart';

class CharityTile extends StatelessWidget {
  final String charityName;
  final String selectedOrder;
  final VoidCallback onTap;

  CharityTile({
    @required this.charityName,
    @required this.selectedOrder,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: 80.0,
        ),
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: selectedIcon(),
            ),
            Expanded(
              flex: 10,
              child: Text(
                charityName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectedIcon() {
    return Visibility(
      visible: selectedOrder.isNotEmpty,
      child: Container(
        height: 35.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: kPrimaryColor,
            width: 3.0,
          ),
        ),
        child: Center(
          child: Text(
            selectedOrder,
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 25.0,
            ),
          ),
        ),
      ),
    );
  }
}

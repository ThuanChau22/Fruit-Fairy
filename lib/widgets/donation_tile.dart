import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/status.dart';

class DonationTile extends StatelessWidget {
  final String charityName;
  final DateTime dateTime;
  final Status status;
  final VoidCallback onTap;

  DonationTile({
    @required this.charityName,
    @required this.dateTime,
    @required this.status,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status.isPennding) {
      statusColor = kPendingStatus;
    }
    if (status.isInProgress) {
      statusColor = kInProgressStatus;
    }
    if (status.isDenied) {
      statusColor = kDeniedStatus;
    }
    if (status.isCompleted) {
      statusColor = kCompletedStatus;
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: kObjectColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                charityName,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().add_Hm().format(dateTime),
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  Text(
                    status.description,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

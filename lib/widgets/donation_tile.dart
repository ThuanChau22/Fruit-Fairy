import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:strings/strings.dart';
import 'package:intl/intl.dart';
//
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/models/status.dart';

class DonationTile extends StatelessWidget {
  final Status status;
  final DateTime dateTime;
  final String userName;
  final bool needCollected;
  final VoidCallback onTap;

  DonationTile({
    @required this.status,
    @required this.dateTime,
    @required this.userName,
    @required this.onTap,
    this.needCollected = false,
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
    if (status.isDeclined) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      camelize(userName),
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: status.isCharity && needCollected,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Assist',
                        style: TextStyle(
                          color: kCompletedStatus,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ],
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

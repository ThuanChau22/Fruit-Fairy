import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/input_field.dart';
import 'package:fruitfairy/widgets/message_bar.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ConfirmCodeDialog {
  final BuildContext scaffoldContext;
  final void Function(String confirmCode) onSubmit;
  ConfirmCodeDialog({
    @required this.scaffoldContext,
    @required this.onSubmit,
  });

  TextEditingController confirmCodeController = TextEditingController();

  void show() {
    Alert(
      context: scaffoldContext,
      title: 'Confirmation Code',
      closeIcon: Icon(
        Icons.close,
        color: kLabelColor,
      ),
      style: AlertStyle(
        titleStyle: TextStyle(
          color: kLabelColor,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: kPrimaryColor,
        overlayColor: Colors.black.withOpacity(0.5),
        isOverlayTapDismiss: false,
      ),
      content: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: InputField(
          label: 'Code',
          controller: confirmCodeController,
          onTap: () {
            MessageBar(scaffoldContext).hide();
          },
        ),
      ),
      buttons: [
        DialogButton(
          color: kObjectBackgroundColor,
          radius: BorderRadius.circular(30.0),
          width: 150.0,
          height: 50.0,
          child: Text(
            'Confirm',
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            onSubmit(confirmCodeController.text.trim());
          },
        ),
      ],
    ).show();
  }
}

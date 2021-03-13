import 'package:flutter/material.dart';

import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/message_bar.dart';

class InputField extends StatelessWidget {
  final String label;
  final Color labelColor;
  final TextEditingController controller;
  final String errorMessage;
  final String helperText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final String prefixText;
  final Icon prefixIcon;
  final ValueChanged<String> onChanged;

  InputField({
    @required this.controller,
    this.label,
    this.labelColor = kLabelColor,
    this.errorMessage = '',
    this.helperText = '',
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.prefixText,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: labelColor,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: () => MessageBar(context).hide(),
      style: TextStyle(color: labelColor),
      decoration: kTextFieldDecoration.copyWith(
        labelText: label,
        errorText: errorMessage.isNotEmpty ? errorMessage : null,
        helperText: helperText,
        prefixText: prefixText,
        prefixIcon: prefixIcon,
        fillColor: kObjectBackgroundColor.withOpacity(0.2),
        enabled: !readOnly,
      ),
    );
  }
}

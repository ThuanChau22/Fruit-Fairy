import 'package:flutter/material.dart';

import 'package:fruitfairy/utils/constant.dart';

class InputField extends StatelessWidget {
  final String label;
  final Color labelColor;
  final TextEditingController controller;
  final String errorMessage;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLength;
  final String helperText;
  final String prefixText;
  final ValueChanged<String> onChanged;
  final GestureTapCallback onTap;

  InputField({
    this.label,
    this.labelColor = kLabelColor,
    this.controller,
    this.errorMessage = '',
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLength,
    this.helperText = '',
    this.prefixText,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      cursorColor: labelColor,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(color: labelColor),
      decoration: kTextFieldDecoration.copyWith(
        labelText: label,
        errorText: errorMessage.isNotEmpty ? errorMessage : null,
        helperText: helperText,
        prefixText: prefixText,
        fillColor: kObjectBackgroundColor.withOpacity(0.2),
        enabled: !readOnly,
      ),
    );
  }
}

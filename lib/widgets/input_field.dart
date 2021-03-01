import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

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
      decoration: inputDecoration(),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: kLabelColor,
        fontSize: 18.0,
      ),
      errorText: errorMessage.isNotEmpty ? errorMessage : null,
      errorStyle: TextStyle(
        color: kErrorColor,
        fontSize: 16.0,
      ),
      errorMaxLines: 1,
      helperText: helperText,
      helperStyle: TextStyle(
        color: kLabelColor,
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        color: kLabelColor,
        fontSize: 16.0,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      filled: true,
      fillColor: kObjectBackgroundColor.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      enabled: !readOnly,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kLabelColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kLabelColor, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kErrorColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kErrorColor, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kErrorColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
    );
  }
}

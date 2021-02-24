import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

class InputField extends StatelessWidget {
  final String label;
  final String errorMessage;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final GestureTapCallback onTap;
  final TextEditingController controller;
  final bool readOnly;

  InputField({
    @required this.label,
    this.errorMessage = '',
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      cursorColor: kLabelColor,
      keyboardType: keyboardType,
      obscureText: obscureText,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(
        color: kLabelColor,
      ),
      decoration: InputDecoration(
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
        helperText: '',
        helperStyle: TextStyle(
          color: kLabelColor,
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
      ),
    );
  }
}

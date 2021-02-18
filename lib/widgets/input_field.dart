import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';

class InputField extends StatelessWidget {
  final String label;
  final String value;
  final String errorMessage;
  final int characterCount;
  final TextInputType keyboardType;
  final bool obscureText;
  final Function onChanged;

  InputField({
    @required this.label,
    @required this.value,
    @required this.onChanged,
    this.characterCount = 0,
    this.errorMessage = '',
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kLabelColor),
        errorText: errorMessage.isNotEmpty ? errorMessage : null,
        errorStyle: TextStyle(color: kErrorColor),
        counterText: characterCount > 0 ? '$characterCount' : null,
        helperText: '',
        errorMaxLines: 2,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
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
      onChanged: onChanged,
    );
  }
}

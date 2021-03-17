import 'package:flutter/material.dart';

/// Color Theme
const Color kDarkPrimaryColor = Color.fromRGBO(128, 0, 0, 1.0);
const Color kPrimaryColor = Color.fromRGBO(240, 94, 92, 1.0);
const Color kLabelColor = Colors.white;
const Color kObjectColor = Colors.white;
const Color kErrorColor = Colors.white;

// Widget Style
const kTextFieldDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: kLabelColor,
    fontSize: 18.0,
  ),
  errorStyle: TextStyle(
    color: kErrorColor,
    fontSize: 16.0,
  ),
  errorMaxLines: 1,
  helperStyle: TextStyle(
    color: kLabelColor,
  ),
  prefixStyle: TextStyle(
    color: kLabelColor,
    fontSize: 16.0,
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  filled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kLabelColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  disabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kLabelColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kErrorColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kLabelColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kErrorColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);

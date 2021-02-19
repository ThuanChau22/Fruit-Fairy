import 'package:flutter/material.dart';

/// Color Theme
const kAppBarColor = Color.fromRGBO(128, 0, 0, 1.0);
const kBackroundColor = Color.fromRGBO(240, 94, 92, 1.0);
const kLabelColor = Colors.white;
const kErrorColor = Colors.white;

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

/// Database fields
const kUserDB = 'users';
const kEmailField = 'email';
const kFirstNameField = 'firstname';
const kLastNameField = 'lastname';
const kPhoneField = 'phone';

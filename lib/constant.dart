import 'package:flutter/material.dart';

/// Color Theme
const Color kAppBarColor = Color.fromRGBO(128, 0, 0, 1.0);
const Color kPrimaryColor = Color.fromRGBO(240, 94, 92, 1.0);
const Color kLabelColor = Colors.white;
const Color kErrorColor = Colors.white;
const Color kObjectBackgroundColor = Colors.white;

/// Database fields
const String kDBUserCollection = 'users';
const String kDBEmailField = 'email';
const String kDBFirstNameField = 'firstname';
const String kDBLastNameField = 'lastname';
const String kDBPhoneField = 'phone';

const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  prefixIcon: Icon(
    Icons.search,
    color: kPrimaryColor,
    size: 30.0,
  ),
  hintText: 'Enter Fruit Name',
  hintStyle: TextStyle(
    color: kPrimaryColor,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);

Widget kDivider() {
  return Divider(
    color: kLabelColor,
    thickness: 3.0,
    indent: 20.0,
    endIndent: 20.0,
  );
}



List<String> kFruitImages = [
  'images/Peach.png',
  'images/Avocado.png',
  'images/Lemon.png',
  'images/Orange.png',
  'images/Peach.png',
  'images/Avocado.png',
  'images/Lemon.png',
  'images/Orange.png',
  'images/Peach.png',
  'images/Avocado.png',
  'images/Lemon.png',
  'images/Orange.png',
  'images/Peach.png',
  'images/Avocado.png',
  'images/Lemon.png',
  'images/Orange.png',
];
List<String> kFruitNames = [
  'Peach',
  'Avocado',
  'Lemon',
  'Orange',
  'Peach',
  'Avocado',
  'Lemon',
  'Orange',
  'Peach',
  'Avocado',
  'Lemon',
  'Orange',
  'Peach',
  'Avocado',
  'Lemon',
  'Orange',
];

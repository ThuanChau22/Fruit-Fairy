import 'package:flutter/material.dart';

/// Color Theme
const Color kAppBarColor = Color.fromRGBO(128, 0, 0, 1.0);
const Color kPrimaryColor = Color.fromRGBO(240, 94, 92, 1.0);
const Color kLabelColor = Colors.white;
const Color kErrorColor = Colors.white;
const Color kObjectBackgroundColor = Colors.white;

/// Database fields
const String kDBUsers = 'users';
const String kDBEmail = 'email';
const String kDBFirstName = 'firstname';
const String kDBLastName = 'lastname';
const String kDBPhone = 'phone';
const String kDBPhoneNumber = 'number';
const String kDBPhoneCountry = 'country';
const String kDBAddress = 'address';
const String kDBAddressStreet = 'street';
const String kDBAddressCity = 'city';
const String kDBAddressState = 'state';
const String kDBAddressZip = 'zip';

// Widget Style
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

List<Widget> kFruitImages = [
  Image.asset('images/Orange.jpg'),
  Image.asset('images/Apple.jpg'),
  Image.asset('images/Avocado.jpg'),
  Image.asset('images/Lemon.jpg'),
  Image.asset('images/Peach.jpg'),
  Image.asset('images/Orange.jpg'),
  Image.asset('images/Apple.jpg'),
  Image.asset('images/Avocado.jpg'),
  Image.asset('images/Lemon.jpg'),
  Image.asset('images/Peach.jpg'),
  Image.asset('images/Orange.jpg'),
  Image.asset('images/Apple.jpg'),
  Image.asset('images/Avocado.jpg'),
  Image.asset('images/Lemon.jpg'),
  Image.asset('images/Peach.jpg'),
];

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:fruitfairy/constant.dart';

class Account extends ChangeNotifier {
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  Map<String, String> _phone = {};
  Map<String, String> _address = {};

  Account();

  String get email {
    return _email;
  }

  String get firstName {
    return _firstName;
  }

  String get lastName {
    return _lastName;
  }

  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  void setEmail(String email) {
    this._email = email;
    notifyListeners();
  }

  void setFirstName(String firstName) {
    this._firstName = firstName;
    notifyListeners();
  }

  void setLastName(String lastName) {
    this._lastName = lastName;
    notifyListeners();
  }

  void setPhoneNumber({String country, String dialCode, String phoneNumber}) {
    if (phoneNumber.isEmpty) {
      this._phone = {};
    } else {
      this._phone[kDBPhoneCountry] = country;
      this._phone[kDBPhoneDialCode] = dialCode;
      this._phone[kDBPhoneNumber] = phoneNumber;
    }
    notifyListeners();
  }

  void setAddress({String street, String city, String state, String zip}) {
    if (street.isEmpty && city.isEmpty && state.isEmpty && zip.isEmpty) {
      this._address = {};
    } else {
      this._address[kDBAddressStreet] = street;
      this._address[kDBAddressCity] = city;
      this._address[kDBAddressState] = state;
      this._address[kDBAddressZip] = zip;
    }

    notifyListeners();
  }

  void fromMap(Map<String, dynamic> accountData) {
    this._email = accountData[kDBEmail];
    this._firstName = accountData[kDBFirstName];
    this._lastName = accountData[kDBLastName];
    Map<String, dynamic> phone = accountData[kDBPhone];
    if (phone != null) {
      this._phone[kDBPhoneCountry] = phone[kDBPhoneCountry];
      this._phone[kDBPhoneDialCode] = phone[kDBPhoneDialCode];
      this._phone[kDBPhoneNumber] = phone[kDBPhoneNumber];
    }
    Map<String, dynamic> address = accountData[kDBAddress];
    if (address != null) {
      this._address[kDBAddressStreet] = address[kDBAddressStreet];
      this._address[kDBAddressCity] = address[kDBAddressCity];
      this._address[kDBAddressState] = address[kDBAddressState];
      this._address[kDBAddressZip] = address[kDBAddressZip];
    }
    notifyListeners();
  }

  void clear() {
    this._email = '';
    this._firstName = '';
    this._lastName = '';
    this._phone = {};
    this._address = {};
    notifyListeners();
  }
}

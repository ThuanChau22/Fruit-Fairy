import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:fruitfairy/services/firestore_service.dart';

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

  void setFirstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
  }

  void setLastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
  }

  void setPhoneNumber({
    @required String phoneNumber,
    String country,
    String dialCode,
  }) {
    if (phoneNumber.isEmpty) {
      _phone = {};
    } else {
      _phone[FireStoreService.kPhoneCountry] = country;
      _phone[FireStoreService.kPhoneDialCode] = dialCode;
      _phone[FireStoreService.kPhoneNumber] = phoneNumber;
    }
    notifyListeners();
  }

  void setAddress({
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
  }) {
    if (street.isEmpty && city.isEmpty && state.isEmpty && zip.isEmpty) {
      _address = {};
    } else {
      _address[FireStoreService.kAddressStreet] = street;
      _address[FireStoreService.kAddressCity] = city;
      _address[FireStoreService.kAddressState] = state;
      _address[FireStoreService.kAddressZip] = zip;
    }
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> accountData) {
    _email = accountData[FireStoreService.kEmail];
    _firstName = accountData[FireStoreService.kFirstName];
    _lastName = accountData[FireStoreService.kLastName];
    Map<String, dynamic> phone = accountData[FireStoreService.kPhone];
    if (phone != null) {
      _phone[FireStoreService.kPhoneCountry] =
          phone[FireStoreService.kPhoneCountry];
      _phone[FireStoreService.kPhoneDialCode] =
          phone[FireStoreService.kPhoneDialCode];
      _phone[FireStoreService.kPhoneNumber] =
          phone[FireStoreService.kPhoneNumber];
    }
    Map<String, dynamic> address = accountData[FireStoreService.kAddress];
    if (address != null) {
      _address[FireStoreService.kAddressStreet] =
          address[FireStoreService.kAddressStreet];
      _address[FireStoreService.kAddressCity] =
          address[FireStoreService.kAddressCity];
      _address[FireStoreService.kAddressState] =
          address[FireStoreService.kAddressState];
      _address[FireStoreService.kAddressZip] =
          address[FireStoreService.kAddressZip];
    }
    notifyListeners();
  }

  void clear() {
    _email = '';
    _firstName = '';
    _lastName = '';
    _phone = {};
    _address = {};
    notifyListeners();
  }
}

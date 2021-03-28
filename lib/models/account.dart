import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

class Account extends ChangeNotifier {
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _ein = '';
  String _charityName = '';
  final Map<String, String> _phone = {};
  final Map<String, String> _address = {};

  String get email {
    return _email;
  }

  String get firstName {
    return _firstName;
  }

  String get lastName {
    return _lastName;
  }

  String get ein {
    return _ein;
  }

  String get charityName {
    return _charityName;
  }

  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  void fromDB(Map<String, dynamic> accountData) {
    clear();
    _email = accountData[FireStoreService.kEmail];
    String firstName = accountData[FireStoreService.kFirstName];
    String lastName = accountData[FireStoreService.kLastName];
    if (firstName != null && lastName != null) {
      _firstName = firstName;
      _lastName = lastName;
    }
    String ein = accountData[FireStoreService.kEIN];
    String charityName = accountData[FireStoreService.kCharityName];
    if (ein != null && charityName != null) {
      _ein = ein;
      _charityName = charityName;
    }
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
    _ein = '';
    _charityName = '';
    _phone.clear();
    _address.clear();
  }
}

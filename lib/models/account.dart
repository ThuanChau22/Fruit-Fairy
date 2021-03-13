import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:fruitfairy/services/firestore_service.dart';

class Account extends ChangeNotifier {
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  Map<String, String> _phone = {};
  Map<String, String> _address = {};

  Account({Map<String, dynamic> data}) {
    if (data != null) {
      fromDB(data);
    }
  }

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

  void fromDB(Map<String, dynamic> accountData) {
    clear();
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

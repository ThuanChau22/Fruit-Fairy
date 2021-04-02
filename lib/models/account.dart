import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a user in the system
/// This class is used for both donor and charity user
/// where donor will have non-empty [_firstName] and [_lastName]
/// and charity will have non-empty [_ein] and [_charityName]
class Account extends ChangeNotifier {
  /// Set default values for all fields
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _ein = '';
  String _charityName = '';
  final Map<String, String> _phone = {};
  final Map<String, String> _address = {};

  /// Return a copy of [_email]
  String get email {
    return _email;
  }

  /// Return a copy of [_firstName]
  String get firstName {
    return _firstName;
  }

  /// Return a copy of [_lastName]
  String get lastName {
    return _lastName;
  }

  /// Return a copy of [_ein]
  String get ein {
    return _ein;
  }

  /// Return a copy of [_charityName]
  String get charityName {
    return _charityName;
  }

  /// Return a copy of [_phone]
  /// A Map with keys that are declared in [FireStoreService]
  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  /// Return a copy of [_address]
  /// A Map with keys that are declared in [FireStoreService]
  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  /// Parse account information from database
  /// [accountData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> accountData) {
    // Clean up current data
    clear();

    // Email
    _email = accountData[FireStoreService.kEmail];

    // First and Last name (Donor only)
    String firstName = accountData[FireStoreService.kFirstName];
    String lastName = accountData[FireStoreService.kLastName];
    if (firstName != null && lastName != null) {
      _firstName = firstName;
      _lastName = lastName;
    }

    // EIN and charity name (Charity only)
    String ein = accountData[FireStoreService.kEIN];
    String charityName = accountData[FireStoreService.kCharityName];
    if (ein != null && charityName != null) {
      _ein = ein;
      _charityName = charityName;
    }

    // Phone number
    Map<String, dynamic> phone = accountData[FireStoreService.kPhone];
    if (phone != null) {
      _phone[FireStoreService.kPhoneCountry] =
          phone[FireStoreService.kPhoneCountry];
      _phone[FireStoreService.kPhoneDialCode] =
          phone[FireStoreService.kPhoneDialCode];
      _phone[FireStoreService.kPhoneNumber] =
          phone[FireStoreService.kPhoneNumber];
    }

    // Address
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

  /// Set all fields to default values
  void clear() {
    _email = '';
    _firstName = '';
    _lastName = '';
    _ein = '';
    _charityName = '';
    _phone.clear();
    _address.clear();
    notifyListeners();
  }
}

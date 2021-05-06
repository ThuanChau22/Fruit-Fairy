import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a user in the system
/// This class is used for both donor and charity user
/// where donor will have non-empty [_firstName] and [_lastName]
/// and charity will have non-empty [_ein] and [_charityName]
/// [_email]: user's email
/// [_firstName]: donor's first name
/// [_lastName]: donor's last name
/// [_ein]: charity's EIN
/// [_charityName]: charity name
/// [_phone]: user's phone number
/// [_address]: user's address
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
class Account extends ChangeNotifier {
  /// Set default values for all fields
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _ein = '';
  String _charityName = '';
  final Map<String, String> _phone = {};
  final Map<String, String> _address = {};
  final List<StreamSubscription> _subscriptions = [];

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

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel last subscription from [_subscriptions]
  void cancelLastSubscription() {
    _subscriptions.last.cancel();
    _subscriptions.removeAt(_subscriptions.length - 1);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Parse account information from database
  /// [userData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> userData) {
    // Reset current data
    reset();

    // Email
    _email = userData[FireStoreService.kEmail];

    // First and Last name (Donor only)
    String firstName = userData[FireStoreService.kFirstName];
    String lastName = userData[FireStoreService.kLastName];
    if (firstName != null && lastName != null) {
      _firstName = firstName;
      _lastName = lastName;
    }

    // EIN and charity name (Charity only)
    String ein = userData[FireStoreService.kEIN];
    String charityName = userData[FireStoreService.kCharityName];
    if (ein != null && charityName != null) {
      _ein = ein;
      _charityName = charityName;
    }

    // Address
    Map<String, dynamic> address = userData[FireStoreService.kAddress];
    if (address != null) {
      address.forEach((key, value) {
        _address[key] = value;
      });
    }

    // Phone number
    Map<String, dynamic> phone = userData[FireStoreService.kPhone];
    if (phone != null) {
      phone.forEach((key, value) {
        _phone[key] = value;
      });
    }
    notifyListeners();
  }

  /// Set all fields to default values
  void reset() {
    _email = '';
    _firstName = '';
    _lastName = '';
    _ein = '';
    _charityName = '';
    _phone.clear();
    _address.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    reset();
    notifyListeners();
  }
}

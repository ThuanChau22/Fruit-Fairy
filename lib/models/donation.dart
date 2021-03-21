import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

class Donation extends ChangeNotifier {
  final List<String> _selectedFruits = [];
  final List<String> _selectedCharities = [];
  final Map<String, String> _address = {};
  final Map<String, String> _phone = {};
  bool _needCollected = true;

  bool get needCollected {
    return _needCollected;
  }

  UnmodifiableListView<String> get selectedFruits {
    return UnmodifiableListView(_selectedFruits);
  }

  UnmodifiableListView<String> get selectedCharities {
    return UnmodifiableListView(_selectedCharities);
  }

  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  void pickFruit(String fruitId) {
    _selectedFruits.add(fruitId);
    notifyListeners();
  }

  void removeFruit(String fruitId) {
    _selectedFruits.remove(fruitId);
    notifyListeners();
  }

  void setCollectOption(bool option) {
    _needCollected = option;
  }

  void setAddress({
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
  }) {
    _address[FireStoreService.kAddressStreet] = street;
    _address[FireStoreService.kAddressCity] = city;
    _address[FireStoreService.kAddressState] = state;
    _address[FireStoreService.kAddressZip] = zip;
  }

  void setPhoneNumber({
    @required String country,
    @required String dialCode,
    @required String phoneNumber,
  }) {
    if (phoneNumber.isEmpty) {
      _phone.clear();
    } else {
      _phone[FireStoreService.kPhoneCountry] = country;
      _phone[FireStoreService.kPhoneDialCode] = dialCode;
      _phone[FireStoreService.kPhoneNumber] = phoneNumber;
    }
  }

  void clear() {
    _needCollected = true;
    _selectedFruits.clear();
    _selectedCharities.clear();
    _address.clear();
    _phone.clear();
  }
}

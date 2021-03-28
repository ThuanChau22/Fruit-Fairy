import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

class Donation extends ChangeNotifier {
  final List<String> _produce = [];
  final List<String> _charities = [];
  final Map<String, String> _address = {};
  final Map<String, String> _phone = {};
  bool _needCollected = true;
  VoidCallback _onEmptyBasket;

  bool get needCollected {
    return _needCollected;
  }

  UnmodifiableListView<String> get produce {
    return UnmodifiableListView(_produce);
  }

  UnmodifiableListView<String> get charities {
    return UnmodifiableListView(_charities);
  }

  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  void onEmptyBasket(VoidCallback action) {
    _onEmptyBasket = () {
      if (_produce.isEmpty) action();
    };
    addListener(_onEmptyBasket);
  }

  void setNeedCollected(bool option) {
    _needCollected = option;
  }

  void pickFruit(String fruitId) {
    _produce.add(fruitId);
    notifyListeners();
  }

  void removeFruit(String fruitId) {
    _produce.remove(fruitId);
    notifyListeners();
  }

  void setContactInfo({
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
    @required String country,
    @required String dialCode,
    @required String phoneNumber,
  }) {
    _address[FireStoreService.kAddressStreet] = street;
    _address[FireStoreService.kAddressCity] = city;
    _address[FireStoreService.kAddressState] = state;
    _address[FireStoreService.kAddressZip] = zip;
    _phone[FireStoreService.kPhoneCountry] = country;
    _phone[FireStoreService.kPhoneDialCode] = dialCode;
    _phone[FireStoreService.kPhoneNumber] = phoneNumber;
  }

  void setCharities(List<String> charities) {
    notifyListeners();
  }

  void reset() {
    _needCollected = true;
    _produce.clear();
    _charities.clear();
    _address.clear();
    _phone.clear();
  }

  void clear() {
    reset();
    removeListener(_onEmptyBasket);
  }
}

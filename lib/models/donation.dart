import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/status.dart';
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a dontation
/// [_id]: donation id
/// [_needCollected]: specify whether
/// the donor need help collecting
/// [_produce]: selected produce
/// [_address]: donor's address
/// [_phone]: donor's phone number
/// [_charities]: selected charities
/// [_updated]: object state's update status
/// [_onEmptyBasket]: a callback that handles when [_produce] is empty
/// [status]: donation status
/// [createdAt]: donation created timestamp
/// [donorId]: donor unique id
/// [donorName]: donor name
/// [MaxCharity]: maximum number of charity can be selected
class Donation extends ChangeNotifier implements Comparable<Donation> {
  static const int MaxCharity = 3;
  final String id;
  final Map<String, ProduceItem> _produce = SplayTreeMap();
  final Map<String, String> _address = {};
  final Map<String, String> _phone = {};
  final List<Charity> _charities = [];
  bool _needCollected = true;
  bool _updated = false;
  VoidCallback _onEmptyBasket = () {};
  Status status = Status.init();
  DateTime createdAt = DateTime.now();
  String donorId = '';
  String donorName = '';

  Donation(this.id);

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get produce {
    return UnmodifiableMapView(_produce);
  }

  /// Return a copy of [_address]
  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  /// Return a copy of [_phone]
  UnmodifiableMapView<String, String> get phone {
    return UnmodifiableMapView(_phone);
  }

  /// Return a copy of [_charities]
  UnmodifiableListView<Charity> get charities {
    return UnmodifiableListView(_charities);
  }

  /// Return a copy of [_needCollected]
  bool get needCollected {
    return _needCollected;
  }

  /// Return [_updated] status
  bool get isUpdated {
    return _updated;
  }

  /// Set collecting option
  set needCollected(bool option) {
    _needCollected = option;
    notifyListeners();
  }

  /// Add [produceItem] to map [_produce]
  /// access through [produceItem.id]
  void pickProduce(ProduceItem produceItem) {
    _produce[produceItem.id] = produceItem;
    _updated = true;
    notifyListeners();
  }

  /// Remove [ProduceItem] from map [_produce]
  /// through [produceId]
  void removeProduce(String produceId) {
    _produce.remove(produceId);
    _updated = true;
    notifyListeners();
  }

  /// Set donor contact info
  void setContactInfo({
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
    @required String country,
    @required String dialCode,
    @required String phoneNumber,
  }) {
    bool changed = false;
    Map<String, String> newAddress = {
      FireStoreService.kAddressStreet: street,
      FireStoreService.kAddressCity: city,
      FireStoreService.kAddressState: state,
      FireStoreService.kAddressZip: zip,
    };
    for (String key in newAddress.keys) {
      if (_address[key] != newAddress[key]) {
        changed = true;
      }
    }
    Map<String, String> newPhone = {
      FireStoreService.kPhoneCountry: country,
      FireStoreService.kPhoneDialCode: dialCode,
      FireStoreService.kPhoneNumber: phoneNumber,
    };
    for (String key in newPhone.keys) {
      if (_phone[key] != newPhone[key]) {
        changed = true;
      }
    }
    if (changed) {
      newAddress.forEach((key, value) {
        _address[key] = value;
      });
      newPhone.forEach((key, value) {
        _phone[key] = value;
      });
      _updated = true;
    }
    notifyListeners();
  }

  /// Add [charity] to list
  void pickCharity(Charity charity) {
    if (_charities.length < MaxCharity) {
      _charities.add(charity);
    }
    notifyListeners();
  }

  /// Remove [charity] from list
  void removeCharity(Charity charity) {
    _charities.remove(charity);
    notifyListeners();
  }

  /// Listen to callback when [_produce] is empty
  void onEmptyBasket(VoidCallback action) {
    _onEmptyBasket = () {
      if (_produce.isEmpty) action();
    };
    addListener(_onEmptyBasket);
  }

  /// Reset update status and clear [_charities]
  void clearUpdated() {
    _updated = false;
    _charities.clear();
  }

  /// Set all fields to default values
  void reset() {
    _produce.clear();
    _charities.clear();
    _address.clear();
    _phone.clear();
    _needCollected = true;
    _updated = false;
    status = Status.init();
    createdAt = DateTime.now();
    donorId = '';
    donorName = '';
  }

  /// Set object to initial state
  void clear() {
    reset();
    removeListener(_onEmptyBasket);
    notifyListeners();
  }

  @override
  int compareTo(Donation other) {
    int result = this.status.compareTo(other.status);
    return result == 0 ? other.createdAt.compareTo(this.createdAt) : result;
  }
}

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
/// [_donorName]: donor name
/// [_address]: donor's address
/// [_phone]: donor's phone number
/// [_charities]: selected charities
/// [_status]: donation status
/// [_createdAt]: donation created timestamp
/// [_updated]: object state's update status
/// [_onEmptyBasket]: a callback that handles when [_produce] is empty
/// [MaxCharity]: maximum number of charity can be selected
class Donation extends ChangeNotifier implements Comparable<Donation> {
  static const int MaxCharity = 3;
  final String id;
  bool _needCollected = true;
  final Map<String, ProduceItem> _produce = {};
  String _donorName = '';
  String _charityName = '';
  final Map<String, String> _address = {};
  final Map<String, String> _phone = {};
  final List<Charity> _charities = [];
  Status _status = Status(Status.init());
  Timestamp _createdAt = Timestamp.now();
  bool _updated = false;
  VoidCallback _onEmptyBasket = () {};

  Donation(this.id);

  /// Return a copy of [_needCollected]
  bool get needCollected {
    return _needCollected;
  }

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get produce {
    return UnmodifiableMapView(_produce);
  }

  /// Return a copy of [_donorName]
  String get donorName {
    return _donorName;
  }

  /// Return a copy of [_charityName]
  String get charityName {
    return _charityName;
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

  /// Return a copy of [_status]
  Status get status {
    return _status;
  }

  /// Return a copy of [_createdAt]
  Timestamp get createdAt {
    return _createdAt;
  }

  /// Return [_updated] status
  bool get isUpdated {
    return _updated;
  }

  /// Set collecting option
  void setNeedCollected(bool option) {
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
    _produce[produceId].clear();
    _produce.remove(produceId);
    _updated = true;
    notifyListeners();
  }

  /// Set donor contact info
  void setContactInfo({
    @required String donorName,
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
    @required String country,
    @required String dialCode,
    @required String phoneNumber,
  }) {
    String oldStreet = _address[FireStoreService.kAddressStreet];
    String oldCity = _address[FireStoreService.kAddressCity];
    String oldState = _address[FireStoreService.kAddressState];
    String oldZip = _address[FireStoreService.kAddressZip];
    String oldCountry = _phone[FireStoreService.kPhoneCountry];
    String oldDialCode = _phone[FireStoreService.kPhoneDialCode];
    String oldPhoneNumber = _phone[FireStoreService.kPhoneNumber];
    if (oldStreet != street ||
        oldCity != city ||
        oldState != state ||
        oldZip != zip ||
        oldCountry != country ||
        oldDialCode != dialCode ||
        oldPhoneNumber != phoneNumber) {
      _donorName = donorName;
      _address[FireStoreService.kAddressStreet] = street;
      _address[FireStoreService.kAddressCity] = city;
      _address[FireStoreService.kAddressState] = state;
      _address[FireStoreService.kAddressZip] = zip;
      _phone[FireStoreService.kPhoneCountry] = country;
      _phone[FireStoreService.kPhoneDialCode] = dialCode;
      _phone[FireStoreService.kPhoneNumber] = phoneNumber;
      _updated = true;
    }
    notifyListeners();
  }

  /// Set charity name
  void setCharityName(String charityName) {
    _charityName = charityName;
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

  /// Set current status
  void setStatus(Status status) {
    _status = status;
  }

  /// Set created timestamp
  void setCreatedAt(Timestamp createdAt) {
    _createdAt = createdAt ?? Timestamp.now();
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
    _needCollected = true;
    _updated = false;
    _produce.clear();
    _charities.clear();
    _address.clear();
    _phone.clear();
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

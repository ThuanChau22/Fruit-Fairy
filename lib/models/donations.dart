import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/donation.dart';

/// A class holds a list of donations of the current user
/// [_startDocument]: A cursor used to traverse DB
/// [_endDocument]: A cursor used to traverse DB
/// [_donations]: a map of [Donation]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
/// [LOAD_LIMIT]: Limit amount per donation retrieval
class Donations extends ChangeNotifier {
  static const LOAD_LIMIT = 5;
  final Map<String, Donation> _donations = {};
  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];
  DocumentSnapshot _startDocument;
  DocumentSnapshot _endDocument;

  /// Return a copy of [_donations]
  UnmodifiableMapView<String, Donation> get map {
    return UnmodifiableMapView(_donations);
  }

  /// Return a copy of [_startDocument]
  DocumentSnapshot get startDocument {
    return _startDocument;
  }

  /// Return a copy of [_endDocument]
  DocumentSnapshot get endDocument {
    return _endDocument;
  }

  /// Add [donation] to map [_donations]
  /// access through [donation.id]
  void pickDonation(Donation donation) {
    _donations[donation.id] = donation;
    notifyListeners();
  }

  /// Remove [Donation] from map [_donations]
  /// through [donationId]
  void removeDonation(String donationId) {
    _donations.remove(donationId);
    notifyListeners();
  }

  /// Set [doc] as starting cursor
  void setStartDocument(DocumentSnapshot doc) {
    _startDocument = doc;
  }

  /// Set [doc] as ending cursor
  void setEndDocument(DocumentSnapshot doc) {
    _endDocument = doc;
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription<QuerySnapshot> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
    _subscriptions.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _donations.clear();
    _startDocument = null;
    _endDocument = null;
    notifyListeners();
  }
}

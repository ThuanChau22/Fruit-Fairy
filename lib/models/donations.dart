import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/donation.dart';

/// A class holds a list of donations of the current user
/// [_donations]: a map of [Donation]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
/// [startDocument]: A cursor used to traverse DB
/// [endDocument]: A cursor used to traverse DB
/// [LoadLimit]: Limit amount per donation retrieval
class Donations extends ChangeNotifier {
  static const LoadLimit = 20;
  final Map<String, Donation> _donations = {};
  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];
  DocumentSnapshot startDocument;
  DocumentSnapshot endDocument;

  /// Return a copy of [_donations]
  UnmodifiableMapView<String, Donation> get map {
    return UnmodifiableMapView(_donations);
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

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription<QuerySnapshot> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    for (StreamSubscription<QuerySnapshot> subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _donations.clear();
    startDocument = null;
    endDocument = null;
    notifyListeners();
  }
}

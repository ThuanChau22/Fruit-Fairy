import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/donation.dart';

/// A class holds a list of all possible produce that a user can select
/// [_donations]: a map of [Donation]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
class Donations extends ChangeNotifier {
  final Map<String, Donation> _donations = {};
  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];
  DocumentSnapshot _startDocument;
  DocumentSnapshot _endDocument;

  /// Return a copy of [_donations]
  UnmodifiableMapView<String, Donation> get map {
    return UnmodifiableMapView(_donations);
  }

  DocumentSnapshot get startDocument {
    return _startDocument;
  }

  DocumentSnapshot get endDocument {
    return _endDocument;
  }

  void addDonation(Donation donation) {
    _donations[donation.id] = donation;
  }

  void removeDonation(String donationId) {
    _donations.remove(donationId);
  }

  void setStartDocument(DocumentSnapshot doc) {
    _startDocument = doc;
  }

  void setEndDocument(DocumentSnapshot doc) {
    _endDocument = doc;
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription<QuerySnapshot> subscription) {
    _subscriptions.add(subscription);
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
    _subscriptions.clear();
    _donations.clear();
    notifyListeners();
  }
}

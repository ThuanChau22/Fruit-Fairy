import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that represents a charity's wishlist
/// [_produce]: list of produce ids selected by the charity
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
class WishList extends ChangeNotifier {
  final PriorityQueue<String> _produceIds = PriorityQueue();
  final List<StreamSubscription<DocumentSnapshot>> _subscriptions = [];

  /// Return a copy of [_produceIds] sorted in alphabetical order
  UnmodifiableListView<String> get produceIds {
    return UnmodifiableListView(_produceIds.toList());
  }

  /// Add [produceId] to list
  void pickProduce(String produceId) {
    _produceIds.add(produceId);
    notifyListeners();
  }

  /// Remove [produceId] from list
  void removeProduce(String produceId) {
    _produceIds.remove(produceId);
    notifyListeners();
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription<DocumentSnapshot> subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    for (StreamSubscription<DocumentSnapshot> subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Parse [produceId] from database
  void fromDB(List<dynamic> wishlist) {
    _produceIds.clear();
    if (wishlist != null) {
      for (dynamic produceId in wishlist) {
        _produceIds.add(produceId);
      }
    }
    notifyListeners();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _produceIds.clear();
    notifyListeners();
  }
}

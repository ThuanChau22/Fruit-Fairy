import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/produce_item.dart';

/// A class holds a list of produce that a user can select
/// [_produceIds]: a set of produce ids
/// [_searchIds]: a set of produce ids from search result
/// [_produce]: a map of [ProduceItem]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
/// [startDocument]: A cursor used to traverse DB
/// [endDocument]: A cursor used to traverse DB
/// [LoadLimit]: Limit amount per donation retrieval
class Produce extends ChangeNotifier {
  static const LoadLimit = 20;
  final Set<String> _produceIds = {};
  final Set<String> _searchIds = {};
  final Map<String, ProduceItem> _produce = {};
  final List<StreamSubscription> _subscriptions = [];
  DocumentSnapshot startDocument;
  DocumentSnapshot endDocument;

  /// Return a copy of [_produceIds]
  UnmodifiableSetView<String> get set {
    return UnmodifiableSetView(_produceIds);
  }

  /// Return a copy of [_searchIds]
  UnmodifiableSetView<String> get searches {
    return UnmodifiableSetView(_searchIds);
  }

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get map {
    return UnmodifiableMapView(_produce);
  }

  /// Add [produceId] to [_produceIds]
  void pickProduce(String produceId) {
    _produceIds.add(produceId);
    notifyListeners();
  }

  /// Remove [produceId] from [_produceIds]
  void removeProduce(String produceId) {
    _produceIds.remove(produceId);
    notifyListeners();
  }

  /// Add [produceId] to [_searchIds]
  void pickSearchProduce(String produceId) {
    _searchIds.add(produceId);
    notifyListeners();
  }

  /// Remove [produceId] from [_searchIds]
  void removeSearchProduce(String produceId) {
    _searchIds.remove(produceId);
    notifyListeners();
  }

  /// Add [ProduceItem] to [_produce]
  void storeProduce(ProduceItem produceItem) {
    _produce[produceItem.id] = produceItem;
    notifyListeners();
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _produceIds.clear();
    _searchIds.clear();
    _produce.clear();
    startDocument = null;
    endDocument = null;
    notifyListeners();
  }
}

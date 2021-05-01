import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/produce_item.dart';

/// A class holds a list of produce that a user can select
/// [_produceIds]: a set of produce ids
/// [_produce]: a map of [ProduceItem]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
/// [_startDocument]: A cursor used to traverse DB
/// [_endDocument]: A cursor used to traverse DB
/// [LOAD_LIMIT]: Limit amount per donation retrieval
class Produce extends ChangeNotifier {
  static const LOAD_LIMIT = 20;
  final Set<String> _produceIds = {};
  final Map<String, ProduceItem> _produce = {};
  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];
  DocumentSnapshot _startDocument;
  DocumentSnapshot _endDocument;

  /// Return a copy of [_produceIds]
  UnmodifiableSetView<String> get set {
    return UnmodifiableSetView(_produceIds);
  }

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get map {
    return UnmodifiableMapView(_produce);
  }

  /// Return a copy of [_startDocument]
  DocumentSnapshot get startDocument {
    return _startDocument;
  }

  /// Return a copy of [_endDocument]
  DocumentSnapshot get endDocument {
    return _endDocument;
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

  /// Add [ProduceItem] to [_produce]
  void storeProduce(ProduceItem produceItem) {
    _produce[produceItem.id] = produceItem;
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
    for (StreamSubscription<QuerySnapshot> subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _produceIds.clear();
    _produce.clear();
    _startDocument = null;
    _endDocument = null;
    notifyListeners();
  }
}

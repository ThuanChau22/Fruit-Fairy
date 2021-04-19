import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//
import 'package:fruitfairy/models/produce_item.dart';

/// A class holds a list of all possible produce that a user can select
/// [_produce]: a map of [ProduceItem] that can be access through [ProduceItem.id]
/// [_subscriptions]: list of stream subcriptions that
/// performs an opperation for each subcription on changes
class Produce extends ChangeNotifier {
  final Map<String, ProduceItem> _produce = SplayTreeMap();
  final List<StreamSubscription<QuerySnapshot>> _subscriptions = [];

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get map {
    return UnmodifiableMapView(_produce);
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription<QuerySnapshot> subscription) {
    _subscriptions.add(subscription);
  }

  /// Parse [produceData] as [Map] from database
  void fromDB(Map<String, ProduceItem> produceData) {
    _produce.clear();
    produceData.forEach((produceId, produceItem) {
      _produce[produceId] = produceItem;
    });
    notifyListeners();
  }

  /// Set [_produce] to default value
  void clear() {
    _subscriptions.forEach((subscription) {
      subscription.cancel();
    });
    _subscriptions.clear();
    _produce.clear();
    notifyListeners();
  }
}

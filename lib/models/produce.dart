import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/produce_item.dart';

/// A class holds a list of all possible produce that a user can select
/// [_produce]: a map of [ProduceItem] that can be access through [ProduceItem.id]
class Produce extends ChangeNotifier {
  final Map<String, ProduceItem> _produce = SplayTreeMap();

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get map {
    return UnmodifiableMapView(_produce);
  }

  /// Parse [produceData] as [Map] from database
  void fromDB(Map<String, ProduceItem> produceData) {
    clear();
    produceData.forEach((produceId, produceItem) {
      _produce[produceId] = produceItem;
    });
    notifyListeners();
  }

  /// Set [_produce] to default value
  void clear() {
    _produce.clear();
    notifyListeners();
  }
}

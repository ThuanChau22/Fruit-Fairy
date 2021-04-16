import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/produce_item.dart';

/// A class holds a list of all possible produce that a user can select
/// [_produce]: a map of [ProduceItem] that can be access through [produce.id]
class Produce extends ChangeNotifier {
  final Map<String, ProduceItem> _produce = SplayTreeMap();

  /// Return a copy of [_produce]
  UnmodifiableMapView<String, ProduceItem> get map {
    return UnmodifiableMapView(_produce);
  }

  /// Parse [produceData] as [ProduceItem] from database
  /// This is call every time a [ProduceItem] is retrieved
  void fromDBLoading(ProduceItem produceData) {
    _produce[produceData.id] = produceData;
    notifyListeners();
  }

  /// Parse [produceData] as [Map] from database
  /// This is call after all [ProduceItem] are retrieved
  /// This method ensures data is retrieved correctly
  void fromDBComplete(Map<String, ProduceItem> produceData) {
    if (produceData.length != _produce.length) {
      clear();
      produceData.forEach((produceId, produce) {
        _produce[produceId] = produce;
      });
    }
    notifyListeners();
  }

  /// Set [_produce] to default value
  void clear() {
    _produce.clear();
    notifyListeners();
  }
}

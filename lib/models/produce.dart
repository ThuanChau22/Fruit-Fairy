import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/fruit.dart';

/// A class holds a list of all possible produce that a user can select
/// [_fruits]: a map of [Fruit] that can be access through [fruit.id]
class Produce extends ChangeNotifier {
  final Map<String, Fruit> _fruits = SplayTreeMap();

  /// Return a copy of [_fruits]
  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  /// Parse [produceData] as [Fruit] from database
  /// This is call every time a [Fruit] is retrieved
  void fromDBLoading(Fruit produceData) {
    _fruits[produceData.id] = produceData;
    notifyListeners();
  }

  /// Parse [produceData] as [Map] from database
  /// This is call after all [Fruit] are retrieved
  /// This method ensures data is retrieved correctly
  void fromDBComplete(Map<String, Fruit> produceData) {
    if (produceData.length != _fruits.length) {
      clear();
      produceData.forEach((id, fruit) {
        _fruits[id] = fruit;
      });
    }
    notifyListeners();
  }

  /// Set [_fruits] to default value
  void clear() {
    _fruits.clear();
    notifyListeners();
  }
}

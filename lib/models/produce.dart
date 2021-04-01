import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/fruit.dart';

class Produce extends ChangeNotifier {
  final Map<String, Fruit> _fruits = {};

  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  void fromDBLoading(Fruit produceData) {
    _fruits[produceData.id] = produceData;
    notifyListeners();
  }

  void fromDBComplete(Map<String, Fruit> produceData) {
    if (produceData.length != _fruits.length) {
      clear();
      produceData.forEach((id, fruit) {
        _fruits[id] = fruit;
      });
    }
    notifyListeners();
  }

  void clear() {
    _fruits.clear();
    notifyListeners();
  }
}

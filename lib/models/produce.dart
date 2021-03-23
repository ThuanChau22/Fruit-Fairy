import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/fruit.dart';

class Produce extends ChangeNotifier {
  final Map<String, Fruit> _fruits = {};

  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  void fromDB(Map<String, Fruit> fruitsData) {
    _fruits.clear();
    fruitsData.forEach((id, fruit) {
      _fruits[id] = fruit;
    });
    notifyListeners();
  }

  void clear() {
    _fruits.clear();
    notifyListeners();
  }
}

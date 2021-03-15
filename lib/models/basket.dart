import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'package:fruitfairy/models/fruit.dart';

class Basket extends ChangeNotifier {
  final Map<String, Fruit> _fruits = {};
  final List<String> _selectedFruits = [];

  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  UnmodifiableListView<String> get selectedFruits {
    return UnmodifiableListView(_selectedFruits);
  }

  void pickFruit(String fruitId) {
    _selectedFruits.add(fruitId);
    notifyListeners();
  }

  void removeFruit(String fruitId) {
    _fruits[fruitId].clear();
    _selectedFruits.remove(fruitId);
    notifyListeners();
  }

  void fromDB(Map<String, Fruit> fruitsData) {
    _fruits.clear();
    fruitsData.forEach((id, fruit) {
      _fruits[id] = fruit;
    });
    for (String fruitId in List.from(selectedFruits)) {
      if (!fruitsData.containsKey(fruitId)) {
        removeFruit(fruitId);
      }
    }
    notifyListeners();
  }

  void clear() {
    _fruits.clear();
    _selectedFruits.clear();
    notifyListeners();
  }
}

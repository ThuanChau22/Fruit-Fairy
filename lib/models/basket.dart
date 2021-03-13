import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/services/firestore_service.dart';

class Basket extends ChangeNotifier {
  final Map<String, Fruit> _fruits = {};
  final List<Fruit> _selectedFruits = [];

  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  UnmodifiableListView<Fruit> get selectedFruits {
    return UnmodifiableListView(_selectedFruits);
  }

  void pickFruit(Fruit fruit) {
    _selectedFruits.add(fruit);
    notifyListeners();
  }

  void removeFruit(Fruit fruit) {
    _selectedFruits.remove(fruit);
    notifyListeners();
  }

  void fromDB(List<QueryDocumentSnapshot> fruitList) {
    for (QueryDocumentSnapshot snapshot in fruitList) {
      String id = snapshot.id;
      Map<String, dynamic> data = snapshot.data();
      _fruits[id] = Fruit(
        id: id,
        name: data[FireStoreService.kFruitName],
        path: data[FireStoreService.kFruitPath],
        url: data[FireStoreService.kFruitURL],
      );
    }
  }

  void clear() {
    _fruits.clear();
    _selectedFruits.clear();
  }
}

import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/fruit.dart';
import 'package:fruitfairy/services/firestore_service.dart';

class Produce extends ChangeNotifier {
  final Map<String, Fruit> _fruits = {};

  UnmodifiableMapView<String, Fruit> get fruits {
    return UnmodifiableMapView(_fruits);
  }

  void fromDB(Map<String, dynamic> produceData) {
    _fruits.clear();
    produceData.forEach((id, fruit) {
      _fruits[id] = Fruit(
        id: id,
        name: fruit[FireStoreService.kFruitName],
        imagePath: fruit[FireStoreService.kFruitPath],
        imageURL: fruit[FireStoreService.kFruitURL],
      );
    });
    notifyListeners();
  }

  void clear() {
    _fruits.clear();
    notifyListeners();
  }
}

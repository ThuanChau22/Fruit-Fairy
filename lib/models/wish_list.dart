import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

class WishList extends ChangeNotifier {
  final List<String> _produce = [];

  UnmodifiableListView<String> get produce {
    _produce.sort();
    return UnmodifiableListView(_produce);
  }

  void pickFruit(String fruitId) {
    _produce.add(fruitId);
    notifyListeners();
  }

  void removeFruit(String fruitId) {
    _produce.remove(fruitId);
    notifyListeners();
  }

  void fromDB(Map<String, dynamic> wishlistData) {
    _produce.clear();
    wishlistData[FireStoreService.kProduceIds].forEach((fruitId) {
      _produce.add(fruitId);
    });
    notifyListeners();
  }

  void clear() {
    _produce.clear();
    notifyListeners();
  }
}

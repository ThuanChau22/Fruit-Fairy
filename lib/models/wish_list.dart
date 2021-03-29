import 'dart:collection';
import 'package:flutter/foundation.dart';

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

  void clear() {
    _produce.clear();
    notifyListeners();
  }
}

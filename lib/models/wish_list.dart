import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a charity's wishlist
/// [_produce]: list of produce ids selected by the charity
class WishList extends ChangeNotifier {
  final List<String> _produce = [];

  /// Return a copy of [_produce] sorted in alphabetical order
  UnmodifiableListView<String> get produce {
    _produce.sort();
    return UnmodifiableListView(_produce);
  }

  /// Add [fruitId] to list
  void pickFruit(String fruitId) {
    _produce.add(fruitId);
    notifyListeners();
  }

  /// Remove [fruitId] from list
  void removeFruit(String fruitId) {
    _produce.remove(fruitId);
    notifyListeners();
  }

  /// Parse [fruitId] from database
  /// [wishlistData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> wishlistData) {
    _produce.clear();
    if (wishlistData != null) {
      wishlistData[FireStoreService.kProduceIds].forEach((fruitId) {
        _produce.add(fruitId);
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

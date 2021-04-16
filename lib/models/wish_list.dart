import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a charity's wishlist
/// [_produce]: list of produce ids selected by the charity
class WishList extends ChangeNotifier {
  final PriorityQueue<String> _produce = PriorityQueue();

  /// Return a copy of [_produce] sorted in alphabetical order
  UnmodifiableListView<String> get produce {
    return UnmodifiableListView(_produce.toList());
  }

  /// Add [produceId] to list
  void pickProduce(String produceId) {
    _produce.add(produceId);
    notifyListeners();
  }

  /// Remove [produceId] from list
  void removeProduce(String produceId) {
    _produce.remove(produceId);
    notifyListeners();
  }

  /// Parse [produceId] from database
  /// [wishlistData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> userData) {
    _produce.clear();
    List<dynamic> wishlist = userData[FireStoreService.kWishList];
    if (wishlist != null) {
      wishlist.forEach((produceId) {
        _produce.add(produceId);
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

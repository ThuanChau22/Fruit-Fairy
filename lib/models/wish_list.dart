import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a charity's wishlist
/// [_produce]: list of produce ids selected by the charity
class WishList extends ChangeNotifier {
  final PriorityQueue<String> _produceIds = PriorityQueue();

  /// Return a copy of [_produceIds] sorted in alphabetical order
  UnmodifiableListView<String> get produceIds {
    return UnmodifiableListView(_produceIds.toList());
  }

  /// Add [produceId] to list
  void pickProduce(String produceId) {
    _produceIds.add(produceId);
    notifyListeners();
  }

  /// Remove [produceId] from list
  void removeProduce(String produceId) {
    _produceIds.remove(produceId);
    notifyListeners();
  }

  /// Parse [produceId] from database
  /// [wishlistData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> userData) {
    _produceIds.clear();
    List<dynamic> wishlist = userData[FireStoreService.kWishList];
    if (wishlist != null) {
      wishlist.forEach((produceId) {
        _produceIds.add(produceId);
      });
    }
    notifyListeners();
  }

  /// Set [_produceIds] to default value
  void clear() {
    _produceIds.clear();
    notifyListeners();
  }
}

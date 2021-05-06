import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// A class that represents a charity's wishlist
/// [_produce]: List of produce ids selected by the charity
/// [_subscriptions]: List of stream subcriptions that
/// performs an opperation for each subcription on changes
/// [isAllSelected]: Indicate whether all produce is on wishlist
/// [isLoading]: A flag indicate loading state
/// [cursor]: A cursor used to traverse internal list
/// [LoadLimit]: Limit amount per Produce retrieval
class WishList extends ChangeNotifier {
  static const LoadLimit = 20;
  final List<String> _produceIds = [];
  final List<StreamSubscription> _subscriptions = [];
  bool isAllSelected = false;
  bool isLoading = true;
  int endCursor = LoadLimit;

  /// Return a copy of [_produceIds] sorted in alphabetical order
  UnmodifiableListView<String> get produceIds {
    _produceIds.sort();
    return UnmodifiableListView(_produceIds);
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

  /// Remove all [produceId] from list
  void removeAllProduce() {
    _produceIds.clear();
    notifyListeners();
  }

  /// Add [subscription] to [_subscriptions] list
  void addStream(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions from [_subscriptions]
  void clearStream() {
    for (StreamSubscription subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Set object to initial state
  /// Cancel all [_subscriptions]
  void clear() {
    clearStream();
    _produceIds.clear();
    isAllSelected = false;
    isLoading = true;
    endCursor = LoadLimit;
    notifyListeners();
  }
}

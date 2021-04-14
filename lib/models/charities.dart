import 'dart:collection';
import 'package:flutter/foundation.dart';
//
import 'package:fruitfairy/models/charity.dart';

/// A class holds a list of suggested charities that a donor can select
/// [_charities]: a list of [Charity] sorted in highest score
/// [MaxDistance]: Maximum distance of charity address related to donor address
/// [MaxCharity]: Maximum number of charities to be suggested
class Charities extends ChangeNotifier {
  static const double MaxDistance = 20.0;
  static const int MaxCharity = 5;
  final List<Charity> _charities = [];

  /// Return a copy of [_charities]
  UnmodifiableListView<Charity> get list {
    return UnmodifiableListView(_charities);
  }

  /// Set suggested charities to a list
  void setList(List<Charity> charities) {
    _charities.addAll(charities);
    notifyListeners();
  }

  /// Clear suggested charities list
  void clear() {
    _charities.clear();
    notifyListeners();
  }
}

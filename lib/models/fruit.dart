import 'package:meta/meta.dart';

class Fruit {
  static const Min = 25;
  static const Max = 100;
  static const int AdjustAmount = 5;
  final String id;
  final String name;
  final String imagePath;
  final String imageURL;
  int _currentAmount = Min;

  Fruit({
    @required this.id,
    @required this.name,
    @required this.imagePath,
    @required this.imageURL,
  });

  int get amount {
    return _currentAmount;
  }

  void increase() {
    int result = _currentAmount + AdjustAmount;
    _currentAmount = result < Max ? result : Max;
  }

  void decrease() {
    int result = _currentAmount - AdjustAmount;
    _currentAmount = result > Min ? result : Min;
  }

  void clear() {
    _currentAmount = Min;
  }
}

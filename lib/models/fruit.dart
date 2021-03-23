class Fruit {
  static const Min = 25;
  static const Max = 100;
  final String id;
  final String name;
  final String imagePath;
  final String imageURL;
  int _amount = Min;

  Fruit({
    this.id,
    this.name,
    this.imagePath,
    this.imageURL,
  });

  int get amount {
    return _amount;
  }

  void increase(int amount) {
    int result = _amount + amount;
    _amount = result < Max ? result : Max;
  }

  void decrease(int amount) {
    int result = _amount - amount;
    _amount = result > Min ? result : Min;
  }

  void clear() {
    _amount = Min;
  }
}

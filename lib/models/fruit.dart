class Fruit {
  static const Max = 100;
  static const Min = 25;
  final String id;
  final String name;
  final String imagePath;
  final String imageURL;
  int _amount = Min;
  bool _selectedOption = false;

  Fruit({
    this.id,
    this.name,
    this.imagePath,
    this.imageURL,
  });

  int get amount {
    return _amount;
  }

  bool get selectedOption {
    return _selectedOption;
  }

  bool changeOption(bool option){
    _selectedOption = option;
    return _selectedOption;
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

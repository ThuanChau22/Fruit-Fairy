/// A class that represents a produce
/// [id]: unique String to identify a produce
/// in both system and database (produce name)
/// [name]: a display name of produce
/// [imagePath]: a path to image in storage
/// [imageURL]: public URL for produce image
/// [Min]: minimun percentage a donor can select
/// [Max]: maximun percentage a donor can select
/// [AdjustAmount]: number of percentage can be adjusted each time
/// [_currentAmount]: current percentage of a produce
class ProduceItem implements Comparable<ProduceItem> {
  static const Min = 25;
  static const Max = 100;
  static const int AdjustAmount = 5;
  final String id;
  String _name;
  String _imagePath;
  String _imageURL = '';
  int _currentAmount = Min;

  ProduceItem(this.id);

  /// Return a copy of [_name]
  String get name {
    return _name;
  }

  /// Return a copy of [_imagePath]
  String get imagePath {
    return _imagePath;
  }

  /// Return a copy of [_imageURL]
  String get imageURL {
    return _imageURL;
  }

  /// Return a copy of [_currentAmount]
  int get amount {
    return _currentAmount;
  }

  /// Set produce item name
  void setName(String name) {
    _name = name;
  }

  /// Set produce item image path
  void setImagePath(String imagePath) {
    _imagePath = imagePath;
  }

  /// Set image URL
  void setImageURL(String imageURL) {
    _imageURL = imageURL;
  }

  /// Set default [_currentAmount]
  /// between [Min] and [Max]
  void setAmount(int amount) {
    if (amount < Min) {
      amount = Min;
    }
    if (amount > Max) {
      amount = Max;
    }
    _currentAmount = amount;
  }

  /// Increase [_currentAmount]
  /// Cap at [Max]
  void increase() {
    int result = _currentAmount + AdjustAmount;
    _currentAmount = result < Max ? result : Max;
  }

  /// Decrease [_currentAmount]
  /// Cap at [Min]
  void decrease() {
    int result = _currentAmount - AdjustAmount;
    _currentAmount = result > Min ? result : Min;
  }

  /// Return a clone of this produce
  ProduceItem clone() {
    ProduceItem produceItem = ProduceItem(id);
    produceItem.setName(_name);
    produceItem.setImagePath(_imagePath);
    produceItem.setImageURL(_imageURL);
    return produceItem;
  }

  @override
  int compareTo(ProduceItem other) {
    return this.name.compareTo(other.name);
  }
}

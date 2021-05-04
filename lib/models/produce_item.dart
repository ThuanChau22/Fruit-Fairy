/// A class that represents a produce
/// [id]: unique String to identify a produce
/// [name]: a display name of produce
/// [imagePath]: a path to image in storage
/// [imageURL]: public URL for produce image
/// [isLoading]: A flag indicate loading state
/// [_amount]: current percentage of a produce
/// [Min]: minimun percentage a donor can select
/// [Max]: maximun percentage a donor can select
/// [AdjustAmount]: number of percentage can be adjusted each time
class ProduceItem implements Comparable<ProduceItem> {
  static const Min = 25;
  static const Max = 100;
  static const int AdjustAmount = 5;
  final String id;
  String name = '';
  String imagePath = '';
  String imageURL = '';
  bool enabled = true;
  bool isLoading = true;
  int _amount = Min;

  ProduceItem(this.id);

  /// Return a copy of [_amount]
  int get amount {
    return _amount;
  }

  /// Set default [_amount]
  /// between [Min] and [Max]
  set amount(int amount) {
    if (amount < Min) {
      amount = Min;
    }
    if (amount > Max) {
      amount = Max;
    }
    _amount = amount;
  }

  /// Increase [_amount]
  /// Cap at [Max]
  void increase() {
    int result = _amount + AdjustAmount;
    _amount = result < Max ? result : Max;
  }

  /// Decrease [_amount]
  /// Cap at [Min]
  void decrease() {
    int result = _amount - AdjustAmount;
    _amount = result > Min ? result : Min;
  }

  /// Return a clone of this produce
  ProduceItem clone() {
    ProduceItem produceItem = ProduceItem(id);
    produceItem.name = name;
    produceItem.imagePath = imagePath;
    produceItem.imageURL = imageURL;
    produceItem.isLoading = false;
    return produceItem;
  }

  @override
  int compareTo(ProduceItem other) {
    return this.name.compareTo(other.name);
  }
}

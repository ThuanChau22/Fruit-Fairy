import 'package:fruitfairy/services/firestore_service.dart';

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

  /// Set image URL
  void setImageURL(String imageURL) {
    _imageURL = imageURL;
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

  /// Parse donation information from database
  /// [produceItemData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> produceItemData) {
    _name = produceItemData[FireStoreService.kProduceName];
    _imagePath = produceItemData[FireStoreService.kProducePath];
  }

  /// Set [_currentAmount] to default value
  void clear() {
    _currentAmount = Min;
  }

  @override
  int compareTo(ProduceItem other) {
    return this.name.compareTo(other.name);
  }
}

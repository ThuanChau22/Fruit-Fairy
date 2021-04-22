import 'dart:collection';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a suggested charity to a donation
/// [id]: charity document id on database
/// [_produce]: a set of produceIds from charity wishlist
/// [_address]: charity address
/// [_name]: charity name
/// [_score]: a value that is used to rank charity suggestion priorrity
class Charity implements Comparable<Charity> {
  /// Set default values for all fields
  final String id;
  String _name = '';
  final Set<String> _wishlist = {};
  final Map<String, String> _address = {};
  double _score = 0;

  /// Instantiate with charity document [id]
  Charity(this.id);

  /// Return a copy of [_name]
  String get name {
    return _name;
  }

  /// Return a copy of [_wishlist] as a set
  UnmodifiableSetView<String> get wishlist {
    return UnmodifiableSetView(_wishlist);
  }

  /// Return a copy of [_address]
  /// A Map with keys that are declared in [FireStoreService]
  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  /// Return a copy of [_score]
  double get score {
    return _score;
  }

  /// Set new ranking score
  void setScore(double score) {
    _score = score;
  }

  /// Parse account information from database
  /// [userData]: A Map with keys that are declared in [FireStoreService]
  void fromDB(Map<String, dynamic> userData) {
    _name = userData[FireStoreService.kCharityName];

    Map<String, dynamic> address = userData[FireStoreService.kAddress];
    if (address != null) {
      _address[FireStoreService.kAddressStreet] =
          address[FireStoreService.kAddressStreet];
      _address[FireStoreService.kAddressCity] =
          address[FireStoreService.kAddressCity];
      _address[FireStoreService.kAddressState] =
          address[FireStoreService.kAddressState];
      _address[FireStoreService.kAddressZip] =
          address[FireStoreService.kAddressZip];
    }

    List<dynamic> wishlist = userData[FireStoreService.kWishList];
    if (wishlist != null) {
      wishlist.forEach((produceId) {
        _wishlist.add(produceId);
      });
    }
  }

  @override
  int compareTo(Charity other) {
    return other._score.compareTo(this._score);
  }
}

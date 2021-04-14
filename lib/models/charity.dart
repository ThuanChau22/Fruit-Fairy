import 'dart:collection';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A class that represents a suggested charity to a donation
/// [id]: charity document id on database
/// [_produce]: a set of produceIds from charity wishlist
/// [_address]: charity address
/// [_name]: charity display name
/// [_score]: a value that is used to rank charity suggestion priorrity
class Charity implements Comparable<Charity> {
  /// Set default values for all fields
  final String id;
  final Set<String> _produce = {};
  final Map<String, String> _address = {};
  String _name = '';
  double _score = 0;

  /// Instantiate with charity document [id]
  Charity(this.id);

  /// Return a copy of [_name]
  String get name {
    return _name;
  }

  /// Return a copy of [_produce] as a set
  UnmodifiableSetView<String> get produce {
    return UnmodifiableSetView(_produce);
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

  /// Parse [fruitId] from database
  /// [wishlistData]: A Map with keys that are declared in [FireStoreService]
  void fromWishListsDB(Map<String, dynamic> wishlistData) {
    if (wishlistData != null) {
      wishlistData[FireStoreService.kProduceIds].forEach((fruitId) {
        _produce.add(fruitId);
      });
    }
  }

  /// Parse account information from database
  /// [accountData]: A Map with keys that are declared in [FireStoreService]
  void fromUsersDB(Map<String, dynamic> userData) {
    // Charity name
    _name = userData[FireStoreService.kCharityName];

    // Address
    Map<String, dynamic> address = userData[FireStoreService.kAddress];
    _address[FireStoreService.kAddressStreet] =
        address[FireStoreService.kAddressStreet];
    _address[FireStoreService.kAddressCity] =
        address[FireStoreService.kAddressCity];
    _address[FireStoreService.kAddressState] =
        address[FireStoreService.kAddressState];
    _address[FireStoreService.kAddressZip] =
        address[FireStoreService.kAddressZip];
  }

  /// Set new ranking score
  void setScore(double score) {
    _score = score;
  }

  @override
  int compareTo(Charity other) {
    return other._score.compareTo(this._score);
  }
}

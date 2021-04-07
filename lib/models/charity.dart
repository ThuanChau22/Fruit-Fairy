import 'dart:collection';
//
import 'package:fruitfairy/services/firestore_service.dart';

class Charity implements Comparable<Charity> {
  final String id;
  String _name = '';
  final Set<String> _produceIds = {};
  final Map<String, String> _address = {};
  double _score = 0;

  Charity(this.id);

  String get name {
    return _name;
  }

  UnmodifiableSetView<String> get produceIds {
    return UnmodifiableSetView(_produceIds);
  }

  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  void fromWishListsDB(Map<String, dynamic> wishlistData) {
    // TODO: parse charity wish list into a set
    throw UnimplementedError();
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

  @override
  int compareTo(Charity other) {
    return this._score.compareTo(other._score);
  }
}

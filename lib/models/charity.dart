import 'dart:collection';

/// A class that represents a suggested charity to a donation
/// [id]: charity document id on database
/// [_name]: charity name
/// [_address]: charity address
/// [_wishlist]: a set of produce ids from charity wishlist
/// [_score]: a value that is used to rank charity suggestion priorrity
class Charity implements Comparable<Charity> {
  /// Set default values for all fields
  final String id;
  final Set<String> _wishlist = {};
  final Map<String, String> _address = {};
  String name = '';
  double score = 0;

  /// Instantiate with charity document [id]
  Charity(this.id);

  /// Return a copy of [_wishlist] as a set
  UnmodifiableSetView<String> get wishlist {
    return UnmodifiableSetView(_wishlist);
  }

  /// Return a copy of [_address]
  /// A Map with keys that are declared in [FireStoreService]
  UnmodifiableMapView<String, String> get address {
    return UnmodifiableMapView(_address);
  }

  /// Set charity wishlist
  set wishList(List<dynamic> wishlist) {
    if (wishlist != null) {
      for (dynamic produceId in wishlist) {
        _wishlist.add(produceId);
      }
    }
  }

  /// Set charity address
  /// [address]: A Map with keys that are declared in [FireStoreService]
  set address(Map<String, dynamic> address) {
    if (address != null) {
      address.forEach((key, value) {
        _address[key] = value;
      });
    }
  }

  @override
  int compareTo(Charity other) {
    return other.score.compareTo(this.score);
  }
}

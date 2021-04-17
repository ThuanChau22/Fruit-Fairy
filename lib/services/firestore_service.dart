import 'dart:async';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/services/map_service.dart';
import 'package:fruitfairy/services/session_token.dart';

class FireStoreService {
  /// Database fields

  /// donations
  static const String kCharities = 'charities';
  static const String kCharityId = 'charityId';
  static const String kDonorId = 'donorId';
  static const String kProduceId = 'produceId';
  static const String kAmount = 'amount';
  static const String kStatus = 'status';
  static const String kCreatedAt = 'createdAt';

  /// produce
  static const String kProduce = 'produce';
  static const String kProduceName = 'name';
  static const String kProducePath = 'path';
  static const String kProduceEnabled = 'enabled';

  /// users
  static const String kUsers = 'users';
  static const String kEmail = 'email';
  static const String kFirstName = 'firstname';
  static const String kLastName = 'lastname';
  static const String kEIN = 'ein';
  static const String kCharityName = 'charityName';
  static const String kPhone = 'phone';
  static const String kPhoneNumber = 'number';
  static const String kPhoneCountry = 'country';
  static const String kPhoneDialCode = 'dialCode';
  static const String kAddress = 'address';
  static const String kAddressStreet = 'street';
  static const String kAddressCity = 'city';
  static const String kAddressState = 'state';
  static const String kAddressZip = 'zip';
  static const String kWishList = 'wishlist';

  ///////////////

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference _usersDB;
  CollectionReference _produceDB;

  String _uid;

  FireStoreService() {
    _usersDB = _firestore.collection(kUsers);
    _produceDB = _firestore.collection(kProduce);
  }

  FirebaseFirestore get instance {
    return FirebaseFirestore.instance;
  }

  String get uid {
    return _uid;
  }

  StreamSubscription<DocumentSnapshot> userStream(
    Function(Map<String, dynamic>) onData,
  ) {
    DocumentReference doc = _usersDB.doc(_uid);
    return doc.snapshots().listen(
      (snapshot) {
        onData(snapshot.data());
      },
      onError: (e) {
        print(e);
      },
    );
  }

  StreamSubscription<QuerySnapshot> produceStream(
    Function(Map<String, ProduceItem>) onData,
  ) {
    Query query = _produceDB.where(kProduceEnabled, isEqualTo: true);
    return query.snapshots().listen(
      (snapshot) async {
        Map<String, ProduceItem> snapshotData = {};
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data();
          snapshotData[doc.id] = ProduceItem(
            id: doc.id,
            name: data[kProduceName],
            imagePath: data[kProducePath],
          );
        }
        await Future.wait(snapshotData.values.map((produceItem) async {
          produceItem.setImageURL(await imageURL(produceItem.imagePath));
        }));
        onData(snapshotData);
      },
      onError: (e) {
        print(e);
      },
    );
  }

  Future<String> imageURL(String path) async {
    try {
      return await _storage.refFromURL(path).getDownloadURL();
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<List<Charity>> charitySuggestions({
    @required Donation donation,
    @required double limitDistance,
    @required int limitCharity,
  }) async {
    List<String> selectedProduce = donation.produce.keys.toList();
    Query query = _usersDB.where(kWishList, arrayContainsAny: selectedProduce);
    QuerySnapshot snapshot = await query.get();
    List<Charity> charities = [];
    for (DocumentSnapshot userDoc in snapshot.docs) {
      Charity charity = Charity(userDoc.id);
      charity.fromUsersDB(userDoc.data());
      charities.add(charity);
    }

    Map<String, String> donationAddress = donation.address;
    String street = donationAddress[kAddressStreet];
    String city = donationAddress[kAddressCity];
    String state = donationAddress[kAddressState];
    String zip = donationAddress[kAddressZip];
    String origin = '$street $city $state $zip';
    List<String> destinations = [];
    for (Charity charity in charities) {
      Map<String, String> charityAddress = charity.address;
      String street = charityAddress[kAddressStreet];
      String city = charityAddress[kAddressCity];
      String state = charityAddress[kAddressState];
      String zip = charityAddress[kAddressZip];
      destinations.add('$street $city $state $zip');
    }
    List<double> distances = await MapService.getDistances(
      origin: origin,
      destinations: destinations,
    );

    double matchPerProduce = limitDistance / selectedProduce.length;
    PriorityQueue<Charity> rankedCharity = PriorityQueue();
    for (int i = 0; i < distances.length; i++) {
      if (distances[i] <= limitDistance) {
        double matchScore = 0.0;
        Set<String> wishList = charities[i].produce;
        for (String produceId in selectedProduce) {
          matchScore += wishList.contains(produceId) ? matchPerProduce : 0.0;
        }
        double distanceScore = limitDistance - distances[i];
        charities[i].setScore(matchScore + distanceScore);
        rankedCharity.add(charities[i]);
      }
    }

    charities.clear();
    for (int i = 0; i < limitCharity && rankedCharity.isNotEmpty; i++) {
      charities.add(rankedCharity.removeFirst());
    }
    return charities;
  }

  Future<void> addDonorAccount({
    @required String email,
    @required String firstName,
    @required String lastName,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).set({
        kEmail: email,
      });
      await updateDonorName(
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> addCharityAccount({
    @required String email,
    @required String ein,
    @required String charityName,
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).set({
        kEmail: email,
        kEIN: ein,
      });
      await updateCharityName(
        camelize(charityName),
      );
      SessionToken sessionToken = SessionToken();
      List<Map<String, String>> results = await MapService.addressSuggestions(
        '$street, $city, $state $zip',
        sessionToken: sessionToken.getToken(),
      );
      if (results.isNotEmpty) {
        Map<String, String> charityAddress = await MapService.addressDetails(
          results.first[MapService.kPlaceId],
          sessionToken: sessionToken.getToken(),
        );
        await updateUserAddress(
          street: charityAddress[MapService.kStreet],
          city: charityAddress[MapService.kCity],
          state: charityAddress[MapService.kState],
          zip: charityAddress[MapService.kZipCode],
        );
      }
      sessionToken.clear();
      await updateWishList([]);
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateDonorName({
    @required String firstName,
    @required String lastName,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).update({
        kFirstName: firstName,
        kLastName: lastName,
      });
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateCharityName(
    String charityName,
  ) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).update({
        kCharityName: charityName,
      });
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateUserAddress({
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _usersDB.doc(_uid);
      if (street.isEmpty && city.isEmpty && state.isEmpty && zip.isEmpty) {
        await doc.update({
          kAddress: FieldValue.delete(),
        });
      } else {
        await doc.update({
          kAddress: {
            kAddressStreet: street,
            kAddressCity: city,
            kAddressState: state,
            kAddressZip: zip,
          },
        });
      }
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updatePhoneNumber({
    @required String country,
    @required String dialCode,
    @required String phoneNumber,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _usersDB.doc(_uid);
      if (phoneNumber.isEmpty) {
        await doc.update({
          kPhone: FieldValue.delete(),
        });
      } else {
        await doc.update({
          kPhone: {
            kPhoneCountry: country,
            kPhoneDialCode: dialCode,
            kPhoneNumber: phoneNumber,
          },
        });
      }
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateWishList(
    List<String> wishlist,
  ) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).update({
        kWishList: wishlist,
      });
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> deleteAccount() async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).delete();
    } catch (e) {
      throw e.message;
    }
  }

  void setUID(String uid) {
    this._uid = uid;
  }

  void clear() {
    _uid = null;
  }
}

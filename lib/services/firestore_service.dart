import 'dart:async';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/status.dart';
import 'package:fruitfairy/services/map_service.dart';
import 'package:fruitfairy/services/session_token.dart';

class FireStoreService {
  /// Database fields

  /// donations
  static const String kDonations = 'donations';
  static const String kDonor = 'donor';
  static const String kCharity = 'charity';
  static const String kUserId = 'userId';
  static const String kUserName = 'userName';
  static const String kNeedCollected = 'needCollected';
  static const String kProduceId = 'produceId';
  static const String kAmount = 'amount';
  static const String kSelectedCharities = 'selectedCharities';
  static const String kRequestedCharities = 'requestedCharities';
  static const String kStatus = 'status';
  static const String kDenied = 'denied';
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
  static const String kLastSignedIn = 'lastSignedIn';

  ///////////////

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference _usersDB;
  CollectionReference _produceDB;
  CollectionReference _donationsDB;

  String _uid;

  FireStoreService() {
    _usersDB = _firestore.collection(kUsers);
    _produceDB = _firestore.collection(kProduce);
    _donationsDB = _firestore.collection(kDonations);
  }

  FirebaseFirestore get instance {
    return _firestore;
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
    Query query = _produceDB
        .where(kProduceEnabled, isEqualTo: true)
        .orderBy(kProduceName)
        .limit(12);
    return query.snapshots().listen(
      (snapshot) async {
        Map<String, ProduceItem> snapshotData = {};
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          ProduceItem produceItem = ProduceItem(doc.id);
          produceItem.fromDB(doc.data());
          snapshotData[produceItem.id] = produceItem;
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

  void donationStreamDonor(
    Donations donations, {
    Function onChange,
  }) async {
    String donorId = '$kDonor.$kUserId';
    if (donations.startDocument == null) {
      QuerySnapshot snapshot = await _donationsDB
          .where(donorId, isEqualTo: _uid)
          .orderBy(kStatus)
          .orderBy(kCreatedAt, descending: true)
          .limit(3)
          .get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      if (docs.isNotEmpty) {
        donations.setStartDocument(docs.last);
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .startAtDocument(donations.startDocument)
            .snapshots();
        _donationStreamDonor(snapshots, donations, onChange);
      } else {
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .snapshots();
        _donationStreamDonor(snapshots, donations, onChange);
      }
    } else {
      QuerySnapshot snapshot = await _donationsDB
          .where(donorId, isEqualTo: _uid)
          .orderBy(kStatus)
          .orderBy(kCreatedAt, descending: true)
          .startAfterDocument(donations.startDocument)
          .limit(3)
          .get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      if (docs.isNotEmpty) {
        donations.setEndDocument(docs.first);
        donations.setStartDocument(docs.last);
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .startAtDocument(donations.startDocument)
            .endAtDocument(donations.endDocument)
            .snapshots();
        _donationStreamDonor(snapshots, donations, onChange);
      }
    }
  }

  void _donationStreamDonor(
    Stream<QuerySnapshot> snapshots,
    Donations donations,
    Function onChange,
  ) {
    donations.addStream(snapshots.listen(
      (snapshot) async {
        for (DocumentChange docChange in snapshot.docChanges) {
          String donationId = docChange.doc.id;
          if (docChange.type == DocumentChangeType.removed) {
            donations.removeDonation(donationId);
            donations.clearStream();
            _donationStreamDonor(
              _donationsDB
                  .where('$kDonor.$kUserId', isEqualTo: _uid)
                  .orderBy(kStatus, descending: true)
                  .orderBy(kCreatedAt)
                  .startAtDocument(donations.startDocument)
                  .snapshots(),
              donations,
              onChange,
            );
          } else {
            Map<String, dynamic> data = docChange.doc.data();
            Donation donation = Donation(donationId);
            donation.setStatus(Status(
              data[kStatus],
              isDenied: data[kDenied],
            ));
            donation.setCreatedAt(data[kCreatedAt]);
            donations.pickDonation(donation);
          }
        }
        if (onChange != null) {
          onChange();
        }
      },
      onError: (e) {
        print(e);
      },
    ));
  }

  void donationStreamCharity(
    Donations donations, {
    Function onChange,
  }) async {
    if (donations.startDocument == null) {
      QuerySnapshot snapshot = await _donationsDB
          .where(kRequestedCharities, arrayContains: _uid)
          .orderBy(kStatus)
          .orderBy(kCreatedAt, descending: true)
          .limit(3)
          .get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      if (docs.isNotEmpty) {
        donations.setStartDocument(docs.last);
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .startAtDocument(donations.startDocument)
            .snapshots();
        _donationStreamCharity(snapshots, donations, onChange);
      } else {
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .snapshots();
        _donationStreamCharity(snapshots, donations, onChange);
      }
    } else {
      QuerySnapshot snapshot = await _donationsDB
          .where(kRequestedCharities, arrayContains: _uid)
          .orderBy(kStatus)
          .orderBy(kCreatedAt, descending: true)
          .startAfterDocument(donations.startDocument)
          .limit(3)
          .get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      if (docs.isNotEmpty) {
        donations.setEndDocument(docs.first);
        donations.setStartDocument(docs.last);
        Stream<QuerySnapshot> snapshots = _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus, descending: true)
            .orderBy(kCreatedAt)
            .startAtDocument(donations.startDocument)
            .endAtDocument(donations.endDocument)
            .snapshots();
        _donationStreamCharity(snapshots, donations, onChange);
      }
    }
  }

  void _donationStreamCharity(
    Stream<QuerySnapshot> snapshots,
    Donations donations,
    Function onChange,
  ) {
    donations.addStream(snapshots.listen(
      (snapshot) async {
        for (DocumentChange docChange in snapshot.docChanges) {
          String donationId = docChange.doc.id;
          if (docChange.type == DocumentChangeType.removed) {
            donations.removeDonation(donationId);
            donations.clearStream();
            _donationStreamDonor(
              _donationsDB
                  .where(kRequestedCharities, arrayContains: _uid)
                  .orderBy(kStatus, descending: true)
                  .orderBy(kCreatedAt)
                  .startAtDocument(donations.startDocument)
                  .snapshots(),
              donations,
              onChange,
            );
          } else {
            Map<String, dynamic> data = docChange.doc.data();
            Donation donation = Donation(donationId);
            donation.setStatus(Status(
              data[kStatus],
              isDenied: data[kDenied],
              isCharity: true,
            ));
            donation.setCreatedAt(data[kCreatedAt]);
            donation.setNeedCollected(data[kNeedCollected]);
            donations.pickDonation(donation);
          }
        }
        if (onChange != null) {
          onChange();
        }
      },
      onError: (e) {
        print(e);
      },
    ));
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
      charity.fromDB(userDoc.data());
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
        Set<String> wishList = charities[i].wishlist;
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
        kFirstName: firstName,
        kLastName: lastName,
      });
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
        kCharityName: camelize(charityName),
        kWishList: [],
      });
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

  Future<void> updateLastSignedIn() async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).update({
        kLastSignedIn: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> addDonation(Donation donation) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      Map<String, String> address = donation.address;
      Map<String, String> phone = donation.phone;
      await _donationsDB.add({
        kDonor: {
          kUserId: _uid,
          kUserName: donation.donorName,
        },
        kNeedCollected: donation.needCollected,
        kProduce: donation.produce.values.map((produceItem) {
          Map<String, dynamic> produce = {
            kProduceId: produceItem.id,
          };
          if (donation.needCollected) {
            produce[kAmount] = produceItem.amount;
          }
          return produce;
        }).toList(),
        kAddress: {
          kAddressStreet: address[kAddressStreet],
          kAddressCity: address[kAddressCity],
          kAddressState: address[kAddressState],
          kAddressZip: address[kAddressZip],
        },
        kPhone: {
          kPhoneCountry: phone[kPhoneCountry],
          kPhoneDialCode: phone[kPhoneDialCode],
          kPhoneNumber: phone[kPhoneNumber],
        },
        kSelectedCharities: donation.charities.map((charity) {
          return charity.id;
        }).toList(),
        kRequestedCharities: [],
        kStatus: donation.status.code,
        kDenied: donation.status.isDenied,
        kCreatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
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

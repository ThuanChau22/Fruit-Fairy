import 'dart:async';
import 'package:fruitfairy/models/produce.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:strings/strings.dart';
//
import 'package:fruitfairy/models/account.dart';
import 'package:fruitfairy/models/charity.dart';
import 'package:fruitfairy/models/donation.dart';
import 'package:fruitfairy/models/donations.dart';
import 'package:fruitfairy/models/produce_item.dart';
import 'package:fruitfairy/models/status.dart';
import 'package:fruitfairy/models/wish_list.dart';
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
  static const String kSubStatus = 'subStatus';
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

  void userStream(
    Account account, {
    Function onComplete,
  }) {
    onComplete = onComplete ?? () {};
    try {
      DocumentReference doc = _usersDB.doc(_uid);
      account.addStream(doc.snapshots().listen(
        (snapshot) {
          Map<String, dynamic> data = snapshot.data();
          if (data != null) {
            account.fromDB(data);
          }
          onComplete();
        },
        onError: (e) {
          print(e);
        },
      ));
    } catch (e) {
      print(e);
    }
  }

  void wishListStream(
    WishList wishList, {
    Function onComplete,
  }) {
    onComplete = onComplete ?? () {};
    try {
      DocumentReference doc = _usersDB.doc(_uid);
      wishList.addStream(doc.snapshots().listen(
        (snapshot) {
          Map<String, dynamic> data = snapshot.data();
          if (data != null) {
            wishList.fromDB(data);
          }
          onComplete();
        },
        onError: (e) {
          print(e);
        },
      ));
    } catch (e) {
      print(e);
    }
  }

  void produceStream(
    Produce produce, {
    Function onComplete,
  }) async {
    onComplete = onComplete ?? () {};
    try {
      if (produce.startDocument == null) {
        QuerySnapshot snapshot = await _produceDB
            .where(kProduceEnabled, isEqualTo: true)
            .orderBy(kProduceName)
            .orderBy(kCreatedAt, descending: true)
            .limit(Produce.LOAD_LIMIT)
            .get();
        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          produce.setStartDocument(docs.last);
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(produce.startDocument)
              .snapshots();
          _produceStream(snapshots, produce, onComplete);
        } else {
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
          _produceStream(snapshots, produce, onComplete);
        }
      } else {
        QuerySnapshot snapshot = await _produceDB
            .where(kProduceEnabled, isEqualTo: true)
            .orderBy(kProduceName)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(produce.startDocument)
            .limit(Produce.LOAD_LIMIT)
            .get();
        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          produce.setEndDocument(docs.first);
          produce.setStartDocument(docs.last);
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(produce.startDocument)
              .endAtDocument(produce.endDocument)
              .snapshots();
          _produceStream(snapshots, produce, onComplete);
        } else {
          onComplete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _produceStream(
    Stream<QuerySnapshot> snapshots,
    Produce produce,
    Function onComplete,
  ) {
    try {
      produce.addStream(snapshots.listen(
        (snapshot) async {
          List<ProduceItem> produceList = [];
          for (DocumentChange docChange in snapshot.docChanges) {
            DocumentSnapshot doc = docChange.doc;
            if (docChange.type == DocumentChangeType.removed) {
              produce.removeProduce(doc.id);
            } else {
              Map<String, dynamic> data = doc.data();
              ProduceItem produceItem = ProduceItem(doc.id);
              produceItem.setName(data[kProduceName]);
              produceItem.setImagePath(data[kProducePath]);
              produce.pickProduce(produceItem.id);
              if ((docChange.type == DocumentChangeType.added &&
                      !produce.map.containsKey(produceItem.id)) ||
                  docChange.type == DocumentChangeType.modified) {
                produceList.add(produceItem);
              }
            }
          }
          await Future.wait(produceList.reversed.map((produceItem) async {
            produceItem.setImageURL(await imageURL(produceItem.imagePath));
            produce.storeProduce(produceItem);
          }));
          onComplete();
        },
        onError: (e) {
          print(e);
        },
      ));
    } catch (e) {
      print(e);
    }
  }

  void searchProduce(
    String produceName,
    Produce produce, {
    Function onComplete,
  }) async {
    onComplete = onComplete ?? () {};
    try {
      Query query = _produceDB
          .where(kProduceEnabled, isEqualTo: true)
          .orderBy(kProduceName)
          .startAt([produceName]).endAt(['$produceName\uf8ff']);
      Map<String, ProduceItem> produceStorage = produce.map;
      bool hasNewProduce = false;
      for (QueryDocumentSnapshot doc in (await query.get()).docs) {
        if (!produceStorage.containsKey(doc.id)) {
          hasNewProduce = true;
        }
      }
      if (hasNewProduce) {
        produce.addStream(query.snapshots().listen(
          (snapshot) async {
            List<ProduceItem> produceList = [];
            for (DocumentChange docChange in snapshot.docChanges) {
              DocumentSnapshot doc = docChange.doc;
              if (docChange.type == DocumentChangeType.removed) {
                produce.removeSearchProduce(doc.id);
              } else {
                Map<String, dynamic> data = doc.data();
                ProduceItem produceItem = ProduceItem(doc.id);
                produceItem.setName(data[kProduceName]);
                produceItem.setImagePath(data[kProducePath]);
                produce.pickSearchProduce(doc.id);
                if ((docChange.type == DocumentChangeType.added &&
                        !produce.map.containsKey(produceItem.id)) ||
                    docChange.type == DocumentChangeType.modified) {
                  produceList.add(produceItem);
                }
              }
            }
            await Future.wait(produceList.reversed.map((produceItem) async {
              produceItem.setImageURL(await imageURL(produceItem.imagePath));
              produce.storeProduce(produceItem);
            }));
            onComplete();
          },
          onError: (e) {
            print(e);
          },
        ));
      } else {
        onComplete();
      }
    } catch (e) {
      print(e);
    }
  }

  void donationStreamDonor(
    Donations donations, {
    Function onComplete,
  }) async {
    onComplete = onComplete ?? () {};
    try {
      String donorId = '$kDonor.$kUserId';
      if (donations.startDocument == null) {
        QuerySnapshot snapshot = await _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .limit(Donations.LOAD_LIMIT)
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
          _donationStreamDonor(snapshots, donations, onComplete);
        } else {
          Stream<QuerySnapshot> snapshots = _donationsDB
              .where(donorId, isEqualTo: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
          _donationStreamDonor(snapshots, donations, onComplete);
        }
      } else {
        QuerySnapshot snapshot = await _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(donations.startDocument)
            .limit(Donations.LOAD_LIMIT)
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
          _donationStreamDonor(snapshots, donations, onComplete);
        } else {
          onComplete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _donationStreamDonor(
    Stream<QuerySnapshot> snapshots,
    Donations donations,
    Function onComplete,
  ) {
    try {
      donations.addStream(snapshots.listen(
        (snapshot) {
          for (DocumentChange docChange in snapshot.docChanges) {
            String donationId = docChange.doc.id;
            if (docChange.type == DocumentChangeType.removed) {
              int currentSize = donations.map.length;
              donations.removeDonation(donationId);
              donations.clearStream();
              if (currentSize < Donations.LOAD_LIMIT) {
                _donationStreamDonor(
                  _donationsDB
                      .where('$kDonor.$kUserId', isEqualTo: _uid)
                      .orderBy(kStatus, descending: true)
                      .orderBy(kCreatedAt)
                      .limit(currentSize)
                      .snapshots(),
                  donations,
                  onComplete,
                );
              } else {
                _donationStreamDonor(
                  _donationsDB
                      .where('$kDonor.$kUserId', isEqualTo: _uid)
                      .orderBy(kStatus, descending: true)
                      .orderBy(kCreatedAt)
                      .startAtDocument(donations.startDocument)
                      .snapshots(),
                  donations,
                  onComplete,
                );
              }
            } else {
              Map<String, dynamic> data = docChange.doc.data();
              Donation donation = Donation(donationId);
              donation.setStatus(Status(
                data[kStatus],
                data[kSubStatus],
              ));
              donation.setCreatedAt(data[kCreatedAt]);
              Charity charity = Charity(data[kCharity][kUserId]);
              charity.setName(data[kCharity][kUserName]);
              donation.pickCharity(charity);
              donations.pickDonation(donation);
            }
          }
          onComplete();
        },
        onError: (e) {
          print(e);
        },
      ));
    } catch (e) {
      print(e);
    }
  }

  void donationStreamCharity(
    Donations donations, {
    Function onComplete,
  }) async {
    onComplete = onComplete ?? () {};
    try {
      if (donations.startDocument == null) {
        QuerySnapshot snapshot = await _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .limit(Donations.LOAD_LIMIT)
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
          _donationStreamCharity(snapshots, donations, onComplete);
        } else {
          Stream<QuerySnapshot> snapshots = _donationsDB
              .where(kRequestedCharities, arrayContains: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
          _donationStreamCharity(snapshots, donations, onComplete);
        }
      } else {
        QuerySnapshot snapshot = await _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(donations.startDocument)
            .limit(Donations.LOAD_LIMIT)
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
          _donationStreamCharity(snapshots, donations, onComplete);
        } else {
          onComplete();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _donationStreamCharity(
    Stream<QuerySnapshot> snapshots,
    Donations donations,
    Function onComplete,
  ) {
    try {
      donations.addStream(snapshots.listen(
        (snapshot) {
          for (DocumentChange docChange in snapshot.docChanges) {
            String donationId = docChange.doc.id;
            if (docChange.type == DocumentChangeType.removed) {
              int currentSize = donations.map.length;
              donations.removeDonation(donationId);
              donations.clearStream();
              if (currentSize < Donations.LOAD_LIMIT) {
                _donationStreamCharity(
                  _donationsDB
                      .where(kRequestedCharities, arrayContains: _uid)
                      .orderBy(kStatus, descending: true)
                      .orderBy(kCreatedAt)
                      .limit(currentSize)
                      .snapshots(),
                  donations,
                  onComplete,
                );
              } else {
                _donationStreamCharity(
                  _donationsDB
                      .where(kRequestedCharities, arrayContains: _uid)
                      .orderBy(kStatus, descending: true)
                      .orderBy(kCreatedAt)
                      .startAtDocument(donations.startDocument)
                      .snapshots(),
                  donations,
                  onComplete,
                );
              }
            } else {
              Map<String, dynamic> data = docChange.doc.data();
              Donation donation = Donation(donationId);
              donation.setStatus(Status(
                data[kStatus],
                data[kSubStatus],
                isCharity: true,
              ));
              donation.setCreatedAt(data[kCreatedAt]);
              donation.setNeedCollected(data[kNeedCollected]);
              donations.pickDonation(donation);
            }
          }
          onComplete();
        },
        onError: (e) {
          print(e);
        },
      ));
    } catch (e) {
      print(e);
    }
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
    List<Charity> charities = [];
    try {
      List<String> selectedProduce = donation.produce.keys.toList();
      Query query =
          _usersDB.where(kWishList, arrayContainsAny: selectedProduce);
      QuerySnapshot snapshot = await query.get();
      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        Charity charity = Charity(doc.id);
        charity.setName(data[kCharityName]);
        charity.setAddress(data[kAddress]);
        charity.setWishList(data[kWishList]);
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
    } catch (e) {
      print(e);
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
      List<Charity> charities = donation.charities;
      await _donationsDB.add({
        kDonor: {
          kUserId: donation.donorId,
          kUserName: donation.donorName,
        },
        kCharity: {
          kUserId: charities.first.id,
          kUserName: charities.first.name,
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
        kSelectedCharities: charities.map((charity) {
          return charity.id;
        }).toList(),
        kRequestedCharities: [],
        kStatus: donation.status.code,
        kSubStatus: donation.status.subCode,
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

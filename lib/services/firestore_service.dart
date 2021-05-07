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
import 'package:fruitfairy/services/utils.dart';

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
  static const String kDeviceTokens = 'deviceTokens';
  ///////////////

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference _usersDB;
  CollectionReference _produceDB;
  CollectionReference _donationsDB;

  String _uid;

  FireStoreService() {
    _usersDB = firestore.collection(kUsers);
    _produceDB = firestore.collection(kProduce);
    _donationsDB = firestore.collection(kDonations);
  }

  String get uid {
    return _uid;
  }

  void accountStream(
    Account account, {
    Function onComplete,
  }) {
    onComplete = onComplete ?? () {};
    try {
      DocumentReference doc = _usersDB.doc(_uid);
      account.addStream(doc.snapshots().listen((snapshot) {
        Map<String, dynamic> data = snapshot.data();
        if (data != null) {
          account.fromDB(data);
        }
        onComplete();
      }, onError: (e) {
        print(e);
      }));
    } catch (e) {
      print(e);
    }
  }

  Future<void> wishListStream(
    WishList wishList, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      Query produce = _produceDB.where(kProduceEnabled, isEqualTo: true);
      DocumentReference doc = _usersDB.doc(_uid);
      wishList.addStream(doc.snapshots().listen((snapshot) async {
        Map<String, dynamic> data = snapshot.data();
        if (data != null) {
          List<dynamic> produceIdList = data[kWishList];
          int produceSize = (await produce.get()).size;
          wishList.isAllSelected = produceIdList.length >= produceSize;
          wishList.removeAllProduce();
          for (String produceId in produceIdList) {
            wishList.pickProduce(produceId);
          }
        }
        onData();
      }, onError: (e) {
        print(e);
      }));
      wishList.addStream(produce.snapshots().listen((snapshot) {
        int produceSize = snapshot.docs.length;
        wishList.isAllSelected = wishList.produceIds.length >= produceSize;
      }, onError: (e) {
        print(e);
      }));
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadDonationProduce(
    Donation donation,
    Produce produce, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      List<String> produceIdList = [];
      Map<String, ProduceItem> produceStorage = produce.map;
      for (String produceId in donation.produce.keys) {
        if (!produceStorage.containsKey(produceId)) {
          produceIdList.add(produceId);
        }
      }
      if (produceIdList.isNotEmpty) {
        List<List<String>> lists = Utils.decompose(produceIdList, 10);
        await Future.wait(lists.map((produceIds) async {
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(FieldPath.documentId, whereIn: produceIds)
              .snapshots();
          produce.addStream(snapshots.listen((snapshot) {
            _loadProduceStorage(snapshot, produce, onData);
          }, onError: (e) {
            print(e);
          }));
        }));
      } else {
        onData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadWishListProduce(
    WishList wishList,
    Produce produce, {
    Function onData,
    bool onLoadMore = true,
  }) async {
    onData = onData ?? () {};
    try {
      List<String> produceIdList = [];
      int index = 0;
      if (onLoadMore && wishList.endCursor < wishList.produceIds.length) {
        index = wishList.endCursor;
        wishList.endCursor += WishList.LoadLimit;
      }
      List<String> produceIds = wishList.produceIds;
      Map<String, ProduceItem> produceStorage = produce.map;
      while (index < wishList.endCursor && index < produceIds.length) {
        String produceId = produceIds[index++];
        if (!produceStorage.containsKey(produceId)) {
          produce.storeProduce(ProduceItem(produceId));
          produceIdList.add(produceId);
        }
      }
      if (produceIdList.isNotEmpty) {
        List<List<String>> lists = Utils.decompose(produceIdList, 10);
        await Future.wait(lists.map((produceIds) async {
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(FieldPath.documentId, whereIn: produceIds)
              .snapshots();
          produce.addStream(snapshots.listen((snapshot) {
            _loadProduceStorage(snapshot, produce, onData);
          }, onError: (e) {
            print(e);
          }));
        }));
      } else {
        onData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadProduceStorage(
    QuerySnapshot snapshot,
    Produce produce,
    Function onData,
  ) async {
    try {
      Map<String, ProduceItem> produceStorage = produce.map;
      List<ProduceItem> produceList = [];
      for (DocumentChange docChange in snapshot.docChanges) {
        Map<String, dynamic> data = docChange.doc.data();
        ProduceItem produceItem = ProduceItem(docChange.doc.id);
        produceItem.name = data[kProduceName];
        produceItem.imagePath = data[kProducePath];
        produceItem.enabled = data[kProduceEnabled];
        bool stored = produceStorage.containsKey(produceItem.id);
        if (docChange.type == DocumentChangeType.added && !stored) {
          produceList.add(produceItem);
        } else {
          ProduceItem oldProduceItem = produceStorage[produceItem.id];
          oldProduceItem.name = produceItem.name;
          oldProduceItem.enabled = produceItem.enabled;
          if (oldProduceItem.imagePath != produceItem.imagePath) {
            produceList.add(produceItem);
          }
        }
      }
      await Future.wait(produceList.map((produceItem) async {
        produceItem.imageURL = await imageURL(produceItem.imagePath);
        produceItem.isLoading = false;
        produce.storeProduce(produceItem);
      }));
      onData();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadProduce(
    Produce produce, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      if (produce.startDocument == null) {
        /// Load Initial
        QuerySnapshot snapshot = await _produceDB
            .where(kProduceEnabled, isEqualTo: true)
            .orderBy(kProduceName)
            .orderBy(kCreatedAt, descending: true)
            .limit(Produce.LoadLimit)
            .get();
        await _loadProduce(snapshot, produce, onData);

        Stream<QuerySnapshot> snapshots;
        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          produce.startDocument = docs.last;
          snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(produce.startDocument)
              .snapshots();
        } else {
          snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
        }
        produce.addStream(snapshots.listen((snapshot) {
          _loadProduce(snapshot, produce, onData);
        }, onError: (e) {
          print(e);
        }));
      } else {
        /// Load More
        QuerySnapshot snapshot = await _produceDB
            .where(kProduceEnabled, isEqualTo: true)
            .orderBy(kProduceName)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(produce.startDocument)
            .limit(Produce.LoadLimit)
            .get();

        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          produce.endDocument = docs.first;
          produce.startDocument = docs.last;
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(kProduceEnabled, isEqualTo: true)
              .orderBy(kProduceName, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(produce.startDocument)
              .endAtDocument(produce.endDocument)
              .snapshots();
          produce.addStream(snapshots.listen((snapshot) {
            _loadProduce(snapshot, produce, onData);
          }, onError: (e) {
            print(e);
          }));
        } else {
          onData();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadProduce(
    QuerySnapshot snapshot,
    Produce produce,
    Function onData,
  ) async {
    try {
      Map<String, ProduceItem> produceStorage = produce.map;
      List<ProduceItem> produceList = [];
      for (DocumentChange docChange in snapshot.docChanges) {
        Map<String, dynamic> data = docChange.doc.data();
        ProduceItem produceItem = ProduceItem(docChange.doc.id);
        produceItem.name = data[kProduceName];
        produceItem.imagePath = data[kProducePath];
        produceItem.enabled = data[kProduceEnabled];
        if (docChange.type == DocumentChangeType.removed) {
          produceStorage[produceItem.id].enabled = false;
          produce.removeProduce(produceItem.id);
        } else {
          produce.pickProduce(produceItem.id);
          bool stored = produceStorage.containsKey(produceItem.id);
          if (docChange.type == DocumentChangeType.added && !stored) {
            produceList.add(produceItem);
          } else {
            ProduceItem oldProduceItem = produceStorage[produceItem.id];
            oldProduceItem.name = produceItem.name;
            oldProduceItem.enabled = produceItem.enabled;
            if (oldProduceItem.imagePath != produceItem.imagePath) {
              produceList.add(produceItem);
            }
          }
        }
      }
      produceList.sort();
      await Future.wait(produceList.map((produceItem) async {
        produceItem.imageURL = await imageURL(produceItem.imagePath);
        produceItem.isLoading = false;
        produce.storeProduce(produceItem);
      }));
      onData();
    } catch (e) {
      print(e);
    }
  }

  Future<void> searchProduce(
    String produceName,
    Produce produce, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      QuerySnapshot snapshot = await _produceDB
          .where(kProduceEnabled, isEqualTo: true)
          .orderBy(kProduceName)
          .startAt([produceName]).endAt(['$produceName\uf8ff']).get();

      Map<String, ProduceItem> produceStorage = produce.map;
      List<String> produceIdList = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        if (!produceStorage.containsKey(doc.id)) {
          produceIdList.add(doc.id);
        }
      }
      if (produceIdList.isNotEmpty) {
        List<List<String>> lists = Utils.decompose(produceIdList, 10);
        await Future.wait(lists.map((produceIds) async {
          Stream<QuerySnapshot> snapshots = _produceDB
              .where(FieldPath.documentId, whereIn: produceIds)
              .snapshots();
          produce.addStream(snapshots.listen((snapshot) {
            _searchProduce(snapshot, produce, onData);
          }, onError: (e) {
            print(e);
          }));
        }));
      } else {
        onData();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _searchProduce(
    QuerySnapshot snapshot,
    Produce produce,
    Function onData,
  ) async {
    try {
      Map<String, ProduceItem> produceStorage = produce.map;
      List<ProduceItem> produceList = [];
      for (DocumentChange docChange in snapshot.docChanges) {
        Map<String, dynamic> data = docChange.doc.data();
        ProduceItem produceItem = ProduceItem(docChange.doc.id);
        produceItem.name = data[kProduceName];
        produceItem.imagePath = data[kProducePath];
        produceItem.enabled = data[kProduceEnabled];
        if (produceItem.enabled) {
          produce.pickSearchProduce(produceItem.id);
        } else {
          produce.removeSearchProduce(produceItem.id);
        }
        bool stored = produceStorage.containsKey(produceItem.id);
        if (docChange.type == DocumentChangeType.added && !stored) {
          produceList.add(produceItem);
        } else {
          ProduceItem oldProduceItem = produceStorage[produceItem.id];
          oldProduceItem.name = produceItem.name;
          oldProduceItem.enabled = produceItem.enabled;
          if (oldProduceItem.imagePath != produceItem.imagePath) {
            produceList.add(produceItem);
          }
        }
      }
      await Future.wait(produceList.map((produceItem) async {
        produceItem.imageURL = await imageURL(produceItem.imagePath);
        produceItem.isLoading = false;
        produce.storeProduce(produceItem);
      }));
      onData();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadDonorDonations(
    Donations donations, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      String donorId = '$kDonor.$kUserId';
      if (donations.startDocument == null) {
        /// Load Initial
        QuerySnapshot snapshot = await _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .limit(Donations.LoadLimit)
            .get();

        Stream<QuerySnapshot> snapshots;
        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          donations.startDocument = docs.last;
          snapshots = _donationsDB
              .where(donorId, isEqualTo: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(donations.startDocument)
              .snapshots();
        } else {
          snapshots = _donationsDB
              .where(donorId, isEqualTo: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
        }
        donations.addStream(snapshots.listen((snapshot) {
          _loadDonorDonations(snapshot, donations, onData);
        }, onError: (e) {
          print(e);
        }));
      } else {
        /// Load More
        QuerySnapshot snapshot = await _donationsDB
            .where(donorId, isEqualTo: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(donations.startDocument)
            .limit(Donations.LoadLimit)
            .get();

        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          donations.endDocument = docs.first;
          donations.startDocument = docs.last;
          Stream<QuerySnapshot> snapshots = _donationsDB
              .where(donorId, isEqualTo: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(donations.startDocument)
              .endAtDocument(donations.endDocument)
              .snapshots();
          donations.addStream(snapshots.listen((snapshot) {
            _loadDonorDonations(snapshot, donations, onData);
          }, onError: (e) {
            print(e);
          }));
        } else {
          onData();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _loadDonorDonations(
    QuerySnapshot snapshot,
    Donations donations,
    Function onData,
  ) async {
    try {
      await Future.wait(snapshot.docChanges.map((docChange) async {
        String donationId = docChange.doc.id;
        if (docChange.type == DocumentChangeType.removed) {
          int currentSize = donations.map.length;
          donations.removeDonation(donationId);
          donations.clearStream();
          Stream<QuerySnapshot> snapshots;
          if (currentSize < Donations.LoadLimit) {
            snapshots = _donationsDB
                .where('$kDonor.$kUserId', isEqualTo: _uid)
                .orderBy(kStatus, descending: true)
                .orderBy(kCreatedAt)
                .limit(currentSize)
                .snapshots();
          } else {
            snapshots = _donationsDB
                .where('$kDonor.$kUserId', isEqualTo: _uid)
                .orderBy(kStatus, descending: true)
                .orderBy(kCreatedAt)
                .startAtDocument(donations.startDocument)
                .snapshots();
          }
          donations.addStream(snapshots.listen((snapshot) {
            _loadDonorDonations(snapshot, donations, onData);
          }, onError: (e) {
            print(e);
          }));
        } else {
          Map<String, dynamic> data = docChange.doc.data();
          Donation donation = Donation(donationId);
          donation.status = Status(
            data[kStatus],
            data[kSubStatus],
          );
          Timestamp timeStamp = data[kCreatedAt] ?? Timestamp.now();
          donation.createdAt = timeStamp.toDate();
          donation.needCollected = data[kNeedCollected];
          for (Map<String, dynamic> produce in data[kProduce]) {
            ProduceItem produceItem = ProduceItem(produce[kProduceId]);
            if (donation.needCollected) {
              produceItem.amount = produce[kAmount];
            }
            donation.pickProduce(produceItem);
          }
          donation.setContactInfo(
            street: data[kAddress][kAddressStreet],
            city: data[kAddress][kAddressCity],
            state: data[kAddress][kAddressState],
            zip: data[kAddress][kAddressZip],
            country: data[kPhone][kPhoneCountry],
            dialCode: data[kPhone][kPhoneDialCode],
            phoneNumber: data[kPhone][kPhoneNumber],
          );
          Charity charity = Charity(data[kCharity][kUserId]);
          charity.name = data[kCharity][kUserName];
          donation.pickCharity(charity);
          donations.pickDonation(donation);
        }
      }));
      onData();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadCharityDonations(
    Donations donations, {
    Function onData,
  }) async {
    onData = onData ?? () {};
    try {
      if (donations.startDocument == null) {
        /// Load Initial
        QuerySnapshot snapshot = await _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .limit(Donations.LoadLimit)
            .get();

        Stream<QuerySnapshot> snapshots;
        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          donations.startDocument = docs.last;
          snapshots = _donationsDB
              .where(kRequestedCharities, arrayContains: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(donations.startDocument)
              .snapshots();
        } else {
          snapshots = _donationsDB
              .where(kRequestedCharities, arrayContains: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .snapshots();
        }
        donations.addStream(snapshots.listen((snapshot) {
          _loadCharityDonations(snapshot, donations, onData);
        }, onError: (e) {
          print(e);
        }));
      } else {
        /// Load More
        QuerySnapshot snapshot = await _donationsDB
            .where(kRequestedCharities, arrayContains: _uid)
            .orderBy(kStatus)
            .orderBy(kCreatedAt, descending: true)
            .startAfterDocument(donations.startDocument)
            .limit(Donations.LoadLimit)
            .get();

        List<QueryDocumentSnapshot> docs = snapshot.docs;
        if (docs.isNotEmpty) {
          donations.endDocument = docs.first;
          donations.startDocument = docs.last;
          Stream<QuerySnapshot> snapshots = _donationsDB
              .where(kRequestedCharities, arrayContains: _uid)
              .orderBy(kStatus, descending: true)
              .orderBy(kCreatedAt)
              .startAtDocument(donations.startDocument)
              .endAtDocument(donations.endDocument)
              .snapshots();
          donations.addStream(snapshots.listen((snapshot) {
            _loadCharityDonations(snapshot, donations, onData);
          }, onError: (e) {
            print(e);
          }));
        } else {
          onData();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _loadCharityDonations(
    QuerySnapshot snapshot,
    Donations donations,
    Function onData,
  ) async {
    try {
      await Future.wait(snapshot.docChanges.map((docChange) async {
        String donationId = docChange.doc.id;
        if (docChange.type == DocumentChangeType.removed) {
          int currentSize = donations.map.length;
          donations.removeDonation(donationId);
          donations.clearStream();
          Stream<QuerySnapshot> snapshots;
          if (currentSize < Donations.LoadLimit) {
            snapshots = _donationsDB
                .where(kRequestedCharities, arrayContains: _uid)
                .orderBy(kStatus, descending: true)
                .orderBy(kCreatedAt)
                .limit(currentSize)
                .snapshots();
          } else {
            snapshots = _donationsDB
                .where(kRequestedCharities, arrayContains: _uid)
                .orderBy(kStatus, descending: true)
                .orderBy(kCreatedAt)
                .startAtDocument(donations.startDocument)
                .snapshots();
          }
          donations.addStream(snapshots.listen((snapshot) {
            _loadCharityDonations(snapshot, donations, onData);
          }, onError: (e) {
            print(e);
          }));
        } else {
          Map<String, dynamic> data = docChange.doc.data();
          Donation donation = Donation(donationId);
          donation.status = Status.declined();
          if (data[kRequestedCharities].last == _uid) {
            donation.status = Status(
              data[kStatus],
              data[kSubStatus],
              isCharity: true,
            );
          }
          Timestamp timeStamp = data[kCreatedAt] ?? Timestamp.now();
          donation.createdAt = timeStamp.toDate();
          donation.needCollected = data[kNeedCollected];
          for (Map<String, dynamic> produce in data[kProduce]) {
            ProduceItem produceItem = ProduceItem(produce[kProduceId]);
            if (donation.needCollected) {
              produceItem.amount = produce[kAmount];
            }
            donation.pickProduce(produceItem);
          }
          donation.setContactInfo(
            street: data[kAddress][kAddressStreet],
            city: data[kAddress][kAddressCity],
            state: data[kAddress][kAddressState],
            zip: data[kAddress][kAddressZip],
            country: data[kPhone][kPhoneCountry],
            dialCode: data[kPhone][kPhoneDialCode],
            phoneNumber: data[kPhone][kPhoneNumber],
          );
          donation.donorId = data[kDonor][kUserId];
          donation.donorName = data[kDonor][kUserName];
          donations.pickDonation(donation);
        }
      }));
      onData();
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkDonationAvailability(
    Donation donation,
    Produce produce, {
    Function(bool removed) notify,
  }) async {
    try {
      Query query = _produceDB.where(kProduceEnabled, isEqualTo: true);
      produce.addStream(query.snapshots().listen((snapshot) {
        bool removed = false;
        Set<String> enabledProduceId = snapshot.docs.map((snapshot) {
          return snapshot.id;
        }).toSet();
        for (String produceId in donation.produce.keys.toList()) {
          if (!enabledProduceId.contains(produceId)) {
            donation.removeProduce(produceId);
            removed = true;
          }
        }
        notify(removed);
      }));
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkWishListAvailability(
    WishList wishList,
    Produce produce, {
    Function(bool removed) notify,
  }) async {
    try {
      Query query = _produceDB.where(kProduceEnabled, isEqualTo: true);
      produce.addStream(query.snapshots().listen((snapshot) {
        bool removed = false;
        Set<String> enabledProduceId = snapshot.docs.map((snapshot) {
          return snapshot.id;
        }).toSet();
        for (String produceId in wishList.produceIds.toList()) {
          if (!enabledProduceId.contains(produceId)) {
            wishList.removeProduce(produceId);
            removed = true;
          }
        }
        notify(removed);
      }));
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> getAllProduceId() async {
    try {
      Query query = _produceDB.where(kProduceEnabled, isEqualTo: true);
      return (await query.get()).docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> imageURL(String path) async {
    try {
      return await storage.refFromURL(path).getDownloadURL();
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
      List<List<String>> lists = Utils.decompose(selectedProduce, 10);
      Map<String, Charity> charityMap = {};
      await Future.wait(lists.map((selectedProduceList) async {
        QuerySnapshot snapshot = await _usersDB
            .where(kWishList, arrayContainsAny: selectedProduceList)
            .get();
        for (DocumentSnapshot doc in snapshot.docs) {
          if (!charityMap.containsKey(doc.id)) {
            Map<String, dynamic> data = doc.data();
            Charity charity = Charity(doc.id);
            charity.name = data[kCharityName];
            charity.address = data[kAddress];
            charity.wishList = data[kWishList];
            charityMap[charity.id] = charity;
          }
        }
      }));
      charities = charityMap.values.toList();

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
          charities[i].score = matchScore + distanceScore;
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

  Future<void> storeDeviceToken(String token) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _usersDB.doc(_uid).update({
        kDeviceTokens: FieldValue.arrayUnion([token]),
      });
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

  Future<void> addDonation(
    Account account,
    Donation donation,
  ) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      List<Charity> charities = donation.charities;
      await _donationsDB.add({
        kDonor: {
          kUserId: _uid,
          kUserName: '${account.firstName} ${account.lastName}',
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
        kAddress: donation.address,
        kPhone: donation.phone,
        kSelectedCharities: donation.charities.map((charity) {
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

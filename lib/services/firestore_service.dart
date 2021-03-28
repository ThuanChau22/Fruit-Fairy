import 'dart:async';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreService {
  /// Database fields

  /// donations
  static const String kCharities = 'charities';
  static const String kCharityId = 'charityId';
  static const String kDonorId = 'donorId';
  static const String kDonorName = 'donorName';
  static const String kFruit = 'fruit';
  static const String kAmount = 'amount';
  static const String kStatus = 'status';

  /// produce
  static const String kProduce = 'produce';
  static const String kFruitName = 'name';
  static const String kFruitPath = 'path';
  static const String kFruitURL = 'url';

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

  StreamSubscription<DocumentSnapshot> userStream(
    Function(Map<String, dynamic>) onData,
  ) {
    return _usersDB.doc(_uid).snapshots().listen(
      (snapshot) {
        onData(snapshot.data());
      },
      onError: (e) {
        print(e);
      },
    );
  }

  StreamSubscription<QuerySnapshot> produceStream(
    Function(Map<String, dynamic>) onData,
  ) {
    return _produceDB.snapshots().listen(
      (snapshot) async {
        Map<String, dynamic> snapshotData = {};
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data();
          snapshotData[doc.id] = {
            kFruitName: data[FireStoreService.kFruitName],
            kFruitPath: data[FireStoreService.kFruitPath],
            kFruitURL: await imageURL(data[FireStoreService.kFruitPath]),
          };
        }
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

  Future<void> addAccount({
    @required String email,
    String firstName,
    String lastName,
    String ein,
    String charityName,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      Map<String, dynamic> data = {};
      data[kEmail] = email;
      if (firstName != null && lastName != null) {
        data[kFirstName] = firstName;
        data[kLastName] = lastName;
      }
      if (ein != null && charityName != null) {
        data[kEIN] = ein;
        data[kCharityName] = charityName;
      }
      await _usersDB.doc(_uid).set(data);
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateUserName({
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

  void uid(String uid) {
    this._uid = uid;
  }

  void clear() {
    _uid = null;
  }
}

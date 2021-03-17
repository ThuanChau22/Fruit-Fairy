import 'dart:async';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:fruitfairy/models/fruit.dart';

class FireStoreService {
  /// Database fields

  /// donors
  static const String kDonors = 'donors';
  static const String kEmail = 'email';
  static const String kFirstName = 'firstname';
  static const String kLastName = 'lastname';
  static const String kPhone = 'phone';
  static const String kPhoneNumber = 'number';
  static const String kPhoneCountry = 'country';
  static const String kPhoneDialCode = 'dialCode';
  static const String kAddress = 'address';
  static const String kAddressStreet = 'street';
  static const String kAddressCity = 'city';
  static const String kAddressState = 'state';
  static const String kAddressZip = 'zip';

  /// fruits
  static const String kFruits = 'fruits';
  static const String kFruitName = 'name';
  static const String kFruitPath = 'path';

  ///////////////

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _storagePath = 'gs://fruit-fairy.appspot.com';

  CollectionReference _donorsDB;
  CollectionReference _fruitsDB;

  String _uid;

  FireStoreService() {
    _donorsDB = _firestore.collection(kDonors);
    _fruitsDB = _firestore.collection(kFruits);
  }

  StreamSubscription<DocumentSnapshot> donorStream(
    Function(Map<String, dynamic>) onData,
  ) {
    return _donorsDB.doc(_uid).snapshots().listen(
      (snapshot) {
        onData(snapshot.data());
      },
      onError: (e) {
        print(e);
      },
    );
  }

  StreamSubscription<QuerySnapshot> fruitsStream(
    Function(Map<String, Fruit>) onData,
  ) {
    return _fruitsDB.snapshots().listen(
      (snapshot) async {
        Map<String, Fruit> fruits = {};
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          String id = doc.id;
          Map<String, dynamic> data = doc.data();
          String fruitName = data[FireStoreService.kFruitName];
          String imagePath = data[FireStoreService.kFruitPath];
          fruits[id] = Fruit(
            id: id,
            name: fruitName,
            imagePath: imagePath,
            imageURL: await imageURL(imagePath),
          );
        }
        onData(fruits);
      },
      onError: (e) {
        print(e);
      },
    );
  }

  Future<String> imageURL(String fullPath) async {
    if (fullPath.indexOf(_storagePath) >= 0) {
      String directory = fullPath.substring(_storagePath.length);
      return await _storage.ref(directory).getDownloadURL();
    }
    return '';
  }

  Future<void> addAccount({
    @required String email,
    @required String firstName,
    @required String lastName,
  }) async {
    if (_uid == null) {
      print('UID Unset');
      return;
    }
    try {
      await _donorsDB.doc(_uid).set({
        kEmail: email,
        kFirstName: firstName,
        kLastName: lastName,
      });
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
      await _donorsDB.doc(_uid).update({
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
      DocumentReference doc = _donorsDB.doc(_uid);
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
      DocumentReference doc = _donorsDB.doc(_uid);
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
      await _donorsDB.doc(_uid).delete();
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

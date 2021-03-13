import 'dart:async';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  /// Database fields

  /// fruits
  static const String kFruits = 'fruits';
  static const String kFruitName = 'name';
  static const String kFruitPath = 'path';
  static const String kFruitURL = 'url';

  /// users
  static const String kUsers = 'users';
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

  ///////////////

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _usersDB;
  CollectionReference _fruitsDB;

  String _uid;

  FireStoreService() {
    _usersDB = _firestore.collection(kUsers);
    _fruitsDB = _firestore.collection(kFruits);
  }

  void uid(String uid) {
    this._uid = uid;
  }

  StreamSubscription<DocumentSnapshot> userStream(
    Function(DocumentSnapshot) onData,
  ) {
    return _usersDB.doc(_uid).snapshots().listen(
      onData,
      onError: (e) {
        print(e);
      },
    );
  }

  Future<List<QueryDocumentSnapshot>> fruits() async {
    return (await _fruitsDB.get()).docs;
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
      await _usersDB.doc(_uid).set({
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

  void clear() {
    _uid = null;
  }
}

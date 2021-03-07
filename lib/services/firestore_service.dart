import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fruitfairy/constant.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId;

  FireStoreService();

  Future<Map<String, dynamic>> get userData async {
    CollectionReference userDB = _firestore.collection(kDBUsers);
    return (await userDB.doc(userId).get()).data();
  }

  void setUID(String uid) {
    this.userId = uid;
  }

  Future<void> addAccount({
    @required String email,
    @required String firstName,
    @required String lastName,
  }) async {
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      await _firestore.collection(kDBUsers).doc(userId).set({
        kDBEmail: email,
        kDBFirstName: firstName,
        kDBLastName: lastName,
      });
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> updateUserName({
    @required String firstName,
    @required String lastName,
  }) async {
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      await _firestore.collection(kDBUsers).doc(userId).update({
        kDBFirstName: firstName,
        kDBLastName: lastName,
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _firestore.collection(kDBUsers).doc(userId);
      if (street.isEmpty && city.isEmpty && state.isEmpty && zip.isEmpty) {
        await doc.update({
          kDBAddress: FieldValue.delete(),
        });
      } else {
        await doc.update({
          kDBAddress: {
            kDBAddressStreet: street,
            kDBAddressCity: city,
            kDBAddressState: state,
            kDBAddressZip: zip,
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _firestore.collection(kDBUsers).doc(userId);
      if (phoneNumber.isEmpty) {
        await doc.update({
          kDBPhone: FieldValue.delete(),
        });
      } else {
        await doc.update({
          kDBPhone: {
            kDBPhoneCountry: country,
            kDBPhoneDialCode: dialCode,
            kDBPhoneNumber: phoneNumber,
          },
        });
      }
    } catch (e) {
      throw e.message;
    }
  }

  Future<void> deleteAccount() async {
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      await _firestore.collection(kDBUsers).doc(userId).delete();
    } catch (e) {
      throw e.message;
    }
  }
}

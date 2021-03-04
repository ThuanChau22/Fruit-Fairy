import 'package:fruitfairy/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId;

  FireStoreService();

  Future<Map<String, dynamic>> get userData async {
    CollectionReference userDB = _firestore.collection(kDBUsers);
    return (await userDB.doc(userId).get()).data();
  }

  void uid(String uid) {
    this.userId = uid;
  }

  Future<void> addAccount({
    String email,
    String firstName,
    String lastName,
  }) async {
    if (userId != null) {
      try {
        await _firestore.collection(kDBUsers).doc(userId).set({
          kDBEmail: email,
          kDBFirstName: firstName,
          kDBLastName: lastName,
        });
      } catch (e) {
        throw e.message;
      }
    } else {
      print('UID Unset');
    }
  }

  Future<void> updateUserName({
    String firstName,
    String lastName,
  }) async {
    if (userId != null) {
      try {
        await _firestore.collection(kDBUsers).doc(userId).update({
          kDBFirstName: firstName,
          kDBLastName: lastName,
        });
      } catch (e) {
        throw e.message;
      }
    } else {
      print('UID Unset');
    }
  }

  Future<void> updateUserAddress({
    String street,
    String city,
    String state,
    String zip,
  }) async {
    if (userId != null) {
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
    } else {
      print('UID Unset');
    }
  }

  Future<void> updatePhoneNumber({
    String country,
    String dialCode,
    String phoneNumber,
  }) async {
    if (userId != null) {
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
    } else {
      print('UID Unset');
    }
  }

  Future<void> deleteAccount() async {
    if (userId != null) {
      try {
        await _firestore.collection(kDBUsers).doc(userId).delete();
      } catch (e) {
        throw e.message;
      }
    } else {
      print('UID Unset');
    }
  }
}

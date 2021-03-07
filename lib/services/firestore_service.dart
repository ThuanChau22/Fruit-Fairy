import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  /// Database fields
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId;

  FireStoreService();

  Future<Map<String, dynamic>> get userData async {
    CollectionReference userDB = _firestore.collection(kUsers);
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
      await _firestore.collection(kUsers).doc(userId).set({
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      await _firestore.collection(kUsers).doc(userId).update({
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _firestore.collection(kUsers).doc(userId);
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      DocumentReference doc = _firestore.collection(kUsers).doc(userId);
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
    if (userId == null) {
      print('UID Unset');
      return;
    }
    try {
      await _firestore.collection(kUsers).doc(userId).delete();
    } catch (e) {
      throw e.message;
    }
  }
}

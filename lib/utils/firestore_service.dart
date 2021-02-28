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

  Future<void> addUser({
    String email,
    String firstName,
    String lastName,
  }) async {
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
    String firstName,
    String lastName,
  }) async {
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
    String street,
    String city,
    String state,
    String zip,
  }) async {
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
}

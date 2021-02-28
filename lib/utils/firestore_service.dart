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
}

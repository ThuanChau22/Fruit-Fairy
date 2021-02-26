import 'package:fruitfairy/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId;

  FireStoreService();

  set uid(String uid) {
    this.userId = uid;
  }

  Future<Map<String, dynamic>> getUserData() async {
    CollectionReference userDB = _firestore.collection(kDBUsers);
    return (await userDB.doc(userId).get()).data();
  }
}

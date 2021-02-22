import 'package:fruitfairy/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreService {
  static final CollectionReference userDB =
      FirebaseFirestore.instance.collection(kDBUserCollection);

  static Future<Map<String, dynamic>> getUserData(String uid) async {
    return (await userDB.doc(uid).get()).data();
  }
}

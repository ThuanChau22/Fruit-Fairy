import 'package:fruitfairy/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final CollectionReference userDB =
      FirebaseFirestore.instance.collection(kDBUserCollection);

  AuthService(this._firebaseAuth);

  User currentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> signUp({
    String email,
    String password,
    String firstName,
    String lastName,
  }) async {
    UserCredential newUser;
    try {
      newUser = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (newUser != null) {
        await _firebaseAuth.currentUser.sendEmailVerification();
        await userDB.doc(_firebaseAuth.currentUser.uid).set({
          kDBEmailField: email,
          kDBFirstNameField: firstName,
          kDBLastNameField: lastName,
        });
      }
    } catch (e) {
      throw e.message;
    }
    return newUser;
  }

  Future<bool> signIn({
    String email,
    String password,
  }) async {
    UserCredential user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        if (_firebaseAuth.currentUser.emailVerified) {
          return true;
        } else {
          await _firebaseAuth.currentUser.sendEmailVerification();
          return false;
        }
      }
    } catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Please check your email or sign in again shortly';
      }
      if (e.code == 'user-disabled') {
        throw 'Your account has been disabled';
      } else {
        throw 'Incorrect Email or Password. Please try again!';
      }
    }
    return false;
  }

  void resetPassword({String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

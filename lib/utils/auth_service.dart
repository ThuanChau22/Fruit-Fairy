import 'package:flutter/material.dart';
import 'package:fruitfairy/constant.dart';
import 'package:fruitfairy/widgets/confirm_code_dialog.dart';
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

  String currentUserUID() {
    return _firebaseAuth.currentUser.uid;
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
    try {
      UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
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

  // Android: set SHA-1, SHA-256, enable SafetyNet from Google Cloud Console
  // IOS: ???
  Future<void> signInWithPhone({
    String phoneNumber,
    BuildContext context,
    Function completed,
    Function failed,
    Function codeSent,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          UserCredential user =
              await _firebaseAuth.signInWithCredential(credential);
          if (user != null) {
            if (_firebaseAuth.currentUser.email == null) {
              _firebaseAuth.currentUser.delete();
              completed('Not register');
            } else {
              completed('');
            }
          }
        } catch (e) {
          print(e);
        }
      },
      codeSent: (String verificationId, int resendToken) {
        ConfirmCodeDialog(
          scaffoldContext: context,
          onSubmit: (confirmCode) async {
            try {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: confirmCode,
              );
              UserCredential user =
                  await _firebaseAuth.signInWithCredential(credential);
              if (user != null) {
                codeSent('');
              } else {
                codeSent('(2)');
              }
            } catch (e) {
              if (e.code == 'invalid-verification-code') {
                codeSent('Invalid confirmation code. Please try again!');
              }
              print(e);
            }
          },
        ).show();
      },
      verificationFailed: (FirebaseAuthException e) {
        //TODO: too many request on phone auth
        if (e.code == 'too-many-requests') {
          failed(e.message);
        }
        print(e);
      },
      timeout: Duration(seconds: 10),
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Timeout');
      },
    );
  }

  Future<void> resetPassword({String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

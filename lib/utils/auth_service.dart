import 'package:fruitfairy/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService();

  User get user {
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
    Function completed,
    Function failed,
    Function codeSent,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      timeout: Duration(seconds: 5),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          if (await _firebaseAuth.signInWithCredential(credential) != null) {
            if (_firebaseAuth.currentUser.email != null) {
              completed('');
            } else {
              await _firebaseAuth.currentUser.delete();
              // TODO: Ask user to register first
              completed('Register first');
            }
          }
        } catch (e) {
          print(e);
        }
      },
      codeSent: (String verificationId, int resendToken) {
        codeSent((smsCode) async {
          try {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            if (await _firebaseAuth.signInWithCredential(credential) != null) {
              if (_firebaseAuth.currentUser.email != null) {
                return '';
              } else {
                await _firebaseAuth.currentUser.delete();
                // TODO: Ask user to register first
                return 'Register first';
              }
            }
          } catch (e) {
            if (e.code == 'invalid-verification-code') {
              return 'Invalid verification code. Please try again!';
            }
            if (e.code == 'session-expired') {
              return 'Verification code has expired. Please re-send to try again!';
            }
            print(e);
          }
          return 'Error';
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        //TODO: too many request on phone auth
        if (e.code == 'too-many-requests') {
          failed(e.message);
        }
        print(e);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Timeout');
      },
    );
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

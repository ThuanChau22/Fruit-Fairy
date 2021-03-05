import 'package:firebase_auth/firebase_auth.dart';

import 'package:fruitfairy/utils/firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService();

  User get user {
    return _firebaseAuth.currentUser;
  }

  Future<String> signUp({
    String email,
    String password,
    String firstName,
    String lastName,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FireStoreService fireStoreService = FireStoreService();
      fireStoreService.uid(user.uid);
      await fireStoreService.addAccount(
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
      await user.sendEmailVerification();
    } catch (e) {
      throw e.message;
    }
    return 'Please check your email for a verification link!';
  }

  Future<String> signIn({
    String email,
    String password,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential != null) {
        if (user.emailVerified) {
          return '';
        } else {
          await user.sendEmailVerification();
          return 'Please check your email for a verification link!';
        }
      }
    } catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Please wait a moment and sign in again shortly!';
      }
      if (e.code == 'user-disabled') {
        throw 'Your account has been disabled';
      } else {
        throw 'Incorrect Email or Password. Please try again!';
      }
    }
    return 'Error';
  }

  // Android: set SHA-1, SHA-256, enable SafetyNet from Google Cloud Console
  // IOS: ???
  Future<String> signInWithPhone({
    String phoneNumber,
    Function completed,
    Function(Future<String> Function(String smsCode) verifyCode) codeSent,
    Function(String errorMessage) failed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      timeout: Duration(seconds: 5),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          if (await _firebaseAuth.signInWithCredential(credential) != null) {
            if (user.email != null) {
              completed('');
            } else {
              await user.delete();
              completed('Phone number not linked with registered email');
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
              if (user.email != null) {
                return '';
              } else {
                await user.delete();
                return 'Phone number not linked with registered email';
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
        if (e.code == 'too-many-requests') {
          failed(
              'We have blocked all requests from this phone number due to numerous attempts');
        }
        print(e);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return 'Verification code sent';
  }

  Future<String> registerPhone({
    String phoneNumber,
    bool update = false,
    Function(Future<String> Function(String smsCode) verifyCode) codeSent,
    Function(String errorMessage) failed,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      timeout: Duration(seconds: 5),
      phoneNumber: phoneNumber,
      codeSent: (String verificationId, int resendToken) {
        codeSent((smsCode) async {
          try {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );
            if (update) {
              await user.updatePhoneNumber(credential);
            } else {
              await user.linkWithCredential(credential);
            }
          } catch (e) {
            if (e.code == 'invalid-verification-code' ||
                e.code == 'invalid-verification-id') {
              return 'Invalid verification code. Please try again!';
            }
            if (e.code == 'session-expired') {
              return 'Verification code has expired. Please re-send to try again!';
            }
            if (e.code == 'credential-already-in-use') {
              return 'Phone number is being used by a different account';
            }
            print(e);
          }
          return '';
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'too-many-requests') {
          failed(
              'We have blocked all requests from this phone number due to numerous attempts');
        }
        print(e);
      },
      verificationCompleted: (PhoneAuthCredential credential) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return 'Verification code sent';
  }

  Future<bool> removePhone() async {
    for (UserInfo userInfo in user.providerData) {
      if (userInfo.providerId == PhoneAuthProvider.PROVIDER_ID) {
        await user.unlink(PhoneAuthProvider.PROVIDER_ID);
        return true;
      }
    }
    return false;
  }

  Future<void> updatePassword({
    String email,
    String oldPassword,
    String newPassword,
  }) async {
    try {
      EmailAuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Incorrect current password. Please try again!';
      }
      print(e);
    }
  }

  Future<String> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
    return 'Reset password email sent';
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount({
    String email,
    String password,
  }) async {
    try {
      EmailAuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      FireStoreService fireStoreService = FireStoreService();
      fireStoreService.uid(user.uid);
      await fireStoreService.deleteAccount();
      await user.delete();
    } catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Incorrect password!';
      }
    }
  }
}

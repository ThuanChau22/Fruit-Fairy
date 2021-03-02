import 'package:firebase_auth/firebase_auth.dart';

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
        await user.sendEmailVerification();
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
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential != null) {
        if (user.emailVerified) {
          return true;
        } else {
          await user.sendEmailVerification();
          return false;
        }
      }
    } catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Please wait a moment and sign in again shortly';
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
    Function codeSent,
    Function failed,
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
              if (user.email != null) {
                return '';
              } else {
                await user.delete();
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
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> registerPhone({
    String phoneNumber,
    bool update = false,
    Function codeSent,
    Function failed,
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
              //TODO: Tell user phone number is used by other
              return 'Phone Number is being used by another account';
            }
            print(e);
          }
          return '';
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        //TODO: too many request on phone auth
        if (e.code == 'too-many-requests') {
          failed(e.message);
        }
        print(e);
      },
      verificationCompleted: (PhoneAuthCredential credential) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
        throw 'Incorrect Current Password. Please try again!';
      }
      print(e);
    }
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
//
import 'package:fruitfairy/services/firestore_service.dart';

/// A wrapper class for Firebase Authentication service
/// that handles all Auth related operations
class FireAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Return information of current user
  User get user {
    return _firebaseAuth.currentUser;
  }

  /// Sign user up as a Donor
  Future<String> signUpDonor({
    @required String email,
    @required String password,
    @required String firstName,
    @required String lastName,
  }) async {
    try {
      // Create a user account on Firebase Authentication
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a document in users collection on Firestore
      FireStoreService fireStoreService = FireStoreService();
      fireStoreService.uid(user.uid);
      await fireStoreService.addDonorAccount(
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      //Send verification link to registered email
      await user.sendEmailVerification();
      return 'Please check your email for a verification link!';
    } catch (e) {
      throw e.message;
    }
  }

  /// Sign user up as a Charity
  Future<String> signUpCharity({
    @required String email,
    @required String password,
    @required String ein,
    @required String charityName,
    @required String street,
    @required String city,
    @required String state,
    @required String zip,
  }) async {
    try {
      // Create a user account on Firebase Authentication
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a document in users collection on Firestore
      FireStoreService fireStoreService = FireStoreService();
      fireStoreService.uid(user.uid);
      await fireStoreService.addCharityAccount(
        email: email,
        ein: ein,
        charityName: charityName,
        street: street,
        city: city,
        state: state,
        zip: zip,
      );

      //Send verification link to registered email
      await user.sendEmailVerification();
      return 'Please check your email for a verification link!';
    } catch (e) {
      throw e.message;
    }
  }

  /// Sign in a user with Email/Password
  /// Throw error if user inputs incorrect combination
  /// of email or password, or makes several unsuccessfull
  /// requests in a short amount of time, or the account
  /// has been disabled
  Future<String> signIn({
    @required String email,
    @required String password,
  }) async {
    try {
      // Sign in with given email and password
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification status of current account,
      // if not yet verified, send a verification link to
      // registered email and return instruction to user
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        return 'Please check your email for a verification link!';
      }
      return '';
    } catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Please wait a moment and sign in again shortly!';
      }
      if (e.code == 'user-disabled') {
        throw 'Your account has been disabled';
      }
      throw 'Incorrect Email or Password. Please try again!';
    }
  }

  /// Sign in a user with phone number
  /// Setup steps:
  /// Android: set SHA-1, SHA-256, enable SafetyNet from Google Cloud Console
  /// IOS: ???
  Future<String> signInWithPhone({
    @required String phoneNumber,
    @required
        Function(Future<String> Function(String smsCode) verifyCode) codeSent,
    @required Function(Future<String> Function() result) completed,
    @required Function(Future<String> Function() errorMessage) failed,
  }) async {
    // Initialize with Firebase Auth's function
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      // Send sms code to user and wait for user's input to sign in
      codeSent: (String verificationId, int resendToken) {
        // Pass a callback to handle user sign in
        // after already retrieved sms code from user
        // Throw error if sms code is incorrect or session expired
        codeSent((smsCode) async {
          try {
            // Get phone credential with given verification id and sms code from user
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            // Attempt to sign the user in and check whether
            // the account is linked with an email
            await _firebaseAuth.signInWithCredential(credential);
            if (user.email == null) {
              // Remove newly created account
              await user.delete();
              return 'Phone number not linked with registered email';
            }
            return '';
          } catch (e) {
            if (e.code == 'invalid-verification-code') {
              return 'Invalid verification code. Please try again!';
            }
            if (e.code == 'session-expired') {
              return 'Verification code has expired. Please re-send to try again!';
            }
            print(e);
            return 'Error';
          }
        });
      },
      // Sign user in as soon as sms code arrived without user's input
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Pass a callback to handle user sign in
        // as soon as sms code arrived
        completed(() async {
          try {
            // Attempt to sign the user in and check whether
            // the account is linked with an email
            await _firebaseAuth.signInWithCredential(credential);
            if (user.email == null) {
              // Remove newly created account
              await user.delete();
              return 'Phone number not linked with registered email';
            }
            return '';
          } catch (e) {
            print(e);
            return 'Error';
          }
        });
      },
      // Failed to sign user in and return error message
      verificationFailed: (FirebaseAuthException e) {
        // Pass a callback to return error message
        failed(() async {
          if (e.code == 'too-many-requests') {
            return 'We have blocked all requests from this phone number due to numerous attempts';
          }
          print(e);
          return 'Error';
        });
      },
      // Unhandle method
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    // A message that notifies user to expect sms code sent
    return 'Sending verification code';
  }

  /// Create a phone credential and link it
  /// with current user account
  Future<String> registerPhone({
    @required String phoneNumber,
    @required
        Function(Future<String> Function(String smsCode) verifyCode) codeSent,
    @required Function(Future<String> Function() result) completed,
    @required Function(Future<String> Function() errorMessage) failed,
  }) async {
    // Initialize with Firebase Auth's function
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      // Send sms code to user and wait for user's input to proceed
      codeSent: (String verificationId, int resendToken) {
        // Pass a callback to link phone number
        // after already retrieved sms code from user
        // Throw error if sms code is incorrect or session expired
        // or phone number is already used on a different user account
        codeSent((smsCode) async {
          try {
            // Get phone credential with given verification id and sms code from user
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            // Update current phone number
            // if user previously had one linked
            for (UserInfo userInfo in user.providerData) {
              if (userInfo.providerId == PhoneAuthProvider.PROVIDER_ID) {
                await user.updatePhoneNumber(credential);
                return '';
              }
            }

            // Link a new phone number to user account
            await user.linkWithCredential(credential);
            return '';
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
            return 'Error';
          }
        });
      },
      // Link phone number as soon as sms code arrived without user's input
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Pass a callback to link phone number
        // as soon as sms code arrived
        // Throw error if phone number is already used
        // on a different user account
        completed(() async {
          try {
            // Update current phone number
            // if user previously had one linked
            for (UserInfo userInfo in user.providerData) {
              if (userInfo.providerId == PhoneAuthProvider.PROVIDER_ID) {
                await user.updatePhoneNumber(credential);
                return '';
              }
            }

            // Link a new phone number to user account
            await user.linkWithCredential(credential);
            return '';
          } catch (e) {
            if (e.code == 'credential-already-in-use') {
              return 'Phone number is being used by a different account';
            }
            print(e);
            return 'Error';
          }
        });
      },
      // Failed to link phone number and return error message
      verificationFailed: (FirebaseAuthException e) {
        // Pass a callback to return error message
        failed(() async {
          if (e.code == 'too-many-requests') {
            return 'We have blocked all requests from this phone number due to numerous attempts';
          }
          print(e);
          return 'Error';
        });
      },
      // Unhandle method
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    // A message that notifies user to expect sms code sent
    return 'Sending verification code';
  }

  /// Remove phone number from a user account
  /// Throw error if the user updated phone number
  /// on the same account on different devices
  Future<void> removePhone() async {
    try {
      // Remove credential with phone number
      await user.unlink(PhoneAuthProvider.PROVIDER_ID);
    } catch (e) {
      throw 'Your phone number has been updated, please sign in again!';
    }
  }

  /// Update account password
  /// Throw error if user re-authentication failed
  Future<void> updatePassword({
    @required String email,
    @required String oldPassword,
    @required String newPassword,
  }) async {
    try {
      // Re-authenticate user to verified user's action
      EmailAuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update account with new password provided by the user
      await user.updatePassword(newPassword);
    } catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Incorrect current password. Please try again!';
      }
      print(e);
    }
  }

  /// Send a password-reset link to registered email
  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Reset password email sent';
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print(e);
    }
  }

  /// Completely remove user from Firebase
  /// Throw error if user re-authentication failed
  Future<void> deleteAccount({
    @required String email,
    @required String password,
  }) async {
    try {
      // Re-authenticate user to verified user's action
      EmailAuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Remove user information on Firestore
      FireStoreService fireStoreService = FireStoreService();
      fireStoreService.uid(user.uid);
      await fireStoreService.deleteAccount();

      // Remove user from Authentication
      await user.delete();
    } catch (e) {
      if (e.code == 'wrong-password') {
        throw 'Incorrect password!';
      }
    }
  }
}

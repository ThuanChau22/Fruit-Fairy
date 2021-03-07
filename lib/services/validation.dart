import 'package:meta/meta.dart';

import 'package:phone_number/phone_number.dart';

/// A class that provides methods for client validations
class Validate {
  static final passwordLength = 8;
  static final maxNameLength = 20;

  /// Private constructor to prevent instantiation
  Validate._();

  /// Validate name
  /// Return empty String on correct [name]
  static String name({
    @required String name,
    @required String label,
  }) {
    if (name.isEmpty) {
      return 'Please enter $label\n';
    }
    if (name.length > maxNameLength) {
      return 'Only $maxNameLength characters allowed\n';
    }
    return '';
  }

  /// Validate email on signup
  /// Return empty String on correct [email]
  static String email(String email) {
    if (email.isEmpty) {
      return 'Please enter email\n';
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return 'Invalid email address\n';
    }
    return '';
  }

  /// Validate password on signup
  /// Return empty String on correct [password]
  static String password(String password) {
    if (password.isEmpty) {
      return 'Please enter password\n';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Requires at least one uppercase\n';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Requires at least one lowercase\n';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Requires at least one number\n';
    }
    if (password.length < passwordLength) {
      return 'Requires at least $passwordLength characters\n';
    }
    return '';
  }

  /// Validate confirm password
  /// Return empty String on correct [confirmPassword]
  static String confirmPassword({
    @required String password,
    @required String confirmPassword,
  }) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password\n';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match\n';
    }
    return '';
  }

  /// Validate phone number
  /// Return empty String on correct [phoneNumber] and [isoCode]
  static Future<String> phoneNumber({
    @required String phoneNumber,
    @required String isoCode,
  }) async {
    try {
      bool isValid = await PhoneNumberUtil().validate(phoneNumber, isoCode);
      return !isValid ? 'Please enter a valid phone number\n' : '';
    } catch (e) {
      return 'Please enter a valid phone number\n';
    }
  }

  /// Validate zip code
  /// Return empty String on correct [zipCode]
  static String zipCode(String zipCode) {
    if (zipCode.isEmpty) {
      return 'Please enter zip code\n';
    }
    if (!RegExp(r'^\d{5}$').hasMatch(zipCode)) {
      return 'Invalid zip code\n';
    }
    return '';
  }

  /// Simple check email on signin
  /// Return empty String on correct [email]
  static String checkEmail(String email) {
    return email.isEmpty ? 'Please enter email\n' : '';
  }

  /// Simple check password on signin
  /// Return empty String on correct [password]
  static String checkPassword(String password) {
    return password.isEmpty ? 'Please enter password\n' : '';
  }

  /// Simple check confirmation code on verifying
  /// Return empty String on correct [confirmationCode]
  static String checkConfirmCode(String confirmationCode) {
    return confirmationCode.isEmpty ? 'Please enter verification code\n' : '';
  }

  /// Simple check confirmation code on verifying
  /// Return empty String on correct [street]
  static String checkStreet(String street) {
    return street.isEmpty ? 'Please enter street\n' : '';
  }

  /// Simple check confirmation code on verifying
  /// Return empty String on correct [city]
  static String checkCity(String city) {
    return city.isEmpty ? 'Please enter city\n' : '';
  }

  /// Simple check confirmation code on verifying
  /// Return empty String on correct [state]
  static String checkState(String state) {
    return state.isEmpty ? 'Please enter state\n' : '';
  }
}

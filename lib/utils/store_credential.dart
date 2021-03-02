import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreCredential {
  static const String email = 'email';
  static const String password = 'password';
  static const String phone = 'phone';
  static const String isoCode = 'isoCode';
  static const String dialCode = 'dialCode';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  StoreCredential._();

  static Future<void> store({
    String email,
    String password,
    String phoneNumber,
    String isoCode,
    String dialCode,
  }) async {
    try {
      await _storage.write(
        key: StoreCredential.email,
        value: email,
      );
      await _storage.write(
        key: StoreCredential.password,
        value: password,
      );
      await _storage.write(
        key: StoreCredential.phone,
        value: phoneNumber,
      );
      await _storage.write(
        key: StoreCredential.isoCode,
        value: isoCode,
      );
      await _storage.write(
        key: StoreCredential.dialCode,
        value: dialCode,
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> detele() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> get() async {
    return await _storage.readAll();
  }
}

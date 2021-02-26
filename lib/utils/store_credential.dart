import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreCredential {
  static final String email = 'email';
  static final String password = 'password';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  StoreCredential._();

  static Future<void> store({String email, String password}) async {
    try {
      await _storage.write(
        key: StoreCredential.email,
        value: email,
      );
      await _storage.write(
        key: StoreCredential.password,
        value: password,
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

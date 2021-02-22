import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreCredential {
  static final String email = 'email';
  static final String password = 'password';
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  StoreCredential._();

  static void store({String email, String password}) async {
    await _storage.deleteAll();
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

  static Future<Map<String, String>> get() async {
    return await _storage.readAll();
  }
}

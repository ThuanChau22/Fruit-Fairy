import 'package:meta/meta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const String email = 'email';
  static const String password = 'password';
  static const String phone = 'phone';
  static const String isoCode = 'isoCode';
  static const String dialCode = 'dialCode';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  CredentialService._();

  static Future<void> store({
    @required String email,
    @required String password,
    @required String phoneNumber,
    @required String isoCode,
    @required String dialCode,
  }) async {
    try {
      await _storage.write(
        key: CredentialService.email,
        value: email,
      );
      await _storage.write(
        key: CredentialService.password,
        value: password,
      );
      await _storage.write(
        key: CredentialService.phone,
        value: phoneNumber,
      );
      await _storage.write(
        key: CredentialService.isoCode,
        value: isoCode,
      );
      await _storage.write(
        key: CredentialService.dialCode,
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

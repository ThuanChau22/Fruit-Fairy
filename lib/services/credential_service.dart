import 'package:meta/meta.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const String kEmail = 'email';
  static const String kPassword = 'password';
  static const String kPhone = 'phone';
  static const String kIsoCode = 'isoCode';
  static const String kDialCode = 'dialCode';
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
        key: CredentialService.kEmail,
        value: email,
      );
      await _storage.write(
        key: CredentialService.kPassword,
        value: password,
      );
      await _storage.write(
        key: CredentialService.kPhone,
        value: phoneNumber,
      );
      await _storage.write(
        key: CredentialService.kIsoCode,
        value: isoCode,
      );
      await _storage.write(
        key: CredentialService.kDialCode,
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

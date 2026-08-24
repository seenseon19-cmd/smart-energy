import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// مخزن آمن للبيانات الحساسة مثل الجلسات، بيانات المستخدم، والسجلات المحلية.
/// تبقى SharedPreferences مخصصة لإعدادات العرض غير الحساسة فقط.
class SecureStorageService {
  SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<SecureStorageService> get instance async => SecureStorageService._();

  Future<String?> getString(String key) => _storage.read(key: key);
  Future<void> setString(String key, String value) => _storage.write(key: key, value: value);
  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    return value == null ? null : value == 'true';
  }
  Future<void> setBool(String key, bool value) => setString(key, value.toString());
  Future<void> setInt(String key, int value) => setString(key, value.toString());
  Future<void> remove(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();
}

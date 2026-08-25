import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// خدمة المصادقة البيومترية الآمنة مع fallback متوافق مع المنصات الأخرى.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const MethodChannel _channel = MethodChannel('smartenergy/biometric');
  static const String _prefKey = 'biometric_auth_enabled';

  /// نتيجة Android BiometricManager: 0 تعني BIOMETRIC_SUCCESS.
  static Future<int?> canAuthenticate() async {
    if (kIsWeb) return null;
    try {
      return await _channel.invokeMethod<int>('canAuthenticate');
    } on PlatformException catch (e) {
      AppLogger.debug('Native biometric availability check failed: ${e.code}');
      return null;
    } catch (e) {
      AppLogger.debug('Native biometric availability check failed: $e');
      return null;
    }
  }

  static Future<bool> isDeviceSupported() async {
    try {
      final nativeResult = await canAuthenticate();
      if (nativeResult != null) return nativeResult == 0;
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e) {
      AppLogger.debug('Biometric support check failed: $e');
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.debug('Available biometrics check failed: $e');
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate({
    String localizedReason = 'يرجى تأكيد هويتك باستخدام البصمة أو التعرف على الوجه',
  }) async {
    try {
      final nativeResult = await canAuthenticate();
      if (nativeResult != null && nativeResult != 0) return false;
      if (!await isDeviceSupported()) return false;
      final available = await getAvailableBiometrics();
      if (available.isEmpty && nativeResult == null) return false;
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException catch (e) {
      AppLogger.debug('Biometric prompt failed: ${e.code}');
      return false;
    } catch (e) {
      AppLogger.debug('Biometric prompt failed: $e');
      return false;
    }
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKey) ?? false;
    } catch (e) {
      AppLogger.debug('Biometric preference read failed: $e');
      return false;
    }
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}

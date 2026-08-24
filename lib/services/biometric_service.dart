import 'app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// خدمة المصادقة البيومترية — BiometricService
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة:
///   - التحقق من دعم الجهاز للبصمة (Fingerprint) أو التعرف على الوجه (Face ID)
///   - تنفيذ طلب المصادقة البيومترية مع رسائل توجيهية بالعربية
///   - حفظ واسترجاع حالة تفعيل البصمة في SharedPreferences
/// ══════════════════════════════════════════════════════════════════════════════
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _prefKey = 'biometric_auth_enabled';

  /// التحقق مما إذا كان الجهاز يدعم البصمة أو الوجه
  static Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } on PlatformException catch (e) {
      AppLogger.debug('Biometric support check error: $e');
      return false;
    } catch (e) {
      AppLogger.debug('Biometric support check unexpected error: $e');
      return false;
    }
  }

  /// الحصول على قائمة أنواع البصمات المتاحة بالجهاز
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      AppLogger.debug('Error getting available biometrics: $e');
      return [];
    }
  }

  /// تنفيذ المصادقة البيومترية
  static Future<bool> authenticate({
    String localizedReason = 'يرجى تأكيد هويتك باستخدام البصمة للوصول الآمن',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      AppLogger.debug('Biometric authentication PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      AppLogger.debug('Biometric authentication error: $e');
      return false;
    }
  }

  /// هل تم تفعيل البصمة في إعدادات التطبيق
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// تفعيل أو تعطيل البصمة في الإعدادات
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}

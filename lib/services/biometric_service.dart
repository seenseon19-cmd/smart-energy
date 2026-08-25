import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_logger.dart';
import 'secure_storage_service.dart';

enum BiometricAuthResult {
  success,
  unavailable,
  notEnrolled,
  canceled,
  failed,
  lockedOut,
  permanentlyLockedOut,
  platformError,
}

/// خدمة المصادقة البيومترية الحقيقية مع معالجة آمنة لجميع حالات Android.
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();
  static const MethodChannel _channel = MethodChannel('smartenergy/biometric');
  static const String _enabledKey = 'biometric_auth_enabled';
  static const String _uidKey = 'biometric_auth_uid';
  static bool _skipNextStartupPrompt = false;

  static void skipNextStartupPrompt() {
    _skipNextStartupPrompt = true;
  }

  static bool consumeStartupPromptSkip() {
    final value = _skipNextStartupPrompt;
    _skipNextStartupPrompt = false;
    return value;
  }

  /// يعيد قيمة BiometricManager.canAuthenticate على Android.
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

  static Future<BiometricAuthResult> availability() async {
    if (kIsWeb) return BiometricAuthResult.unavailable;
    try {
      final nativeStatus = await canAuthenticate();
      if (nativeStatus != null) {
        if (nativeStatus == 0) return BiometricAuthResult.success;
        // Android: 11 = no hardware, 12 = hardware unavailable,  BIOMETRIC_ERROR_NONE_ENROLLED = 11.
        if (nativeStatus == 11) return BiometricAuthResult.notEnrolled;
        return BiometricAuthResult.unavailable;
      }
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported || !canCheck) return BiometricAuthResult.unavailable;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isEmpty ? BiometricAuthResult.notEnrolled : BiometricAuthResult.success;
    } on PlatformException catch (e) {
      AppLogger.debug('Biometric availability failed: ${e.code}');
      return BiometricAuthResult.platformError;
    } catch (e) {
      AppLogger.debug('Biometric availability failed: $e');
      return BiometricAuthResult.platformError;
    }
  }

  static Future<bool> isDeviceSupported() async {
    final status = await availability();
    return status == BiometricAuthResult.success;
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.debug('Available biometrics check failed: $e');
      return <BiometricType>[];
    }
  }

  static Future<BiometricAuthResult> authenticateWithResult({
    required String localizedReason,
  }) async {
    final status = await availability();
    if (status != BiometricAuthResult.success) return status;

    try {
      final authenticated = await _auth
          .authenticate(
            localizedReason: localizedReason,
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
              useErrorDialogs: true,
              sensitiveTransaction: true,
            ),
          )
          .timeout(const Duration(seconds: 45));
      return authenticated ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on PlatformException catch (e) {
      AppLogger.debug('Biometric prompt failed: ${e.code}');
      final code = e.code.toLowerCase();
      if (code.contains('lockout') && code.contains('permanent')) {
        return BiometricAuthResult.permanentlyLockedOut;
      }
      if (code.contains('lockout')) return BiometricAuthResult.lockedOut;
      if (code.contains('cancel') || code.contains('user_canceled')) {
        return BiometricAuthResult.canceled;
      }
      return BiometricAuthResult.platformError;
    } on TimeoutException {
      return BiometricAuthResult.canceled;
    } catch (e) {
      AppLogger.debug('Biometric prompt failed: $e');
      return BiometricAuthResult.platformError;
    }
  }

  static Future<bool> authenticate({
    String localizedReason = 'Confirm your identity to continue',
  }) async {
    return (await authenticateWithResult(localizedReason: localizedReason)) ==
        BiometricAuthResult.success;
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final storage = await SecureStorageService.instance;
      final secureValue = await storage.getBool(_enabledKey);
      if (secureValue != null) return secureValue;

      // ترحيل آمن لمرة واحدة من الإصدارات القديمة التي استخدمت SharedPreferences للحالة فقط.
      final prefs = await SharedPreferences.getInstance();
      final legacyValue = prefs.getBool(_enabledKey) ?? false;
      if (legacyValue) await storage.setBool(_enabledKey, true);
      await prefs.remove(_enabledKey);
      return legacyValue;
    } catch (e) {
      AppLogger.debug('Biometric preference read failed: $e');
      return false;
    }
  }

  static Future<void> setBiometricEnabled(bool enabled, {String? userUid}) async {
    final storage = await SecureStorageService.instance;
    await storage.setBool(_enabledKey, enabled);
    if (enabled && userUid != null && userUid.isNotEmpty) {
      await storage.setString(_uidKey, userUid);
    } else if (!enabled) {
      await storage.remove(_uidKey);
    }
  }

  static Future<bool> isEnabledForUser(String uid) async {
    if (!await isBiometricEnabled()) return false;
    final storage = await SecureStorageService.instance;
    return (await storage.getString(_uidKey)) == uid;
  }
}

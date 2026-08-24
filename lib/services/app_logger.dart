import 'package:flutter/foundation.dart';

/// Logger آمن؛ لا يكتب أي تفاصيل تشغيلية في إصدار الإنتاج.
class AppLogger {
  AppLogger._();

  static void debug(Object? message) {
    if (kDebugMode) debugPrint('[SmartEnergy] $message');
  }
}

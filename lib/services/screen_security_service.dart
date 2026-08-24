import 'package:flutter/services.dart';

/// حماية الشاشات الحساسة من لقطات الشاشة على المنصات التي تدعمها.
class ScreenSecurityService {
  ScreenSecurityService._();
  static const _channel = MethodChannel('smartenergy/screen_security');

  static Future<void> enable() async {
    try { await _channel.invokeMethod('enable'); } on PlatformException { /* no-op */ }
  }

  static Future<void> disable() async {
    try { await _channel.invokeMethod('disable'); } on PlatformException { /* no-op */ }
  }
}

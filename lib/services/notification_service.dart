/// ══════════════════════════════════════════════════════════════════════════════
/// خدمة الإشعارات — NotificationService
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: إدارة Firebase Cloud Messaging (FCM) للإشعارات الفورية
///          تهيئة الأذونات، معالجة الرسائل (أمامية/خلفية/عند الفتح)
///
/// الاستخدام: يُستدعى مرة واحدة بعد Firebase.initializeApp()
///            NotificationService.initialize()
///
/// القيمة المرجعة: خدمة ثابتة (static) لإدارة FCM
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// معالج الرسائل في الخلفية — يجب أن يكون دالة عليا (top-level)
///
/// المعاملات:
///   - [message]: الرسالة القادمة من FCM
///
/// القيمة المرجعة: [Future<void>]
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 رسالة خلفية: ${message.messageId}');
  debugPrint('   العنوان: ${message.notification?.title}');
  debugPrint('   المحتوى: ${message.notification?.body}');
}

/// كلاس خدمة الإشعارات — يدير FCM بالكامل
class NotificationService {
  /// مرجع Firebase Messaging
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// هل تم التهيئة
  static bool _initialized = false;

  /// تهيئة FCM — تُستدعى مرة واحدة بعد Firebase.initializeApp()
  ///
  /// القيمة المرجعة: [Future<void>]
  static Future<void> initialize() async {
    if (_initialized) return;

    // تسجيل معالج الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // طلب الأذونات (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 أذونات FCM: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // الحصول على رمز FCM
      try {
        final token = await _messaging.getToken();
        debugPrint('🔔 رمز FCM: $token');
      } catch (e) {
        debugPrint('🔔 خطأ في رمز FCM: $e');
      }

      // الاستماع لتحديث الرمز
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔔 تم تحديث رمز FCM: $newToken');
      });

      // معالج الرسائل الأمامية (التطبيق مفتوح)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 رسالة أمامية: ${message.messageId}');
        final notification = message.notification;
        if (notification != null) {
          debugPrint('   العنوان: ${notification.title}');
          debugPrint('   المحتوى: ${notification.body}');
          _showInAppNotification(notification);
        }
      });

      // معالج النقر على الإشعار (التطبيق في الخلفية)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 تم فتح إشعار: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // التحقق من إشعار الفتح الأولي (التطبيق كان مغلقاً)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 رسالة أولية: ${initialMessage.messageId}');
        _handleNotificationTap(initialMessage);
      }
    }

    _initialized = true;
  }

  /// عرض إشعار داخل التطبيق (للرسائل الأمامية)
  ///
  /// المعاملات:
  ///   - [notification]: بيانات الإشعار
  static void _showInAppNotification(RemoteNotification notification) {
    debugPrint('📢 إشعار داخلي: ${notification.title} — ${notification.body}');
  }

  /// معالجة النقر على الإشعار والتوجيه حسب البيانات
  ///
  /// المعاملات:
  ///   - [message]: الرسالة التي تم النقر عليها
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('📢 بيانات النقر: $data');
  }

  /// الاشتراك في موضوع FCM (مثل: 'energy_alerts')
  ///
  /// المعاملات:
  ///   - [topic]: اسم الموضوع
  ///
  /// القيمة المرجعة: [Future<void>]
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('🔔 تم الاشتراك في: $topic');
  }

  /// إلغاء الاشتراك من موضوع FCM
  ///
  /// المعاملات:
  ///   - [topic]: اسم الموضوع
  ///
  /// القيمة المرجعة: [Future<void>]
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('🔔 تم إلغاء الاشتراك من: $topic');
  }
}

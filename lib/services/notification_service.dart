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

import 'app_logger.dart';
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
  AppLogger.debug('🔔 رسالة خلفية: ${message.messageId}');
  AppLogger.debug('   العنوان: ${message.notification?.title}');
  AppLogger.debug('   المحتوى: ${message.notification?.body}');
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

    AppLogger.debug('🔔 أذونات FCM: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // الحصول على رمز FCM
      try {
        final token = await _messaging.getToken();
        AppLogger.debug('🔔 رمز FCM: $token');
      } catch (e) {
        AppLogger.debug('🔔 خطأ في رمز FCM: $e');
      }

      // الاستماع لتحديث الرمز
      _messaging.onTokenRefresh.listen((newToken) {
        AppLogger.debug('🔔 تم تحديث رمز FCM: $newToken');
      });

      // معالج الرسائل الأمامية (التطبيق مفتوح)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.debug('🔔 رسالة أمامية: ${message.messageId}');
        final notification = message.notification;
        if (notification != null) {
          AppLogger.debug('   العنوان: ${notification.title}');
          AppLogger.debug('   المحتوى: ${notification.body}');
          _showInAppNotification(notification);
        }
      });

      // معالج النقر على الإشعار (التطبيق في الخلفية)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.debug('🔔 تم فتح إشعار: ${message.messageId}');
        _handleNotificationTap(message);
      });

      // التحقق من إشعار الفتح الأولي (التطبيق كان مغلقاً)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.debug('🔔 رسالة أولية: ${initialMessage.messageId}');
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
    AppLogger.debug('📢 إشعار داخلي: ${notification.title} — ${notification.body}');
  }

  /// معالجة النقر على الإشعار والتوجيه حسب البيانات
  ///
  /// المعاملات:
  ///   - [message]: الرسالة التي تم النقر عليها
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    AppLogger.debug('📢 بيانات النقر: $data');
  }

  /// الاشتراك في موضوع FCM (مثل: 'energy_alerts')
  ///
  /// المعاملات:
  ///   - [topic]: اسم الموضوع
  ///
  /// القيمة المرجعة: [Future<void>]
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    AppLogger.debug('🔔 تم الاشتراك في: $topic');
  }

  /// إلغاء الاشتراك من موضوع FCM
  ///
  /// المعاملات:
  ///   - [topic]: اسم الموضوع
  ///
  /// القيمة المرجعة: [Future<void>]
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    AppLogger.debug('🔔 تم إلغاء الاشتراك من: $topic');
  }
}

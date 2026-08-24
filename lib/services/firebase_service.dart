/// ══════════════════════════════════════════════════════════════════════════════
/// خدمة Firebase — FirebaseService
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: طبقة الاتصال الوحيدة مع Firebase Realtime Database (RTDB)
///          تقرأ بيانات الطاقة اللحظية من ESP32 وتتحكم في حالات الريلاي
///
/// المسارات في قاعدة البيانات (RTDB Paths):
///   ┌─────────────────────┬──────────────────────────────────────────┐
///   │ المسار              │ الوصف                                    │
///   ├─────────────────────┼──────────────────────────────────────────┤
///   │ energy_node/        │ قراءات الطاقة اللحظية (فولت، أمبير، واط)│
///   │ relays/{relayId}/   │ حالة كل ريلاي (state + updated_at)     │
///   │ activity_logs/      │ سجل نشاط النظام (تشغيل/إيقاف)          │
///   └─────────────────────┴──────────────────────────────────────────┘
///
/// أنواع العمليات:
///   - Stream (بث مستمر): للبيانات التي تتغير لحظياً (قراءات الطاقة)
///   - Future (طلب مرة واحدة): لجلب حالة فورية (مثل حالة ريلاي)
///
/// مثال الاستخدام:
///   final service = FirebaseService();
///   service.energyDataStream.listen((data) {
///     print('الفولتية: ${data.voltage}V');
///   });
///
/// القيمة المرجعة: كائن يوفر Streams و Futures للتعامل مع RTDB
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:firebase_database/firebase_database.dart';
import '../models/energy_data.dart';

/// كلاس خدمة Firebase — يوفر واجهة موحدة للتعامل مع Realtime Database
///
/// ملاحظة: جميع الدوال غير المتزامنة (async) تُرجع Future أو Stream
///         تأكد من فحص context.mounted قبل تحديث الواجهة بعد كل await
class FirebaseService {
  // ─────────────────────────────────────────────────────────────
  // المراجع الأساسية (References)
  // ─────────────────────────────────────────────────────────────

  /// مرجع قاعدة البيانات الرئيسي — نقطة الدخول لجميع المسارات
  /// يُستخدم كأساس لبناء مراجع فرعية مثل: _dbRef.child('energy_node')
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ─────────────────────────────────────────────────────────────
  // 1. بث بيانات الطاقة اللحظية (Real-time Energy Stream)
  // ─────────────────────────────────────────────────────────────

  /// بث بيانات الطاقة اللحظية من Firebase RTDB
  ///
  /// المسار في RTDB: energy_node/
  /// مصدر البيانات: ESP32 يكتب القراءات كل ثانية
  ///
  /// البيانات المتوقعة من ESP32:
  ///   - voltage: الفولتية (V)
  ///   - current: التيار (A)
  ///   - power: القدرة (W)
  ///   - energy: الطاقة المستهلكة (kWh)
  ///   - frequency: التردد (Hz)
  ///   - power_factor: معامل القدرة
  ///
  /// القيمة المرجعة: [Stream<EnergyData>] — تدفق مستمر لقراءات الطاقة
  ///                  يتحدث تلقائياً عند كل تغيير في RTDB
  ///
  /// مثال الاستخدام في الواجهة:
  ///   StreamBuilder<EnergyData>(
  ///     stream: firebaseService.energyDataStream,
  ///     builder: (context, snapshot) {
  ///       if (!context.mounted) return const SizedBox(); // فحص السلامة
  ///       if (snapshot.hasData) {
  ///         return Text('${snapshot.data!.voltage}V');
  ///       }
  ///       return const CircularProgressIndicator();
  ///     },
  ///   )
  Stream<EnergyData> get energyDataStream {
    return _dbRef.child('energy_node').onValue.map((event) {
      // التحقق: هل توجد بيانات في المسار؟
      if (event.snapshot.value != null) {
        // تحويل البيانات الخام من Firebase إلى Map قابلة للقراءة
        final data = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map,
        );
        // تحويل Map إلى كائن EnergyData مُنظّم
        return EnergyData.fromMap(data);
      }
      // إرجاع قيم افتراضية (أصفار) إذا لم تتوفر بيانات من ESP32
      return EnergyData();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 2. جلب بيانات الطاقة لمرة واحدة (One-time Fetch)
  // ─────────────────────────────────────────────────────────────

  /// جلب بيانات الطاقة الحالية مرة واحدة (بدون بث مستمر)
  ///
  /// يُستخدم عند فتح الشاشة لأول مرة أو عند طلب تحديث يدوي
  ///
  /// ⚠️ تنبيه: بعد استدعاء هذه الدالة (await)، تأكد من فحص:
  ///   if (!context.mounted) return;
  ///   قبل تحديث أي عنصر في الواجهة
  ///
  /// القيمة المرجعة: [Future<EnergyData>] — بيانات الطاقة الحالية
  Future<EnergyData> getEnergyData() async {
    // جلب لقطة واحدة من المسار (بدون اشتراك مستمر)
    final snapshot = await _dbRef.child('energy_node').get();

    // التحقق: هل المسار موجود وفيه بيانات؟
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return EnergyData.fromMap(data);
    }

    // إرجاع قيم افتراضية إذا لم يكن المسار موجوداً بعد
    return EnergyData();
  }

  // ─────────────────────────────────────────────────────────────
  // 3. التحكم في الريلاي (Relay Control)
  // ─────────────────────────────────────────────────────────────

  /// كتابة حالة الريلاي إلى Firebase RTDB (للتحكم في الأجهزة عن بُعد)
  ///
  /// المسار في RTDB: relays/{relayId}/
  ///
  /// كيف يعمل:
  ///   1. التطبيق يكتب الحالة الجديدة في RTDB
  ///   2. ESP32 يستمع للتغييرات على هذا المسار
  ///   3. ESP32 يُغيّر حالة الريلاي الفعلي (تشغيل/إيقاف)
  ///
  /// المعاملات:
  ///   - [relayId]: معرّف الريلاي الفريد (مثال: "relay1", "relay2", "relay3")
  ///   - [isOn]: الحالة المطلوبة (true = تشغيل ⚡، false = إيقاف 🔴)
  ///
  /// البيانات المكتوبة:
  ///   {
  ///     "state": true/false,
  ///     "updated_at": ServerValue.timestamp  ← طابع زمني من سيرفر Firebase
  ///   }
  ///
  /// ⚠️ تنبيه: بعد استدعاء هذه الدالة، تأكد من فحص context.mounted
  ///
  /// القيمة المرجعة: [Future<void>]
  Future<void> setRelayState(String relayId, bool isOn) async {
    await _dbRef.child('relays/$relayId').set({
      // الحالة الجديدة للريلاي
      'state': isOn,
      // طابع زمني من سيرفر Firebase (وليس من جهاز المستخدم) لضمان الدقة
      'updated_at': ServerValue.timestamp,
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 4. بث حالات الريلاي (Relay States Stream)
  // ─────────────────────────────────────────────────────────────

  /// بث حالات جميع الريلاي من Firebase RTDB
  ///
  /// المسار في RTDB: relays/
  ///
  /// يُستخدم في شاشة الأجهزة لعرض الحالة اللحظية لكل ريلاي
  /// عند تغيير ESP32 لأي ريلاي، يتم تحديث الواجهة فوراً
  ///
  /// القيمة المرجعة: [Stream<Map<String, bool>>]
  ///   خريطة مفاتيحها معرّفات الريلاي وقيمها الحالة
  ///   مثال: {"relay1": true, "relay2": false, "relay3": true}
  Stream<Map<String, bool>> get relayStatesStream {
    return _dbRef.child('relays').onValue.map((event) {
      // التحقق: هل توجد بيانات ريلاي في RTDB؟
      if (event.snapshot.value != null) {
        // تحويل البيانات الخام إلى Map
        final data = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map,
        );
        // تحويل كل ريلاي إلى زوج {معرّف: حالة}
        return data.map((key, value) {
          final relay = Map<dynamic, dynamic>.from(value as Map);
          return MapEntry(
            key.toString(),           // معرّف الريلاي (relay1, relay2...)
            relay['state'] == true,   // الحالة (true = مُشغّل)
          );
        });
      }
      // إرجاع خريطة فارغة إذا لم تتوفر بيانات ريلاي بعد
      return <String, bool>{};
    });
  }

  // ─────────────────────────────────────────────────────────────
  // 5. سجل النشاط (Activity Logs)
  // ─────────────────────────────────────────────────────────────

  /// بث سجل النشاط من Firebase RTDB
  ///
  /// المسار في RTDB: activity_logs/
  ///
  /// يتضمن سجلات:
  ///   - تشغيل/إيقاف الأجهزة
  ///   - تسجيل الدخول/الخروج
  ///   - تنبيهات الطاقة (استهلاك عالي، انقطاع)
  ///
  /// القيمة المرجعة: [Stream<List<Map<String, dynamic>>>]
  ///   قائمة أحداث مرتبة زمنياً (الأحدث أولاً)
  ///
  /// هيكل كل حدث:
  ///   {
  ///     "type": "relay_toggle",
  ///     "relay_id": "relay1",
  ///     "action": "on",
  ///     "timestamp": 1715000000000,
  ///     "user": "+218XXXXXXXXX"
  ///   }
  Stream<List<Map<String, dynamic>>> get activityLogsStream {
    return _dbRef.child('activity_logs').onValue.map((event) {
      // التحقق: هل يوجد سجل نشاط؟
      if (event.snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map,
        );
        // تحويل كل إدخال إلى Map وجمعها في قائمة
        return data.entries.map((entry) {
          final log = Map<dynamic, dynamic>.from(entry.value as Map);
          return Map<String, dynamic>.from(log);
        }).toList()
          // ترتيب تنازلي حسب الطابع الزمني (الأحدث أولاً)
          ..sort((a, b) {
            final aTime = a['timestamp'] ?? a['time'] ?? 0;
            final bTime = b['timestamp'] ?? b['time'] ?? 0;
            return (bTime as int).compareTo(aTime as int);
          });
      }
      // إرجاع قائمة فارغة إذا لم يوجد سجل بعد
      return <Map<String, dynamic>>[];
    });
  }

  /// تسجيل نشاط جديد في Firebase RTDB
  Future<void> logActivity({
    required String device,
    required String action,
    required String trigger,
    String? space,
  }) async {
    try {
      final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
      await _dbRef.child('activity_logs/$logId').set({
        'device': device,
        'action': action,
        'trigger': trigger,
        'space': space ?? 'Main',
        'timestamp': ServerValue.timestamp,
        'time': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // صامت في حالة عدم الاتصال بالسحابة
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 6. فحص الاتصال المباشر (Connection Health Check)
  // ─────────────────────────────────────────────────────────────

  /// بث حالة اتصال Firebase الحية عبر مسار .info/connected
  Stream<bool> get connectionStream {
    return _dbRef.root.child('.info/connected').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }
}

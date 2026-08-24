/// ══════════════════════════════════════════════════════════════════════════════
/// نموذج الجهاز — DeviceModel
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: يمثل جهاز واحد في نظام المراقبة الذكية، مع ربط بمخرج ريلي ESP32
///          يستخدم خريطة أيقونات ثابتة (static) لتجنب أخطاء tree-shaking
///
/// المعاملات الرئيسية:
///   - id: معرّف فريد للجهاز
///   - name: اسم الجهاز بالعربية
///   - iconKey: مفتاح نصي للأيقونة من الخريطة الثابتة
///   - relayId: معرّف مخرج الريلي في ESP32 (relay1, relay2, ...)
///   - wattage: استهلاك الجهاز بالواط
///   - isOn: حالة التشغيل/الإيقاف
///   - spaceId: المساحة التي ينتمي إليها الجهاز
///
/// القيمة المرجعة: كائن قابل للتحويل من/إلى Map للتخزين المحلي
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// كلاس نموذج الجهاز — يحتوي على جميع معلومات الجهاز وربط الريلي
class DeviceModel {
  /// معرّف فريد للجهاز
  final String id;

  /// اسم الجهاز المعروض للمستخدم
  String name;

  /// مفتاح الأيقونة — يُخزن كنص ويُحل من الخريطة الثابتة
  String iconKey;

  /// معرّف مخرج الريلي في ESP32 (مثال: relay1, relay2, relay3, relay4)
  String relayId;

  /// استهلاك الجهاز بالواط (W)
  int wattage;

  /// حالة التشغيل — true = مشغّل، false = مطفأ
  bool isOn;

  /// معرّف المساحة التي ينتمي إليها الجهاز
  String spaceId;

  /// المُنشئ — ينشئ جهاز جديد مع جميع الحقول المطلوبة
  DeviceModel({
    required this.id,
    required this.name,
    this.iconKey = 'plug',
    this.relayId = '',
    required this.wattage,
    this.isOn = false,
    this.spaceId = 'default',
  });

  /// خريطة الأيقونات الثابتة — آمنة من tree-shaking
  /// تستخدم حزمة FontAwesomeIcons الفاخرة
  static const Map<String, dynamic> iconMap = {
    'couch': FontAwesomeIcons.couch,
    'kitchen': FontAwesomeIcons.kitchenSet,
    'snowflake': FontAwesomeIcons.snowflake,
    'droplet': FontAwesomeIcons.droplet,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'tv': FontAwesomeIcons.tv,
    'fan': FontAwesomeIcons.fan,
    'plug': FontAwesomeIcons.plug,
    'computer': FontAwesomeIcons.laptop,
    'blender': FontAwesomeIcons.blender,
    'temperature': FontAwesomeIcons.temperatureHalf,
    'shower': FontAwesomeIcons.shower,
    'bolt': FontAwesomeIcons.bolt,
    'fire': FontAwesomeIcons.fire,
    'wifi': FontAwesomeIcons.wifi,
    'solar': FontAwesomeIcons.solarPanel,
  };

  /// الحصول على أيقونة الجهاز من الخريطة الثابتة
  dynamic get icon => iconMap[iconKey] ?? FontAwesomeIcons.plug;

  /// قائمة مخارج الريلي المتاحة في ESP32
  static const List<String> availableRelays = [
    'relay1', 'relay2', 'relay3', 'relay4',
    'relay5', 'relay6', 'relay7', 'relay8',
  ];

  /// تحويل الجهاز إلى Map للتخزين المحلي
  ///
  /// القيمة المرجعة: [Map<String, dynamic>] — خريطة بيانات الجهاز
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'iconKey': iconKey,
    'relayId': relayId,
    'wattage': wattage,
    'isOn': isOn,
    'spaceId': spaceId,
  };

  /// إنشاء جهاز من Map — يدعم البيانات القديمة (iconCodePoint) والجديدة (iconKey)
  ///
  /// المعاملات:
  ///   - [map]: خريطة البيانات المحفوظة
  ///
  /// القيمة المرجعة: كائن [DeviceModel] جديد
  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    String resolvedIconKey = map['iconKey'] ?? 'plug';

    // دعم البيانات القديمة التي تخزن iconCodePoint بدلاً من iconKey
    if (!map.containsKey('iconKey') && map.containsKey('iconCodePoint')) {
      final codePoint = map['iconCodePoint'] as int;
      resolvedIconKey = _resolveIconKeyFromCodePoint(codePoint);
    }

    return DeviceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconKey: resolvedIconKey,
      relayId: map['relayId'] ?? '',
      wattage: map['wattage'] ?? 100,
      isOn: map['isOn'] ?? false,
      spaceId: map['spaceId'] ?? 'default',
    );
  }

  /// تحويل رقم الأيقونة القديم إلى مفتاح نصي
  ///
  /// المعاملات:
  ///   - [codePoint]: رقم Unicode للأيقونة
  ///
  /// القيمة المرجعة: [String] — مفتاح الأيقونة النصي أو 'plug' كافتراضي
  static String _resolveIconKeyFromCodePoint(int codePoint) {
    for (final entry in iconMap.entries) {
      if (entry.value.codePoint == codePoint) return entry.key;
    }
    return 'plug';
  }
}

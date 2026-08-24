/// ══════════════════════════════════════════════════════════════════════════════
/// نموذج بيانات الطاقة — EnergyData
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: يمثل هذا الكلاس قراءات الطاقة اللحظية القادمة من حساس SCT-013
///          المتصل بـ ESP32 عبر Firebase Realtime Database.
///
/// الحقول:
///   - power: القدرة اللحظية بالواط (W)
///   - current: التيار الكهربائي بالأمبير (A)
///   - voltage: الجهد الكهربائي بالفولت (V)
///   - totalKwh: إجمالي الاستهلاك بالكيلووات/ساعة (kWh)
///
/// القيمة المرجعة: كائن يحتوي على جميع قراءات الطاقة مع دوال مساعدة
///                 لحساب الفاتورة والنسبة المئوية
/// ══════════════════════════════════════════════════════════════════════════════

class EnergyData {
  /// القدرة اللحظية — بالواط (W)
  final double power;

  /// التيار الكهربائي — بالأمبير (A)
  final double current;

  /// الجهد الكهربائي — بالفولت (V)
  final double voltage;

  /// إجمالي الاستهلاك — بالكيلووات/ساعة (kWh)
  final double totalKwh;

  /// المُنشئ الأساسي مع قيم افتراضية صفرية
  ///
  /// المعاملات:
  ///   - [power]: القدرة (اختياري، افتراضي: 0.0)
  ///   - [current]: التيار (اختياري، افتراضي: 0.0)
  ///   - [voltage]: الجهد (اختياري، افتراضي: 0.0)
  ///   - [totalKwh]: إجمالي الاستهلاك (اختياري، افتراضي: 0.0)
  EnergyData({
    this.power = 0.0,
    this.current = 0.0,
    this.voltage = 0.0,
    this.totalKwh = 0.0,
  });

  /// تحويل من بيانات Firebase RTDB إلى كائن EnergyData
  ///
  /// المعاملات:
  ///   - [map]: خريطة البيانات القادمة من Firebase snapshot
  ///
  /// القيمة المرجعة: كائن [EnergyData] جديد مملوء بالبيانات
  factory EnergyData.fromMap(Map<dynamic, dynamic> map) {
    return EnergyData(
      power: (map['power'] ?? 0).toDouble(),
      current: (map['current'] ?? 0).toDouble(),
      voltage: (map['voltage'] ?? 0).toDouble(),
      totalKwh: (map['total_kwh'] ?? 0).toDouble(),
    );
  }

  /// حساب الفاتورة الشهرية المتوقعة بالدينار الليبي (LYD)
  ///
  /// يستخدم تعرفة الكهرباء الليبية التقريبية: 0.065 د.ل / كيلووات/ساعة
  ///
  /// القيمة المرجعة: [double] — المبلغ المتوقع بالدينار الليبي
  double get estimatedBillLYD {
    const double ratePerKwh = 0.065; // دينار ليبي لكل كيلووات/ساعة
    return totalKwh * ratePerKwh;
  }

  /// حساب نسبة القدرة من الحد الأقصى المنزلي (5000W)
  ///
  /// القيمة المرجعة: [double] — نسبة بين 0.0 و 1.0
  double get powerPercentage {
    const double maxPower = 5000.0;
    return (power / maxPower).clamp(0.0, 1.0);
  }

  /// تنسيق عرض القدرة (تحويل تلقائي W ↔ kW)
  ///
  /// القيمة المرجعة: [String] — نص منسق مثل "1.2 kW" أو "800 W"
  String get powerDisplay {
    if (power >= 1000) {
      return '${(power / 1000).toStringAsFixed(1)} kW';
    }
    return '${power.toStringAsFixed(0)} W';
  }
}

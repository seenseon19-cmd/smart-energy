/// مدير مصادر الرسوم المتحركة Lottie — AppAnimations
///
/// جميع الحركات Premium محلية بصيغة JSON مستخرجة من ملفات dotLottie
/// الرسمية التي تم تنزيلها من صفحات LottieFiles المحددة. هذا يمنع
/// الاعتماد على GIF أو روابط غير مستقرة، ويجعل فشل الشبكة غير مؤثر.
class AppAnimations {
  AppAnimations._();

  /// الحركة المستخدمة في شرح الدخول بعد التسجيل.
  static const String welcomeOnboarding =
      'assets/lottie/premium/smart_home_animation_2.json';

  /// الحركة الحالية لزر تبديل الوضع النهاري والليلي.
  static const String themeToggle =
      'https://lottie.host/149d38e6-45fb-41b2-991b-26f586f9c9d5/mZHwwCR2mE.json';

  /// Energy Saving — بطاقة ترشيد الطاقة داخل Dashboard.
  static const String energySavingPromo =
      'assets/lottie/premium/energy_saving_tktaQk8Po2.json';

  /// أزرار فتح وإغلاق الأجهزة.
  static const String powerToggle =
      'https://lottie.host/91be81ee-cfb9-440f-9278-747ebd9e7955/4REGnkyv7q.json';

  /// Concept Smart Home — اختيار المنزل الذكي.
  static const String conceptSmartHome =
      'assets/lottie/premium/concept_smart_home.json';

  /// Smart Homes Devices — شاشة الأجهزة والأتمتة.
  static const String smartHomesDevices =
      'assets/lottie/premium/smart_homes_devices.json';

  /// Electricity / Smart Appliances — قسم استهلاك الكهرباء.
  static const String electricity = 'assets/lottie/premium/electricity.json';

  /// الحركة الحالية للانتقال التجاري، مع إبقاء المرجع القديم للتوافق.
  static const String resToCom = conceptSmartHome;

  /// الحركة الحالية للانتقال المنزلي، مع إبقاء المرجع القديم للتوافق.
  static const String comToRes = 'assets/lottie/premium/concept_smart_home.json';

  /// Energy Saving — Dialog التوعية.
  static const String energyAdvisoryDialog =
      'assets/lottie/premium/energy_saving_tktaQk8Po2.json';

  /// تنبيه الحمل الزائد.
  static const String overloadWarning =
      'https://lottie.host/eea04746-73a7-4ffc-adb7-36ffdeccab96/xrnu6WHhJ0.json';

  /// هيدر شاشة الإحصائيات.
  static const String analyticsHero =
      'https://lottie.host/9860f184-bdbd-4a42-a490-25a1e9db730c/Z7Z53NtprF.json';

  /// المصدر الرسمي للحركة السادسة لأغراض التوثيق والترخيص.
  static const String smartHomeAnimation2 =
      'assets/lottie/premium/smart_home_animation_2.json';
}

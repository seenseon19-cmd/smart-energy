# تقرير التدقيق الأمني والتقني النهائي — SmartEnergy

## نطاق التدقيق

تم فحص مشروع Flutter وملفات Android وطبقة Firebase RTDB وتهيئة FCM ومسارات المصادقة والتخزين المحلي ومسارات Startup، مع التركيز على عدم تنفيذ أي اختبار هجومي خارجي. التدقيق ساكن ومحدود بالملفات والموارد الموجودة داخل المشروع.

## النتائج التي تم إصلاحها

| المجال | النتيجة والإجراء |
|---|---|
| الإعلانات | لا توجد dependency إعلانية في `pubspec.yaml`، ولا توجد مراجع AdMob أو Interstitial أو Rewarded أو Banner داخل `lib` أو Android. كما أزيل مسار الإعلان التلقائي `showOnce` من Dashboard، وأصبح Dialog الترشيد يفتح من ضغط صريح فقط. |
| Startup | أزيل طلب FCM من `main()` قبل Authentication. أصبحت تهيئة FCM بعد دخول المستخدم داخل PostLoginRouter، ولا تمنع رفض الإذن أو انقطاع الشبكة فتح التطبيق. |
| 2FA secret | أزيل المفتاح الثابت من `SecurityScreen`. يُنشأ مفتاح عشوائي لكل UID ويُحفظ عبر `flutter_secure_storage`. |
| 2FA الوهمي | أوقف مسار قبول أي رمز من ستة أرقام وتفعيل 2FA محليًا. تظهر الآن رسالة واضحة بأن التفعيل يحتاج مسار Firebase/Backend موثق؛ هذا يمنع إعطاء المستخدم إحساسًا زائفًا بالحماية. |
| السجلات | أزيل تسجيل OTP ورقم الهاتف والبريد ومحتوى الإشعارات وPayload الإشعار. بقيت سجلات Debug عامة أو رموز أخطاء غير حساسة. |
| Firebase catch | أزيل catch الصامت من `FirebaseService.logActivity` واستُبدل بسجل Debug آمن يعتمد نوع الخطأ فقط. كما عولجت catches مزامنة الخطط ونوع الحساب في `EnergyProvider`. |
| Android Release | أزيل توقيع debug من `android/app/build.gradle.kts`. يجب توفير keystore إنتاجي رسمي في بيئة الإصدار قبل نشر APK. |
| الأسرار | `esp32_firmware/secrets.h` غير متابع في Git، وأضيف `secrets.example.h` بقيم placeholder. يجب عدم إرسال أو رفع `secrets.h` الحقيقي. |

## Startup Flow الفعلي

```text
main()
  → WidgetsFlutterBinding.ensureInitialized()
  → Firebase.initializeApp() بمهلة 15 ثانية
  → SystemChrome
  → قراءة dark_mode
  → runApp(SmartEnergyApp)
  → MultiProvider
  → MaterialApp(home: _AppRouter)
  → AuthService.authResolved
  → biometric gate عند وجود جلسة محفوظة محمية
  → PostLoginRouter عند نجاح المصادقة
  → تهيئة FCM بعد Authentication فقط
```

عند عدم وجود جلسة، يقرأ `_AppRouter` قيمة `onboarding_done` ثم يعرض `OnboardingScreen` أو `LoginScreen`. لا يوجد مسار إعلاني أو شاشة تجارية بين Startup وAuthentication.

## ملاحظة حرجة حول Firebase Rules

قواعد RTDB الحالية تمنح أي مستخدم مسجل دخول صلاحية قراءة وكتابة المسارات العالمية `energy_node` و`relays` و`device_status` و`activity_logs`. هذا لا يساوي `allow read, write: if true`، لكنه لا يحقق عزل الملكية بين المستخدمين. السبب أن التطبيق والـ ESP32 يستخدمان حاليًا مسارات عالمية، وليس مسارات مفصولة مثل `users/{uid}/...`.

لا يجوز تغيير هذه القواعد عشوائيًا قبل تغيير بنية ESP32 وطبقة Flutter؛ لأن ذلك قد يقطع قراءة الطاقة والتحكم. قبل الإنتاج يجب نقل البيانات إلى مسارات مملوكة، مثل `users/$uid/spaces/...`، أو استخدام خادم/Cloud Functions وCustom Claims للتحقق من ملكية الأجهزة وأهلية Commercial. كما يجب منع العميل من تعديل entitlement الخاص بالخطط دون تحقق خادمي.

## قيود الاختبار

نجح `git diff --check`، ونجحت فحوص البحث الخاصة بالإعلانات والأسرار الثابتة المتعمدة داخل ملفات التطبيق. لم يتم تشغيل `flutter analyze` أو `flutter test` أو APK Runtime داخل هذه البيئة لأن Flutter وDart SDK غير مثبتين. لذلك لا يُسجل هذا التقرير نجاح بناء أو اختبار Android فعليًا.

يلزم تنفيذ الاختبار النهائي على جهاز Windows أو CI يحتوي Flutter SDK:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter run
```

ويجب اختبار Startup وLogin وRegister وLogout وOnboarding وAdd Device وAdd Home Space وAdd Commercial Space وSettings وLanguage Switching وBiometric وعمليات Firebase على جهاز فعلي، إضافة إلى اختبار الشبكة المنقطعة والقفل البيومتري.

## الخلاصة

تم إصلاح الثغرات المؤكدة داخل الكود التي يمكن معالجتها دون تغيير بنية Firebase: إزالة الإعلانات التلقائية، تأجيل FCM، إزالة السر الثابت، إيقاف 2FA الوهمي، تنظيف السجلات، معالجة catches الصامتة، ومنع توقيع Release بمفتاح debug. أما عزل بيانات RTDB وأهلية Commercial الخادمية فتحتاج إعادة تصميم مسارات Firebase وتهيئة Rules/Backend، ولا يصح الادعاء بأنها محمية بالكامل بالواجهة الحالية فقط.

آخر تحديث: 25 أغسطس 2026.

المشروع: SmartEnergy
الطلاب: سهيل عبدالله سعيد — همام بن عروس

# تقرير تطبيق شعار SmartEnergy

## المصدر الرسمي

تم اعتماد الملف المرفق نفسه دون إعادة رسم أو تغيير ألوان أو نسب:

```text
assets/images/smart_energy_official_logo.webp
```

خصائص الأصل: WebP، أبعاد 1248×1248. وهو أصل مربع يحتوي على جهاز قياس الطاقة واسم SmartEnergy والعبارة التعريفية.

## Widget المركزي

تم إنشاء:

```text
lib/widgets/smart_energy_logo.dart
```

والكلاس المركزي هو `SmartEnergyLogo`. يقبل الحجم والمحاذاة والهامش و`BoxFit`، ويحتوي على fallback محدود عند فشل تحميل الأصل. كما تم تحويل `AppLogo` القديم إلى غلاف توافق يستدعي `SmartEnergyLogo`، ولذلك لا تبقى مراجع `AppLogo` القديمة مرتبطة بأيقونة برق أو نص مرسوم يدويًا.

## الأحجام المستخدمة

| السياق | الشاشة | الحجم |
|---|---|---:|
| Startup/Splash الحقيقي | `_StartupLoadingScreen` في `lib/main.dart` | 162 داخل حاوية 178 |
| Login | `_buildAnimatedLogo` في `lib/screens/login_screen.dart` | 174 داخل حاوية 190 |
| Register | `lib/screens/register_screen.dart` | 156 |
| Onboarding | `lib/screens/onboarding_screen.dart` | 96 |
| Account Type بعد التسجيل | `lib/screens/account_type_screen.dart` | 82 |
| الترويسة الداخلية | `lib/screens/main_shell.dart` | 42 |
| Spaces | AppBar في `lib/screens/spaces_screen.dart` | 34 |
| Subscription | AppBar في `lib/screens/subscription_screen.dart` | 34 |
| Add Device | AppBar في `lib/screens/add_device_screen.dart` | 32 |
| Dashboard والـ Drawer والملفات القديمة | عبر `AppLogo` التوافقي | أحجام صغيرة حسب الاستدعاء |

بهذا يكون الشعار بارزًا في Splash وLogin وRegister، وأصغر وأكثر هدوءًا في الصفحات الداخلية حتى لا يطغى على البيانات والبطاقات والتنقل.

## Asset Management

لم يحتج `pubspec.yaml` إلى تعديل جديد لأن المشروع يضم أصلًا:

```yaml
assets:
  - assets/
  - assets/images/
  - assets/animations/
```

الأصل الجديد موجود داخل `assets/images/` وسيتم تضمينه تلقائيًا في Flutter build. لم يتم تضمين الشعار كـ Base64، ولم يتم نسخ صور متعددة منه.

## الشعارات القديمة

أزيلت الاستخدامات المباشرة لـ `assets/images/logo.webp` من الشاشات المهمة. لم يعد MainShell أو Onboarding أو Login يستخدم الشعار القديم مباشرة. بقي الملف القديم إن كان موجودًا داخل مجلد الأصول فقط إلى حين التحقق من عدم استخدامه خارج Dart أو حذفِه في تنظيف لاحق؛ لا توجد له مراجع مباشرة داخل `lib`.

## Responsive وRTL/LTR

يتم وضع الشعار داخل `SafeArea` في Startup وOnboarding، وداخل AppBar أو الحاويات الحالية في الصفحات الداخلية. الحجم محدود بقيم ثابتة صغيرة أو حاويات معروفة، ولا يعتمد على `Positioned` خارج قيود الشاشة. التوجيه العربي والإنجليزي يبقى مسؤولية `Directionality` المحيط بكل شاشة، بينما الشعار نفسه ثابت ولا يتغير شكله عند تبديل اللغة.

## نتيجة التحقق

نجح `git diff --check`، وتم التأكد من وجود الأصل ومن وجود مراجع `SmartEnergyLogo` في المسارات الفعلية. لا يوجد Flutter أو Dart SDK داخل بيئة التنفيذ الحالية، لذلك لم يتم تشغيل `flutter analyze` أو بناء APK أو إثبات ظهور الشعار على جهاز فعلي من داخل هذه البيئة. يجب تنفيذ البناء والاختبار على Windows أو CI يحتوي Flutter SDK.

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter run
```

مسار اختبار التشغيل:

```text
Startup/Splash → Onboarding → Login → Register → Account Type → MainShell → Dashboard → Settings → Spaces → Devices → Subscription
```

ويجب التأكد بصريًا من العربية والإنجليزية وعلى شاشة صغيرة بعد البناء.

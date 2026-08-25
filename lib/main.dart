/// ═══════════════════════════════════════════════════════════════
/// نقطة الدخول الرئيسية — SmartEnergy App
/// ═══════════════════════════════════════════════════════════════
///
/// الوظيفة: تهيئة Firebase، إعداد Providers، والتوجيه بين الشاشات
///
/// خطوات التشغيل:
///   1. تهيئة Flutter Engine (WidgetsFlutterBinding)
///   2. الربط الفعلي بسحابة Firebase (initializeApp)
///   3. تفعيل خدمة الإشعارات (FCM)
///   4. إطلاق التطبيق مع Providers
///
/// ملاحظة: بدون سطر Firebase.initializeApp لن يتمكن التطبيق من:
///   - قراءة فولتية الكهرباء من ESP32
///   - التحكم في حالة الريلاي (Relay)
///   - إرسال/استقبال إشعارات الأمان
/// ═══════════════════════════════════════════════════════════════

// 1. استيراد مكتبة Flutter الأساسية للواجهات
import 'package:flutter/material.dart';
// 2. استيراد خدمة التحكم في شريط الحالة (Status Bar)
import 'package:flutter/services.dart';
// 2.5 استيراد مكتبة تأثيرات الزجاج (BackdropFilter)
// 3. استيراد المكتبة الأساسية للفايربيس — بدونها لا تعمل أي خدمة أخرى
import 'package:firebase_core/firebase_core.dart';
// 4. استيراد مكتبة إدارة الحالة (State Management)
import 'package:provider/provider.dart';
// 5. استيراد مكتبات الترجمة المحلية (العربية/الإنجليزية)
import 'package:flutter_localizations/flutter_localizations.dart';
// 6. استيراد التخزين المحلي للجلسات (هل أكمل التسجيل؟ نوع الحساب؟)
import 'package:shared_preferences/shared_preferences.dart';

// 7. استيراد ملف إعدادات Firebase الذي أنتجه FlutterFire CLI
//    يحتوي على مفاتيح API ومعرّفات المشروع لكل منصة (أندرويد/ويب/ويندوز)
import 'firebase_options.dart';
// 8. استيراد ثيم التطبيق الموحّد (ألوان، خطوط، أنماط)
import 'theme/app_theme.dart';
// 9. استيراد نظام الترجمة المحلي
import 'l10n/app_localizations.dart';
// 10. استيراد خدمة المصادقة (تسجيل الدخول بالهاتف OTP)
import 'services/auth_service.dart';
// 11. استيراد خدمة الإشعارات (FCM)
import 'services/notification_service.dart';
// 12. استيراد مزوّد بيانات الطاقة (يستمع لقراءات ESP32 اللحظية)
import 'providers/energy_provider.dart';
// 13. استيراد الشاشات — كل شاشة تمثل واجهة مستقلة في التطبيق
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/account_type_screen.dart';
import 'screens/main_shell.dart';

/// ═══════════════════════════════════════════════════════════════
/// دالة main — نقطة البداية لكل تطبيق Flutter
/// ═══════════════════════════════════════════════════════════════
///
/// الخطوات:
///   1. WidgetsFlutterBinding.ensureInitialized() — التأكد من جاهزية النظام
///   2. Firebase.initializeApp() — الربط الفعلي بسحابة Google
///   3. NotificationService.initialize() — تفعيل FCM
///   4. SystemChrome — تخصيص مظهر شريط الحالة
///   5. runApp() — إطلاق التطبيق
///
/// ملاحظة مهمة:
///   استخدام DefaultFirebaseOptions.currentPlatform يضمن أن التطبيق
///   سيعمل بنفس الكفاءة كـ تطبيق أندرويد أو كـ موقع ويب
/// ═══════════════════════════════════════════════════════════════
Future<void> main() async {
  // التأكد من أن جميع موارد النظام جاهزة قبل بدء الاتصال بالسحابة
  WidgetsFlutterBinding.ensureInitialized();

  // الربط الفعلي بالسحابة — محفوظ كما هو، مع حارس فشل لعرض Retry بدل الشاشة السوداء.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
  } catch (error) {
    runApp(_StartupFailureApp(message: error.toString()));
    return;
  }

  // تهيئة خدمة الإشعارات (FCM) مع مهلة حتى لا يتعطل البدء عند انقطاع الشبكة.
  try {
    await NotificationService.initialize().timeout(const Duration(seconds: 12));
  } catch (error) {
    debugPrint('Notification initialization skipped: $error');
  }

  // تخصيص مظهر شريط الحالة — شفاف مع أيقونات بيضاء للتوافق مع الثيم الداكن
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // قراءة حالة المظهر المحفوظة مسبقاً لمنع أي وميض
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('dark_mode') ?? false;

  // انطلاق التطبيق — يبدأ بـ SmartEnergyApp كجذر لشجرة الواجهات
  runApp(SmartEnergyApp(initialDarkMode: isDarkMode));
}

/// ═══════════════════════════════════════════════════════════════
/// كلاس التطبيق الرئيسي — SmartEnergyApp
/// ═══════════════════════════════════════════════════════════════
class SmartEnergyApp extends StatelessWidget {
  final bool initialDarkMode;
  const SmartEnergyApp({super.key, this.initialDarkMode = false});

  /// مفتاح التنقل العام — يُستخدم للتنقل بين الشاشات من أي مكان
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // MultiProvider — يوفر خدمات الحالة لجميع الشاشات الفرعية
    return MultiProvider(
      providers: [
        // مزوّد خدمة المصادقة — يُخطر الواجهات عند تغيّر حالة الدخول
        ChangeNotifierProvider(create: (_) => AuthService()),
        // مزوّد بيانات الطاقة — يستمع لقراءات ESP32 من Firebase RTDB
        ChangeNotifierProvider(create: (_) => EnergyProvider()),
        // مزوّد اللغة — يتحكم في تبديل العربية/الإنجليزية
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        // مزوّد المظهر — يتحكم في المظهر الداكن/المضيء مع الحالة المسبقة
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialDarkMode: initialDarkMode)),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) => MaterialApp(
          // مفتاح التنقل العام للوصول من أي خدمة
          navigatorKey: navigatorKey,
          // إخفاء شعار Debug
          debugShowCheckedModeBanner: false,
          title: 'SmartEnergy',
          // تطبيق الثيم بناءً على حالة المظهر
          theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          // اللغة الحالية من مزوّد اللغة
          locale: localeProvider.locale,

          // اللغات المدعومة — الإنجليزية والعربية
          supportedLocales: const [Locale('en'), Locale('ar')],
          // مندوبو الترجمة — يوفرون النصوص المترجمة لكل واجهة
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // الشاشة الأولى — موجّه التطبيق يحدد أين يذهب المستخدم
          home: const _AppRouter(),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// موجّه التطبيق — _AppRouter
/// ═══════════════════════════════════════════════════════════════
///
/// الوظيفة: يحدد الشاشة الأولى بناءً على حالة المصادقة
///
/// السيناريوهات:
///   1. المصادقة لم تُحسم بعد → شاشة انتظار (Loading)
///   2. المستخدم مسجّل الدخول → الشاشة الرئيسية (MainShell)
///   3. Onboarding لم يكتمل → شاشة الترحيب
///   4. Onboarding مكتمل → شاشة تسجيل الدخول
/// ═══════════════════════════════════════════════════════════════
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة المصادقة — يُعاد بناء الواجهة عند كل تغيير
    final auth = context.watch<AuthService>();

    // إذا لم تُحسم حالة المصادقة بعد → عرض مؤشر تحميل نيوني
    if (!auth.authResolved) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.15), blurRadius: 30)],
              ),
              child: const CircularProgressIndicator(
                color: AppTheme.accentCyan,
                strokeWidth: 3,
              ),
            ),
          ],
        )),
      );
    }

    // إذا المستخدم مسجّل الدخول → التحقق من إكمال البيانات ونوع الحساب أولاً
    if (auth.isLoggedIn) return const _PostLoginRouter();

    // التحقق هل أكمل المستخدم Onboarding من قبل
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance()
          .then((p) => p.getBool('onboarding_done') ?? false),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _StartupLoadingScreen(label: 'جارٍ تجهيز تجربة SmartEnergy');
        }
        if (snap.hasError) {
          return _StartupErrorScreen(onRetry: () => (ctx as Element).markNeedsBuild());
        }

        // إذا أكمل Onboarding → شاشة تسجيل الدخول
        if (snap.data == true) {
          return LoginScreen(onLoginSuccess: () {
            // بعد نجاح الدخول → التوجيه لموجّه ما بعد التسجيل
            SmartEnergyApp.navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const _PostLoginRouter()),
              (route) => false,
            );
          });
        }

        // إذا لم يكمل Onboarding → شاشة الترحيب أولاً
        return OnboardingScreen(onComplete: () async {
          // حفظ أن Onboarding اكتمل حتى لا يظهر مجدداً
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_done', true);

          // فحص context.mounted — ضروري بعد كل عملية async
          // لضمان أن الشاشة لا تزال موجودة قبل التنقل
          if (!ctx.mounted) return;

          SmartEnergyApp.navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen(
              onLoginSuccess: () {
                SmartEnergyApp.navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const _PostLoginRouter()),
                  (route) => false,
                );
              },
            )),
            (route) => false,
          );
        });
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════
/// موجّه ما بعد تسجيل الدخول — _PostLoginRouter
/// ═══════════════════════════════════════════════════════════════
///
/// الوظيفة: يتحقق هل أكمل المستخدم ملفه الشخصي واختار نوع حسابه
///
/// التدفق:
///   1. الملف الشخصي غير مكتمل → CompleteProfileScreen
///   2. نوع الحساب غير محدد → AccountTypeScreen
///   3. كل شيء مكتمل → MainShell (الشاشة الرئيسية)
/// ═══════════════════════════════════════════════════════════════
class _PostLoginRouter extends StatelessWidget {
  const _PostLoginRouter();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _StartupLoadingScreen(label: 'جارٍ تحميل ملفك الشخصي');
        }
        if (snap.hasError) {
          return _StartupErrorScreen(onRetry: () => (ctx as Element).markNeedsBuild());
        }
        if (!snap.hasData) {
          return const _StartupLoadingScreen(label: 'جارٍ تجهيز حسابك');
        }
        final prefs = snap.data!;

        // التحقق: هل أكمل المستخدم ملفه الشخصي؟
        final profileDone = prefs.getBool('profile_completed') ?? false;
        // التحقق: هل اختار نوع الحساب (شخصي/تجاري)؟
        final acctDone = prefs.getBool('account_type_selected') ?? false;

        // إذا لم يكمل الملف الشخصي → شاشة إكمال الملف
        if (!profileDone) {
          return CompleteProfileScreen(onComplete: () {
            SmartEnergyApp.navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const _PostLoginRouter()),
              (route) => false,
            );
          });
        }

        // إذا لم يختر نوع الحساب → شاشة اختيار النوع
        if (!acctDone) {
          return AccountTypeScreen(onComplete: () {
            SmartEnergyApp.navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainShell()),
              (route) => false,
            );
          });
        }

        // كل شيء مكتمل → الشاشة الرئيسية
        return MainShell();
      },
    );
  }
}



class _StartupFailureApp extends StatelessWidget {
  final String message;
  const _StartupFailureApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartEnergy',
      theme: AppTheme.darkTheme,
      home: _StartupErrorScreen(onRetry: () => main()),
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  final String label;
  const _StartupLoadingScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF10B981)]),
                boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.28), blurRadius: 30)],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 42),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _StartupErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppTheme.neonGreen, size: 64),
                const SizedBox(height: 20),
                const Text('تعذر تجهيز التطبيق', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Text('تحقق من الاتصال ثم أعد المحاولة. لم يتم فقدان أي بيانات.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.darkBg, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// نهاية ملف main.dart

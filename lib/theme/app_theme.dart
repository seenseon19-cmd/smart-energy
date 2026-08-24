import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// ═══════════════════════════════════════════════════════════════
/// 🟢 بداية: نظام ثيم Stitch الفاخر العالمي (Stitch Elite UI Design System)
/// هذا الملف يمثل حجر الأساس لكافة واجهات التطبيق البصرية.
/// تم نقله وحقنه بالكامل من مواصفات تصميم Stitch المعتمد بـ DESIGN.md
/// ═══════════════════════════════════════════════════════════════
class AppTheme {
  // ══════════════════════════════════════════════════════════════
  // 1. ألوان الهوية البصرية الرئيسية لمنصة Stitch (Material 3 Tokens)
  // ══════════════════════════════════════════════════════════════
  // 🔵 لون الخلفية السائلة الانسيابية الفاخرة المستوحاة من Stitch
  static const Color lightBg = Color(0xFFF8FAFC);
  // 🔵 لون الكروت الزجاجية البيضاء الأساسية الممتصة للضوء
  static const Color lightCard = Colors.white;
  // 🔵 لون النص الرئيسي الداكن عالي التباين
  static const Color lightText = Color(0xFF0F172A);
  // 🔵 لون النص الثانوي الرمادي المريح للعين
  static const Color lightTextSecondary = Color(0xFF64748B);
  // 🔵 لون الحدود الزجاجية الفاتحة والشفافة
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ══════════════════════════════════════════════════════════════
  // 2. ألوان الوضع المظلم العصري الفخم (Deep Slate & Navy Stitch)
  // ══════════════════════════════════════════════════════════════
  static const Color darkBg = Color(0xFF070C18);
  static const Color darkCard = Color(0xFF10192C);
  static const Color darkCardAlt = Color(0xFF1E2A42);
  static const Color darkText = Colors.white;
  static const Color darkBorder = Color(0xFF1E2A42);

  // ══════════════════════════════════════════════════════════════
  // 3. ألوان التمييز والمؤشرات الذكية والنيون المتوهج
  // ══════════════════════════════════════════════════════════════
  // 🟢 لون النيون المضيء السيان (Tertiary Fixed Dim) - مؤشرات الاتصال والتحكم
  static const Color neonCyan = Color(0xFF38BDF8);
  // 🟢 لون النيون الأخضر الفاخر - للأجهزة النشطة وحالات الأمان المستقرة
  static const Color neonGreen = Color(0xFF10B981);
  // 🟢 لون النيون الأحمر المتوهج - للتنبيهات وحالات زيادة الأحمال
  static const Color neonRed = Color(0xFFEF4444);
  // 🟢 لون النيون البرتقالي الدافئ - للمجدول والتحذيرات المتوسطة
  static const Color neonAmber = Color(0xFFF59E0B);
  
  // 🔵 ألوان العلامة التجارية الرئيسية — الأزرق الدافئ 0xFF2563EB
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF2563EB); // Warm Royal Blue Accent
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF6366F1);

  // ── التوافقية مع الأكواد القديمة ──
  static const Color textPrimary = lightText;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color iconCyanLight = accentCyan;
  static const Color iconGreenLight = neonGreen;
  static const Color iconRedLight = neonRed;
  static const Color iconAmberLight = neonAmber;
  static const Color iconBlueLight = primaryBlue;

  // ══════════════════════════════════════════════════════════════
  // 4. التدرجات اللونية الفاخرة للواجهات وأزرار النيون (Gradients)
  // ══════════════════════════════════════════════════════════════
  // 🔵 التدرج الذكي الرئيسي للأزرار التفاعلية الفاخرة من الأزرق إلى النيون
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 🟢 التدرج الأخضر المتوهج للأجهزة الفعالة والآمنة
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF006573)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔴 التدرج الأحمر للتحذيرات وحالات الخطر والمحاكاة الطارئة
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFBA1A1A), Color(0xFF93000A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🟠 التدرج البرتقالي لتنظيم الطاقة وجدول المواعيد
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 🟣 التدرج البنفسجي الأنيق للرؤى والتقارير المتقدمة
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF316BF3), Color(0xFF0051D5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 🟡 التدرج الذهبي الفاخر للخطط الممتازة والترقيات
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ══════════════════════════════════════════════════════════════
  // 5. زوايا الحواف الهندسية المرنة لـ Stitch (Rounded Borders)
  // ══════════════════════════════════════════════════════════════
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  // 🔵 انحناء الحواف الموحد في بطاقات Stitch الكبرى (24px)
  static const double radius2Xl = 24.0;
  // 🔵 انحناء الشاشات والكروت العملاقة (32px)
  static const double radius3Xl = 32.0;

  // ══════════════════════════════════════════════════════════════
  // 6. خلفية الشاشة الفاخرة للوضع المظلم/النهاري المعتمد لـ Stitch
  // ══════════════════════════════════════════════════════════════
  static BoxDecoration get darkBackgroundDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070C18), Color(0xFF0A1224), Color(0xFF060B16)],
        ),
      );

  static BoxDecoration get lightBackgroundDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFEDF2F7), Color(0xFFF1F5F9)],
        ),
      );

  static BoxDecoration get dashboardBackgroundDecoration => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF070C18), Color(0xFF0A1224), Color(0xFF060B16)],
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // 7. طبقات توهج النيون المحيطة المضيئة (Ambient Neon Blur Blobs)
  // ══════════════════════════════════════════════════════════════
  static List<Widget> buildGlowLayers() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [accentCyan.withOpacity(0.09), Colors.transparent],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -80,
        left: -80,
        child: Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [neonCyan.withOpacity(0.07), Colors.transparent],
            ),
          ),
        ),
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════
  // 8. بطاقة زجاجية فاخرة نهارية — Stitch Glassmorphism Card (Light)
  // تم ضبطها بدقة هندسية: تعتيم 92%، ضبابية 20px، حواف 24px/32px، وظل أزرق خفيف
  // ═══════════════════════════════════════════════════════════════
  static Widget glassCard({
    required Widget child,
    double radius = radius2Xl,
    bool isStrong = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.0,
        ),
        boxShadow: [
          // 🔵 الظل الأزرق المشرق المتوهج الحصري لمنصة Stitch
          BoxShadow(
            color: const Color(0x0D2563EB),
            blurRadius: isStrong ? 32 : 20,
            offset: Offset(0, isStrong ? 8 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: child,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 9. بطاقة زجاجية داكنة فخمة — Stitch Glassmorphism Card (Dark)
  // تستخدم للأجزاء المظلمة بتأثير التوهج النيوني الفاخر
  // ═══════════════════════════════════════════════════════════════
  static Widget darkGlassCard({
    required Widget child,
    double radius = radius2Xl,
    bool isStrong = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: isStrong ? 30 : 20,
            offset: const Offset(0, 6),
          ),
          // 🟢 وهج نيون أزرق داخلي خفيف
          BoxShadow(
            color: accentCyan.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: child,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 10. حاوية زجاجية شاملة (تغلف الكرت الزجاجي مع التوسيد الفاخر)
  // ═══════════════════════════════════════════════════════════════
  static Widget glassContainer({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double borderRadius = 24,
    Color? glowColor,
    double blurAmount = 20,
  }) {
    return Container(
      margin: margin,
      child: glassCard(
        radius: borderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 11. تفاصيل تصميم ديكور الزجاج الافتراضية
  // ═══════════════════════════════════════════════════════════════
  static BoxDecoration get glassmorphism => BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(radius2Xl),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D2563EB),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ══════════════════════════════════════════════════════════════
  // 12. تخصيص الخطوط والأنماط العربية — الخط Cairo الفاخر والمستقر
  // ══════════════════════════════════════════════════════════════
  static TextStyle getTextStyle({
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = lightText,
    FontStyle fontStyle = FontStyle.normal,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 13. ThemeData الشامل للتطبيق — متوافق مع نظام ألوان Stitch
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentCyan,
      surface: lightCard,
      error: neonRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: lightText,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textMuted,
    ),
    fontFamily: 'Cairo',
    useMaterial3: true,
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: neonCyan,
      surface: darkCard,
      error: neonRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: darkText,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBg,
      selectedItemColor: neonCyan,
      unselectedItemColor: darkBorder,
    ),
    fontFamily: 'Cairo',
    useMaterial3: true,
  );

  // ═══════════════════════════════════════════════════════════════
  // 14. دوال التوافقية للشاشات الحالية (لإبقاء واجهات التطبيق مستقرة تماماً)
  // ═══════════════════════════════════════════════════════════════
  static Color bgColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;
  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color cardAltColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardAlt : const Color(0xFFECEFD4);
  static Color textPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : lightText;
  static Color textMutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : textMuted;
  static Color textSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFFCBD5E1) : lightTextSecondary;
  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder.withOpacity(0.5);
  
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkCard : Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(radius2Xl),
      border: Border.all(color: isDark ? darkBorder : Colors.white.withOpacity(0.4)),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.3) : const Color(0x0D2563EB),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
/// 🔵 نهاية: نظام ثيم Stitch الفاخر العالمي

/// مزود المظهر — يدير حالة المظهر (داكن/مضيء) ويحفظها محلياً
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider({bool initialDarkMode = false}) : _isDarkMode = initialDarkMode {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getBool('dark_mode');
    if (savedMode != null && savedMode != _isDarkMode) {
      _isDarkMode = savedMode;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool val) async {
    _isDarkMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
}



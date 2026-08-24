/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة تسجيل الدخول — LoginScreen (Lovable Light Design)
/// ══════════════════════════════════════════════════════════════════════════════
// 🚨 تنبيه أمني صارم للذكاء الاصطناعي: ممنوع المساس بـ FirebaseAuth أو دوال الـ OTP أو دالة التحقق نهائياً!
// 🚨 حصر التعديل في الواجهة البصرية (UI Layout) داخل دالة build() لتطابق تصميم مجلد image lovable.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/screen_security_service.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../providers/energy_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // 🟢 حافظ على الـ TextControllers الحالية لربط الخدمات السحابية هنا
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedAccountType = 'residential'; // 'residential' or 'commercial'

  bool _isLoginMode = true;
  bool _isPhoneMethod = true;
  bool _showPassword = false;

  Timer? _resendTimer;
  int _resendSeconds = 60;

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        if (mounted) setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // 🟢 إضافة كائنات التركيز (FocusNodes) لحقول الإدخال لتغيير ألوانها عند التفاعل
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  bool _isPhoneFocused = false;
  bool _isOtpFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isNameFocused = false;
  bool _isAgeFocused = false;

  @override
  void initState() {
    super.initState();
    ScreenSecurityService.enable();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _phoneFocusNode.addListener(() => setState(() => _isPhoneFocused = _phoneFocusNode.hasFocus));
    _otpFocusNode.addListener(() => setState(() => _isOtpFocused = _otpFocusNode.hasFocus));
    _emailFocusNode.addListener(() => setState(() => _isEmailFocused = _emailFocusNode.hasFocus));
    _passwordFocusNode.addListener(() => setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus));
    _nameFocusNode.addListener(() => setState(() => _isNameFocused = _nameFocusNode.hasFocus));
    _ageFocusNode.addListener(() => setState(() => _isAgeFocused = _ageFocusNode.hasFocus));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();

    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          // 🟢 بداية: تدرج الخلفية الانسيابي الفاخر — Light Glassmorphic Gradient
          Container(
            decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
          ),
          // 🔵 نهاية: تدرج الخلفية الانسيابي

          // 🟢 بداية: طبقات النيون المتوهجة المحيطة من خلفية ثيم Stitch
          ...AppTheme.buildGlowLayers(),
          // 🔵 نهاية: طبقات النيون

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🟢 بداية: شعار التطبيق المحدث بالوهج والظل الفاخر بنظام Stitch
                  _buildAnimatedLogo(),
                  const SizedBox(height: 32),
                  // 🔵 نهاية: شعار التطبيق

                  // 🟢 بداية: كرت العرض الزجاجي الفاخر الممتد (.glass-card) الخاص بواجهة الدخول لشاشة Stitch _1
                  _buildLightGlassCard(loc, auth),
                  const SizedBox(height: 24),
                  // 🔵 نهاية: كرت العرض الزجاجي

                  // 🟢 بداية: كارت ملاحظة الوضع التجريبي المطابق لحواف Stitch الدائرية
                  _buildDemoNote(loc),
                  const SizedBox(height: 16),
                  // 🔵 نهاية: ملاحظة الوضع التجريبي
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // الشعار المتوهج العلوي
  // ══════════════════════════════════════════════════════════════
  Widget _buildAnimatedLogo() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Column(
        children: [
          // 🟢 بداية: الحاوية المتوهجة بالظل النيوني للأزرق الرئيسي لـ Stitch
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppTheme.darkBorder.withOpacity(0.3) : Colors.white.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.25 * _glowAnimation.value),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.webp',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.bolt,
                  size: 44,
                  color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          // 🔵 نهاية: الحاوية المتوهجة
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "الطاقة ",
                style: AppTheme.getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.darkText : const Color(0xFF191C21),
                ),
              ),
              Text(
                "الذكية",
                style: AppTheme.getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "بوابة التحكم الآمنة والمستدامة",
            style: AppTheme.getTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText.withOpacity(0.7) : const Color(0xFF414751),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // الكرت الزجاجي المضيء الرئيسي
  // ══════════════════════════════════════════════════════════════
  Widget _buildLightGlassCard(AppLocalizations loc, AuthService auth) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    
    final cardChild = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🟢 بداية: شريط التبديل الزجاجي الانسيابي الدائري المطابق لتصميم Stitch _1
          _buildSegmentedControl(loc),
          const SizedBox(height: 28),
          // 🔵 نهاية: شريط التبديل

          Text(
            _isLoginMode ? loc.tr('welcomeLogin') : loc.tr('signUp'),
            style: AppTheme.getTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isLoginMode ? loc.tr('loginSubtitle') : "أنشئ حساباً للتحكم الكامل في طاقتك",
            style: AppTheme.getTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 28),

          // 🟢 بداية: شريط تبويب طريقة التسجيل (هاتف / بريد) بتصميم زجاجي ناعم
          _buildMethodTabs(loc),
          const SizedBox(height: 24),
          // 🔵 نهاية: شريط تبويب طريقة التسجيل

            // نموذج الحقول الحية بناءً على الوضع المحدد (مؤمن بالكامل من الناحية الأمنية)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isPhoneMethod ? _buildPhoneMode(loc, auth) : _buildEmailMode(loc, auth),
            ),

            // 🟢 بداية: خيار الدخول كزائر (يظهر فقط في وضع تسجيل الدخول)
            if (_isLoginMode) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "أو",
                      style: AppTheme.getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 0.8)),
                ],
              ),
              const SizedBox(height: 20),
              _InteractiveScale(
                onTap: () async {
                  _autoSaveUserProfile(name: 'زائر الطاقة الذكية', phone: '+218910000000');
                  if (context.mounted) widget.onLoginSuccess();
                  auth.sendOTP('910000000');
                  auth.verifyOTP('123456');
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      "متابعة كزائر",
                      style: AppTheme.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // 🔵 نهاية: خيار الدخول كزائر
          ],
        ),
      );

      return isDark
          ? AppTheme.darkGlassCard(
              radius: AppTheme.radius3Xl,
              isStrong: true,
              child: cardChild,
            )
          : AppTheme.glassCard(
              radius: AppTheme.radius3Xl,
              isStrong: true,
              child: cardChild,
            );
  }

  // ══════════════════════════════════════════════════════════════
  // مبدل الوضع (دخول / تسجيل)
  // ══════════════════════════════════════════════════════════════
  Widget _buildSegmentedControl(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FA), // لون surface-container-low من Stitch
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _segmentBtn(
              loc.tr('signIn'),
              _isLoginMode,
              () => setState(() => _isLoginMode = true),
            ),
          ),
          Expanded(
            child: _segmentBtn(
              loc.tr('signUp'),
              !_isLoginMode,
              () => setState(() => _isLoginMode = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentBtn(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: AppTheme.getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // مبدل الطريقة (هاتف / بريد إلكتروني)
  // ══════════════════════════════════════════════════════════════
  Widget _buildMethodTabs(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: _methodTab(
            loc.tr('loginWithPhone'),
            Icons.phone_iphone_rounded,
            _isPhoneMethod,
            () {
              final auth = context.read<AuthService>();
              auth.clearError();
              setState(() => _isPhoneMethod = true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _methodTab(
            loc.tr('loginWithEmail'),
            Icons.alternate_email_rounded,
            !_isPhoneMethod,
            () {
              final auth = context.read<AuthService>();
              auth.clearError();
              setState(() => _isPhoneMethod = false);
            },
          ),
        ),
      ],
    );
  }

  Widget _methodTab(
      String text, IconData icon, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppTheme.primaryBlue.withOpacity(0.2) : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTheme.getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? AppTheme.primaryBlue : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // وضع الهاتف — Phone Mode (OTP Flow محفوظ بالكامل)
  // ══════════════════════════════════════════════════════════════
  Widget _buildPhoneMode(AppLocalizations loc, AuthService auth) {
    if (!auth.otpSent) return _buildPhoneInput(loc, auth);
    return _buildOtpInput(loc, auth);
  }

  Widget _buildPhoneInput(AppLocalizations loc, AuthService auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟢 حقل إدخال رقم الهاتف المحدث بنظام زجاج Stitch الداخلي الفخم (.glass-input)
        _buildPhoneField(loc),
        _buildErrorText(auth, 'invalid_phone', loc.tr('invalidPhone')),
        const SizedBox(height: 28),

        // 🟢 زر الإرسال المتدرج الفاخر لـ Stitch المتوهج
        _buildSubmitButton(
          label: loc.tr('sendOtp'),
          isLoading: auth.isLoading,
          onPressed: () async {
            await auth.sendOTP(_phoneController.text);
            _startResendTimer();
          },
        ),
      ],
    );
  }

  Widget _buildOtpInput(AppLocalizations loc, AuthService auth) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط تأكيد إرسال الرمز
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neonGreen.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.neonGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${loc.tr('otpSent')} ${auth.displayPhone}',
                  style: AppTheme.getTextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 🟢 حقل إدخال رمز OTP الزجاجي الناعم من Stitch
        Text(
          loc.tr('otpCode'),
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _isOtpFocused
                ? (isDark ? AppTheme.darkCard : Colors.white)
                : (isDark ? AppTheme.darkBg : const Color(0xFFF2F3FA)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isOtpFocused
                  ? (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue)
                  : (isDark ? AppTheme.darkBorder.withOpacity(0.3) : Colors.white.withOpacity(0.5)),
              width: _isOtpFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isOtpFocused)
                BoxShadow(
                  color: (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue).withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                )
            ],
          ),
          child: TextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: AppTheme.getTextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
            ).copyWith(letterSpacing: 10),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: '••••••',
              hintStyle: TextStyle(
                color: isDark ? AppTheme.darkText.withOpacity(0.3) : Colors.grey,
                letterSpacing: 8,
              ),
            ),
          ),
        ),
        _buildErrorText(auth, 'invalid_otp', loc.tr('invalidOtp')),
        const SizedBox(height: 24),

        // زر التحقق
        _buildSubmitButton(
          label: loc.tr('verify'),
          isLoading: auth.isLoading,
          onPressed: () async {
            final ok = await auth.verifyOTP(_otpController.text);
            if (ok && context.mounted) widget.onLoginSuccess();
          },
        ),
        const SizedBox(height: 8),
        Center(
          child: _resendSeconds > 0
              ? Text(
                  '${loc.tr('resendIn')} $_resendSeconds ${loc.tr('seconds')}',
                  style: AppTheme.getTextStyle(
                    color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : TextButton(
                  onPressed: () async {
                    await auth.sendOTP(_phoneController.text);
                    _startResendTimer();
                  },
                  child: Text(
                    loc.tr('resendOtp'),
                    style: AppTheme.getTextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // حقل الهاتف مع مفتاح ليبيا 🇱🇾 +218
  // ══════════════════════════════════════════════════════════════
  Widget _buildPhoneField(AppLocalizations loc) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.tr('phoneNumber'),
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isPhoneFocused
                ? (isDark ? AppTheme.darkCard : Colors.white)
                : (isDark ? AppTheme.darkBg : const Color(0xFFF2F3FA)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isPhoneFocused
                  ? (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue)
                  : (isDark ? AppTheme.darkBorder.withOpacity(0.3) : Colors.white.withOpacity(0.5)),
              width: _isPhoneFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isPhoneFocused)
                BoxShadow(
                  color: (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue).withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
            ],
          ),
          child: Row(
            children: [
              Text(
                "🇱🇾 +218",
                style: AppTheme.getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkText : const Color(0xFF191C21),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 20,
                color: isDark ? AppTheme.darkBorder.withOpacity(0.5) : Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  style: AppTheme.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "91 234 5678",
                    hintStyle: TextStyle(
                      color: isDark ? AppTheme.darkText.withOpacity(0.4) : Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // وضع البريد الإلكتروني — Email Mode (تسجيل الدخول السريع)
  // ══════════════════════════════════════════════════════════════
  Widget _buildEmailMode(AppLocalizations loc, AuthService auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // حقل البريد الإلكتروني
        _buildField(
          Icons.alternate_email_rounded,
          loc.tr('email'),
          _emailController,
          loc.tr('emailHint'),
          focusNode: _emailFocusNode,
          isFocused: _isEmailFocused,
        ),
        _buildErrorText(auth, 'invalid_email', loc.tr('invalidEmail')),
        _buildErrorText(auth, 'email_not_found', loc.tr('emailNotFound')),
        _buildErrorText(auth, 'email_in_use', loc.tr('emailInUse')),
        const SizedBox(height: 16),

        // حقل كلمة المرور
        _buildField(
          Icons.lock_outline_rounded,
          loc.tr('password'),
          _passwordController,
          '••••••••',
          isPassword: true,
          focusNode: _passwordFocusNode,
          isFocused: _isPasswordFocused,
        ),
        _buildErrorText(auth, 'weak_password', loc.tr('weakPassword')),
        _buildErrorText(auth, 'wrong_password', loc.tr('wrongPassword')),
        _buildErrorText(auth, 'email_auth_failed', loc.tr('emailAuthFailed')),
        _buildErrorText(auth, 'too_many_requests', loc.tr('tooManyRequests')),
        _buildErrorText(auth, 'user_disabled', loc.tr('userDisabled')),

        // 🟢 رابط "نسيت كلمة السر؟"
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _showForgotPasswordDialog(context, auth),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'نسيت كلمة السر؟',
              style: AppTheme.getTextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // زر تسجيل الدخول
        _buildSubmitButton(
          label: loc.tr('signIn'),
          isLoading: auth.isLoading,
          onPressed: () => _handleEmailAuth(auth),
        ),
        const SizedBox(height: 16),

        // زر التوجيه لشاشة إنشاء حساب جديد (المرحلة 1)
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: Text.rich(TextSpan(
              text: loc.tr('noAccount'),
              style: AppTheme.getTextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
              ),
              children: [
                TextSpan(
                  text: ' ${loc.tr('signUp')}',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // مكونات مشتركة — Shared Components
  // ══════════════════════════════════════════════════════════════

  /// 🟢 مراجعة وتعديل: حقل إدخال ناعم بتصميم Stitch يدعم التفاعل مع حالة التركيز (Focus)
  Widget _buildField(IconData icon, String label,
      TextEditingController controller, String hint,
      {bool isPassword = false, required FocusNode focusNode, required bool isFocused}) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isFocused
                ? (isDark ? AppTheme.darkCard : Colors.white)
                : (isDark ? AppTheme.darkBg : const Color(0xFFF2F3FA)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isFocused
                  ? (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue)
                  : (isDark ? AppTheme.darkBorder.withOpacity(0.3) : Colors.white.withOpacity(0.5)),
              width: isFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  color: (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue).withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isFocused
                    ? (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue)
                    : (isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && !_showPassword,
                  style: AppTheme.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: isDark ? AppTheme.darkText.withOpacity(0.4) : Colors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 18,
                    color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.textMuted,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🟢 مراجعة وتأكيد: تم حقن تصميم Stitch للزر وتأكيد ربطه بالـ Controller المسؤول عن المصادقة دون تعديل المنطق الخلفي
  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return _InteractiveScale(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: AppTheme.getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
        ),
      ),
    );
  }

  /// نص الخطأ المرتبط بـ AuthService
  Widget _buildErrorText(
      AuthService auth, String errorKey, String displayText) {
    if (auth.errorMessage != errorKey) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.accentRed, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(displayText,
                  style: AppTheme.getTextStyle(
                      color: AppTheme.accentRed, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// ملاحظة الوضع التجريبي
  Widget _buildDemoNote(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentAmber.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.science_rounded,
              color: AppTheme.accentAmber, size: 16),
          const SizedBox(width: 8),
          Text(
            loc.tr('demoModeNote'),
            style: AppTheme.getTextStyle(
                fontSize: 12,
                color: AppTheme.accentAmber,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, AuthService auth) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final resetEmailCtrl = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3)),
          ),
          title: Text(
            'استعادة كلمة المرور',
            style: AppTheme.getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أدخل بريدك الإلكتروني المسجل لإرسال رابط إعادة تعيين كلمة المرور:',
                style: AppTheme.getTextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTheme.getTextStyle(
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'user@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: AppTheme.getTextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final email = resetEmailCtrl.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(ctx);
                final ok = await auth.sendPasswordResetEmail(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك بنجاح ✅'
                          : 'تعذر إرسال الرابط. تأكد من صحة البريد وأعد المحاولة.'),
                      backgroundColor: ok ? AppTheme.neonGreen : AppTheme.neonRed,
                    ),
                  );
                }
              },
              child: Text('إرسال الرابط', style: AppTheme.getTextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🔒 دوال المصادقة — Auth Logic لتسجيل الدخول السريع
  // ══════════════════════════════════════════════════════════════
  Future<void> _handleEmailAuth(AuthService auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني'), backgroundColor: AppTheme.neonRed),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كلمة المرور'), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    _autoSaveUserProfile(email: email);
    final ok = await auth.signInWithEmail(email, password);
    if (ok) {
      final energyProvider = Provider.of<EnergyProvider>(context, listen: false);
      await energyProvider.reloadUserData();
      if (context.mounted) widget.onLoginSuccess();
    }
  }

  Future<void> _autoSaveUserProfile({String? name, String? phone, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (name != null && name.isNotEmpty) {
      await prefs.setString('profile_display_name', name);
      if (uid != null && uid.isNotEmpty) await prefs.setString('display_name_$uid', name);
    }
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString('profile_phone', phone);
      if (uid != null && uid.isNotEmpty) await prefs.setString('simulated_phone_$uid', phone);
    }
    if (email != null && email.isNotEmpty) {
      await prefs.setString('profile_email', email);
      if (uid != null && uid.isNotEmpty) await prefs.setString('profile_email_$uid', email);
    }
  }
}

/// 🟢 بداية: حاوية التفاعل التلمسي الحركي (Stitch Interactive Scale Effect)
/// تدعم انكماش الحجم بنسبة 98% عند الضغط وسلاسة التأثير
class _InteractiveScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _InteractiveScale({required this.child, this.onTap});

  @override
  State<_InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<_InteractiveScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}
/// 🔵 نهاية: حاوية التفاعل التلمسي

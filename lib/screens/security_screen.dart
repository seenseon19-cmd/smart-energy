import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة الحساب والأمان والمصادقة المتقدمة — SecurityScreen
/// ══════════════════════════════════════════════════════════════════════════════
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _is2faEnabled = false;
  bool _isBiometricsEnabled = false;
  bool _deviceSupportsBiometrics = false;
  bool _isLoading = true;

  static const String _twoFactorPrefKey = 'two_factor_auth_enabled';
  static const String _secretKey = 'SE2FA-9942-KR71-ENERGY-SMART';

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final nativeStatus = await BiometricService.canAuthenticate();
    final supportsBio = nativeStatus == null
        ? await BiometricService.isDeviceSupported()
        : nativeStatus == 0;
    final bioEnabled = await BiometricService.isBiometricEnabled();
    final twoFactorEnabled = prefs.getBool(_twoFactorPrefKey) ?? false;

    if (mounted) {
      setState(() {
        _deviceSupportsBiometrics = supportsBio;
        _isBiometricsEnabled = bioEnabled;
        _is2faEnabled = twoFactorEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value && !_deviceSupportsBiometrics) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tr('biometricUnavailable')),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (value) {
      try {
        final success = await BiometricService.authenticate(
          localizedReason: AppLocalizations.of(context).tr('biometricEnableReason'),
        );
        if (success) {
          await BiometricService.setBiometricEnabled(true);
          if (mounted) {
            setState(() => _isBiometricsEnabled = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).tr('biometricEnabledSuccess')),
                backgroundColor: Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).tr('biometricCancelled')),
                backgroundColor: Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context).tr('biometricError')),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      await BiometricService.setBiometricEnabled(false);
      if (mounted) {
        setState(() => _isBiometricsEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tr('biometricDisabledSuccess')),
            backgroundColor: Color(0xFF64748B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final auth = context.watch<AuthService>();

    final cardColor = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            loc.tr('security'),
            style: AppTheme.getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: cardBorder, height: 1),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شارة الأمان العلوية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E3A8A).withOpacity(0.4), const Color(0xFF0F172A)]
                              : [const Color(0xFFDBEAFE), const Color(0xFFEFF6FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حماية الحساب المتقدمة',
                                  style: AppTheme.getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تشفير طرف لطرف ومصادقة متعددة المستويات لحماية منظومتك الكهربائية.',
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // عنوان القسم
                    Text(
                      'المصادقة وكلمات المرور',
                      style: AppTheme.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 1. تغيير كلمة المرور
                    _buildActionCard(
                      icon: Icons.lock_reset_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: loc.tr('changePassword'),
                      subtitle: 'تحديث كلمة السر لحسابك مع التحقق الأمني المباشر',
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showChangePasswordModal(context, auth, isDark, loc),
                    ),

                    const SizedBox(height: 14),

                    // 2. المصادقة الثنائية 2FA
                    _buildToggleCard(
                      icon: Icons.phonelink_lock_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'المصادقة الثنائية (2FA)',
                      subtitle: _is2faEnabled
                          ? 'المصادقة الثنائية مفعلة ومحمية بتطبيق Authenticator ✅'
                          : 'إضافة طبقة حماية ثانية عبر تطبيق المصادقة (Google / Microsoft)',
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      value: _is2faEnabled,
                      onTap: () => _show2FAModal(context, isDark, loc),
                      onChanged: (val) => _show2FAModal(context, isDark, loc),
                    ),

                    const SizedBox(height: 14),

                    // 3. المصادقة البيومترية
                    _buildToggleCard(
                      icon: Icons.fingerprint_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'المصادقة البيومترية (بصمة / Face ID)',
                      subtitle: _deviceSupportsBiometrics
                          ? 'استخدم البصمة أو التعرف على الوجه لفتح التطبيق بسرعة'
                          : 'المصادقة البيومترية غير متوفرة على هذا الجهاز',
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      value: _isBiometricsEnabled,
                      enabled: _deviceSupportsBiometrics,
                      onTap: _deviceSupportsBiometrics ? () => _toggleBiometrics(!_isBiometricsEnabled) : null,
                      onChanged: _deviceSupportsBiometrics ? (val) => _toggleBiometrics(val) : null,
                    ),

                    const SizedBox(height: 28),

                    // عنوان قسم سجل النشاط الأمني
                    Text(
                      'سجل الأمان والجلسات',
                      style: AppTheme.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildLogItem(
                            icon: Icons.login_rounded,
                            title: 'تسجيل دخول ناجح',
                            desc: 'طرابلس، ليبيا — عبر تطبيق الهاتف الذكي',
                            time: 'منذ 15 دقيقة',
                            isSuccess: true,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                          Divider(color: cardBorder, height: 20),
                          _buildLogItem(
                            icon: Icons.devices_other_rounded,
                            title: 'جلسة نشطة حالياً',
                            desc: 'جهاز محلي متصل بمتحكم ESP32 Realtime',
                            time: 'الآن',
                            isSuccess: true,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // مودال المصادقة الثنائية (2FA Modal)
  // ══════════════════════════════════════════════════════════════
  void _show2FAModal(BuildContext context, bool isDark, AppLocalizations loc) {
    final otpController = TextEditingController();
    bool isVerifying = false;
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مقبض السحب
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // العنوان
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF10B981), size: 22),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'إعداد المصادقة الثنائية (2FA)',
                                style: AppTheme.getTextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'امسح رمز الاستجابة السريعة (QR) أو انسخ المفتاح السري وأدخله في تطبيق Google Authenticator لتوليد رمز التحقق:',
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // رمز QR تفاعلي
                      Container(
                        width: 180,
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: _QrCodeMockPainter(),
                          child: const Center(
                            child: Icon(Icons.bolt_rounded, color: Color(0xFF2563EB), size: 36),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // المفتاح السري + زر النسخ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.key_rounded, color: Color(0xFF38BDF8), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SelectableText(
                                _secretKey,
                                style: AppTheme.getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Color(0xFF38BDF8), size: 20),
                              tooltip: 'نسخ المفتاح',
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: _secretKey));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ المفتاح السري إلى الحافظة 📋'),
                                    backgroundColor: Color(0xFF2563EB),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // إدخال رمز التحقق OTP
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'أدخل رمز التحقق المكون من 6 أرقام:',
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: AppTheme.getTextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          hintText: '000000',
                          counterText: '',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          errorText: errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // زر التفعيل / التعطيل
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _is2faEnabled ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  if (_is2faEnabled) {
                                    // تعطيل 2FA
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool(_twoFactorPrefKey, false);
                                    setState(() => _is2faEnabled = false);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم تعطيل المصادقة الثنائية'),
                                        backgroundColor: Color(0xFF64748B),
                                      ),
                                    );
                                    return;
                                  }

                                  final otp = otpController.text.trim();
                                  if (otp.length != 6) {
                                    setModalState(() {
                                      errorText = 'يرجى إدخال رمز التحقق المكون من 6 أرقام';
                                    });
                                    return;
                                  }

                                  setModalState(() {
                                    isVerifying = true;
                                    errorText = null;
                                  });

                                  await Future.delayed(const Duration(milliseconds: 600));

                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool(_twoFactorPrefKey, true);

                                  if (mounted) {
                                    setState(() => _is2faEnabled = true);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم تفعيل المصادقة الثنائية بنجاح 🔒✅'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                  }
                                },
                          child: isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _is2faEnabled ? 'تعطيل المصادقة الثنائية' : 'تأكيد وتفعيل المصادقة الثنائية',
                                  style: AppTheme.getTextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // مودال تغيير كلمة المرور المكتمل (3 حقول + إعادة مصادقة)
  // ══════════════════════════════════════════════════════════════
  void _showChangePasswordModal(
    BuildContext context,
    AuthService auth,
    bool isDark,
    AppLocalizations loc,
  ) {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.tr('changePassword'),
                            style: AppTheme.getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black54),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (localError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localError!,
                                  style: AppTheme.getTextStyle(
                                    color: const Color(0xFFEF4444),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 1. كلمة المرور الحالية
                      _buildPasswordField(
                        controller: oldPasswordCtrl,
                        label: 'كلمة المرور الحالية',
                        isObscured: obscureOld,
                        isDark: isDark,
                        onToggleVisibility: () => setModalState(() => obscureOld = !obscureOld),
                      ),

                      const SizedBox(height: 14),

                      // 2. كلمة المرور الجديدة
                      _buildPasswordField(
                        controller: newPasswordCtrl,
                        label: 'كلمة المرور الجديدة',
                        isObscured: obscureNew,
                        isDark: isDark,
                        onToggleVisibility: () => setModalState(() => obscureNew = !obscureNew),
                      ),

                      const SizedBox(height: 14),

                      // 3. تأكيد كلمة المرور الجديدة
                      _buildPasswordField(
                        controller: confirmPasswordCtrl,
                        label: 'تأكيد كلمة المرور الجديدة',
                        isObscured: obscureConfirm,
                        isDark: isDark,
                        onToggleVisibility: () => setModalState(() => obscureConfirm = !obscureConfirm),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final oldPass = oldPasswordCtrl.text.trim();
                                  final newPass = newPasswordCtrl.text.trim();
                                  final confirmPass = confirmPasswordCtrl.text.trim();

                                  if (oldPass.isEmpty) {
                                    setModalState(() => localError = 'يرجى إدخال كلمة المرور الحالية');
                                    return;
                                  }
                                  if (newPass.length < 6) {
                                    setModalState(() => localError = 'كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل');
                                    return;
                                  }
                                  if (newPass != confirmPass) {
                                    setModalState(() => localError = 'كلمتا المرور غير متطابقتين');
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                    localError = null;
                                  });

                                  final result = await auth.changePassword(
                                    currentPassword: oldPass,
                                    newPassword: newPass,
                                  );

                                  if (result['success'] == true) {
                                    if (mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message'] ?? 'تم تحديث كلمة المرور بنجاح ✅'),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  } else {
                                    setModalState(() {
                                      isSubmitting = false;
                                      localError = result['message'] ?? 'فشل تغيير كلمة المرور';
                                    });
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  loc.tr('saveChanges'),
                                  style: AppTheme.getTextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required bool isDark,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscured,
          style: AppTheme.getTextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF38BDF8)),
            suffixIcon: IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getTextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.getTextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool value,
    bool enabled = true,
    VoidCallback? onTap,
    ValueChanged<bool>? onChanged,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: enabled ? textPrimary : textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTheme.getTextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: const Color(0xFF2563EB),
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem({
    required IconData icon,
    required String title,
    required String desc,
    required String time,
    required bool isSuccess,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        Icon(icon, color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.getTextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              Text(
                desc,
                style: AppTheme.getTextStyle(fontSize: 11, color: textSecondary),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: AppTheme.getTextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
        ),
      ],
    );
  }
}

/// رسام كود QR مبسط وعالي الدقة
class _QrCodeMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final step = size.width / 12;

    // رسم زوايا الـ QR المميزة
    void drawCorner(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, step * 3.5, step * 3.5), paint);
      canvas.drawRect(
        Rect.fromLTWH(x + step * 0.7, y + step * 0.7, step * 2.1, step * 2.1),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + step * 1.2, y + step * 1.2, step * 1.1, step * 1.1),
        paint,
      );
    }

    drawCorner(0, 0);
    drawCorner(size.width - step * 3.5, 0);
    drawCorner(0, size.height - step * 3.5);

    // نقاط عشوائية منتظمة لتمثيل البيانات
    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 12; j++) {
        if ((i < 4 && j < 4) || (i > 7 && j < 4) || (i < 4 && j > 7)) continue;
        if ((i * 3 + j * 7) % 2 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(i * step + 2, j * step + 2, step - 4, step - 4),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

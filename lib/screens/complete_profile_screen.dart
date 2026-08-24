/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إكمال الملف الشخصي — CompleteProfileScreen (Stage 2: Personal Information)
/// المرحلة الثانية: الاسم الكامل + رقم الهاتف + العمر
/// ══════════════════════════════════════════════════════════════════════════════

import '../services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/secure_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../services/screen_security_service.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../core/app_animations.dart';

class CompleteProfileScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const CompleteProfileScreen({super.key, required this.onComplete});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _agreedToTerms = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    ScreenSecurityService.enable();
    _loadExistingUserData();
  }

  Future<void> _loadExistingUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _fullNameCtrl.text = user.displayName!;
      }
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        _phoneCtrl.text = user.phoneNumber!;
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue(AppLocalizations loc) async {
    final fullName = _fullNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final ageStr = _ageCtrl.text.trim();
    final age = int.tryParse(ageStr) ?? 0;

    if (fullName.isEmpty || phone.isEmpty || ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول للمتابعة'), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    if (age <= 0 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال عمر صحيح'), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tr('mustAgreeTerms')), backgroundColor: AppTheme.accentAmber),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SecureStorageService.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      await prefs.setString('user_full_name', fullName);
      await prefs.setString('profile_display_name', fullName);
      await prefs.setString('display_name', fullName);
      await prefs.setString('profile_phone', phone);
      await prefs.setInt('user_age', age);
      await prefs.setBool('profile_completed', true);

      if (uid != null && uid.isNotEmpty) {
        await prefs.setString('display_name_$uid', fullName);
        await prefs.setString('simulated_phone_$uid', phone);
        try {
          await FirebaseDatabase.instance.ref('users/$uid').update({
            'fullName': fullName,
            'phone': phone,
            'age': age.toString(),
            'profileCompleted': true,
            'updatedAt': ServerValue.timestamp,
          });
        } catch (e) {
          AppLogger.debug('Firebase profile update error: $e');
        }
      }

      if (mounted) {
        final auth = Provider.of<AuthService>(context, listen: false);
        await auth.updateDisplayName(fullName);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حفظ البيانات: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // مؤشر الخطوة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_forward_rounded, color: textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'الخطوة 2 من 3',
                          style: AppTheme.getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // أنيميشن الترحيب وإكمال البيانات
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Lottie.network(
                        AppAnimations.welcomeOnboarding,
                        fit: BoxFit.contain,
                        repeat: true,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue).withOpacity(0.12),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.userPen,
                            color: isDark ? AppTheme.neonCyan : AppTheme.accentCyan,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'إكمال الملف الشخصي',
                      style: AppTheme.getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'يرجى إدخال اسمك ورقم هاتفك لتخصيص حسابك',
                      style: AppTheme.getTextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // حقول الإدخال
                  _glassField('الاسم الكامل', _fullNameCtrl, FontAwesomeIcons.user, isDark: isDark),
                  const SizedBox(height: 16),
                  _glassField('رقم الهاتف', _phoneCtrl, FontAwesomeIcons.phone, keyboardType: TextInputType.phone, isDark: isDark),
                  const SizedBox(height: 16),
                  _glassField('العمر (بالسنوات)', _ageCtrl, FontAwesomeIcons.cakeCandles, keyboardType: TextInputType.number, isDark: isDark),
                  const SizedBox(height: 20),

                  // شروط الاستخدام
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                        activeColor: AppTheme.primaryBlue,
                        checkColor: Colors.white,
                        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                      Expanded(
                        child: Text(
                          'أوافق على شروط الخدمة وسياسة الخصوصية',
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // زر المتابعة
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : () => _saveAndContinue(loc),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'التالي (نوع الحساب)',
                                  style: AppTheme.getTextStyle(
                                    fontSize: 16,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassField(
    String label,
    TextEditingController ctrl,
    dynamic icon, {
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10192C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: AppTheme.getTextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.lightText),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTheme.getTextStyle(color: isDark ? Colors.white60 : AppTheme.lightTextSecondary, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: FaIcon(
                icon,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      );
}

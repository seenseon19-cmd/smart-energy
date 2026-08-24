/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إنشاء الحساب — RegisterScreen (Stage 1: Account Credentials)
/// المرحلة الأولى: البريد الإلكتروني + كلمة المرور + تأكيد كلمة المرور
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import 'complete_profile_screen.dart';
import 'account_type_screen.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(AuthService auth) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال البريد الإلكتروني'), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين'), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    final success = await auth.signUpWithEmail(email, password);

    if (success && mounted) {
      // الانتقال فوراً للمرحلة الثانية: إكمال الملف الشخصي
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(
            onComplete: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => AccountTypeScreen(
                    onComplete: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                    },
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ),
        (route) => false,
      );
    } else if (mounted && auth.errorMessage != null) {
      final loc = AppLocalizations.of(context);
      final errorMsg = auth.errorMessage == 'email_in_use'
          ? 'هذا البريد الإلكتروني مسجل مسبقاً. يرجى تسجيل الدخول.'
          : (auth.errorMessage == 'weak_password'
              ? 'كلمة المرور ضعيفة جداً'
              : loc.tr('authFailed'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppTheme.neonRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final auth = context.watch<AuthService>();
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF070C18) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // شعار التطبيق
                  AppLogo(
                    isDark: isDark,
                    fontSize: 26,
                    iconSize: 32,
                    isHorizontal: true,
                  ),
                  const SizedBox(height: 24),

                  // كرت إنشاء الحساب
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // خطوة 1 من 3
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إنشاء حساب جديد',
                              style: AppTheme.getTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'الخطوة 1 من 3',
                                style: AppTheme.getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'أدخل بيانات الدخول الأساسية للبدء في إدارة طاقتك',
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. البريد الإلكتروني
                        _buildInputField(
                          label: 'البريد الإلكتروني',
                          hint: 'user@example.com',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // 2. كلمة المرور
                        _buildInputField(
                          label: 'كلمة المرور',
                          hint: '••••••••',
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          showPassword: _showPassword,
                          onTogglePassword: () => setState(() => _showPassword = !_showPassword),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // 3. تأكيد كلمة المرور
                        _buildInputField(
                          label: 'تأكيد كلمة المرور',
                          hint: '••••••••',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          showPassword: _showConfirmPassword,
                          onTogglePassword: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 28),

                        // زر إنشاء الحساب والمتابعة
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            onPressed: auth.isLoading ? null : () => _handleRegister(auth),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'متابعة (الخطوة التالية)',
                                        style: AppTheme.getTextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
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
                  const SizedBox(height: 20),

                  // العودة لتسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟',
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'تسجيل الدخول',
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: isPassword && !showPassword,
                  keyboardType: keyboardType,
                  style: AppTheme.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.lightText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  onPressed: onTogglePassword,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

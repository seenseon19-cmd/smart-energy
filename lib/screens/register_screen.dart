/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إنشاء الحساب — RegisterScreen (Stage 1: Account Credentials)
/// المرحلة الأولى: البريد الإلكتروني + كلمة المرور + تأكيد كلمة المرور
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/screen_security_service.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/app_logo.dart';
import 'complete_profile_screen.dart';
import 'account_type_screen.dart';
import 'main_shell.dart';
import 'privacy_policy_screen.dart';

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
  bool _acceptedPolicies = false;

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
    final loc = AppLocalizations.of(context);

    if (!_acceptedPolicies) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.tr('registrationConsentRequired')), backgroundColor: AppTheme.neonRed));
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tr('enterEmail')), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tr('passwordMinLength')), backgroundColor: AppTheme.neonRed),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.tr('passwordsMismatch')), backgroundColor: AppTheme.neonRed),
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
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final auth = context.watch<AuthService>();
    const textPrimary = Colors.white;
    final cardBg = const Color(0xFF141B2B).withOpacity(0.88);
    final cardBorder = Colors.white.withOpacity(0.16);

    return Directionality(
      textDirection: loc.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF070E1D),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/stitch_auth_bg.png'),
                    fit: BoxFit.cover,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.30), const Color(0xFF070E1D).withOpacity(0.95)],
                  ),
                  backgroundBlendMode: BlendMode.darken,
                ),
              ),
            ),
            SafeArea(
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
                              loc.tr('signUp'),
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
                                '${loc.tr('step')} 1 ${loc.tr('of')} 3',
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
                          loc.tr('signupCredentialsHint'),
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.68),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. البريد الإلكتروني
                        _buildInputField(
                          label: loc.tr('email'),
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
                          label: loc.tr('password'),
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
                          label: loc.tr('confirmPassword'),
                          hint: '••••••••',
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          showPassword: _showConfirmPassword,
                          onTogglePassword: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                          isDark: isDark,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(value: _acceptedPolicies, onChanged: (v) => setState(() => _acceptedPolicies = v ?? false)),
                            Expanded(child: Padding(
                              padding: const EdgeInsets.only(top: 11),
                              child: Wrap(children: [
                                Text('${loc.tr('iAgreeTo')} '),
                                GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())), child: Text(loc.tr('privacyTerms'), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800))),
                              ]),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                            onPressed: auth.isLoading || !_acceptedPolicies || _emailController.text.trim().isEmpty || _passwordController.text.length < 6 || _passwordController.text != _confirmPasswordController.text ? null : () => _handleRegister(auth),
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
                                        loc.tr('nextStep'),
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
                        loc.tr('alreadyHaveAccount'),
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          loc.tr('login'),
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
                  onChanged: (_) => setState(() {}),
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
        ),
      ),
    );
  }
}

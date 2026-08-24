import '../services/app_logger.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../providers/energy_provider.dart';
import '../core/app_animations.dart';
import 'main_shell.dart';

class AccountTypeScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const AccountTypeScreen({super.key, required this.onComplete});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen>
    with SingleTickerProviderStateMixin {
  bool? _isCommercial;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
          ..forward();
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_isCommercial == null) return;
    final isComm = _isCommercial!;
    final accountType = isComm ? 'commercial' : 'residential';
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    await prefs.setBool('account_type_commercial', isComm);
    await prefs.setBool('account_type_selected', true);
    await prefs.setString('account_type', accountType);
    await prefs.setBool('account_type_locked', true);

    if (uid != null && uid.isNotEmpty) {
      await prefs.setString('account_type_$uid', accountType);
      await prefs.setBool('account_type_locked_$uid', true);
      try {
        await FirebaseDatabase.instance.ref('users/$uid').update({
          'accountType': accountType,
          'accountTypeCommercial': isComm,
          'accountTypeLocked': true,
          'updatedAt': ServerValue.timestamp,
        });
      } catch (e) {
        AppLogger.debug('Firebase update account type error: $e');
      }
    }

    if (mounted) {
      final energyProvider = Provider.of<EnergyProvider>(context, listen: false);
      energyProvider.setPlanType(isComm);
      await energyProvider.reloadUserData();
    }

    // انتقال وحيد وقسري إلى الشاشة الرئيسية بعد اكتمال الحفظ.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
          ),

          // طبقات التوهج النيوني
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(isDark ? 0.12 : 0.06),
                    blurRadius: 160,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(isDark ? 0.10 : 0.05),
                    blurRadius: 160,
                  ),
                ],
              ),
            ),
          ),

          // المحتوى
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // أنيميشن التحويل التفاعلي
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_isCommercial == true
                                  ? AppTheme.neonGreen
                                  : AppTheme.neonCyan)
                              .withOpacity(isDark ? 0.12 : 0.08),
                          border: Border.all(
                            color: (_isCommercial == true
                                    ? AppTheme.neonGreen
                                    : (isDark ? AppTheme.neonCyan : AppTheme.accentCyan))
                                .withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isCommercial == true
                                      ? AppTheme.neonGreen
                                      : AppTheme.neonCyan)
                                  .withOpacity(0.2),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Lottie.network(
                            _isCommercial == true
                                ? AppAnimations.resToCom
                                : (_isCommercial == false
                                    ? AppAnimations.comToRes
                                    : AppAnimations.welcomeOnboarding),
                            key: ValueKey(_isCommercial),
                            fit: BoxFit.contain,
                            repeat: true,
                            errorBuilder: (_, __, ___) => Center(
                              child: FaIcon(
                                FontAwesomeIcons.boltLightning,
                                size: 40,
                                color: isDark ? AppTheme.neonCyan : AppTheme.accentCyan,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // العنوان الرئيسي
                      Text(
                        "اختر نوع حسابك",
                        style: AppTheme.getTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "حدد كيف تريد إدارة استهلاك الطاقة",
                        style: AppTheme.getTextStyle(
                          fontSize: 14,
                          color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // كرت النوع الشخصي
                      _buildTypeCard(
                        title: "شخصي",
                        subtitle: "Personal",
                        description: "مراقبة طاقة المنزل والتحكم الذكي",
                        icon: FontAwesomeIcons.houseUser,
                        isSelected: _isCommercial == false,
                        activeColor: AppTheme.neonCyan,
                        onTap: () => setState(() => _isCommercial = false),
                      ),
                      const SizedBox(height: 16),

                      // كرت النوع التجاري
                      _buildTypeCard(
                        title: "تجاري",
                        subtitle: "Commercial",
                        description: "ذكاء الطاقة للأعمال والمنشآت المتعددة",
                        icon: FontAwesomeIcons.buildingShield,
                        isSelected: _isCommercial == true,
                        activeColor: AppTheme.neonGreen,
                        onTap: () => setState(() => _isCommercial = true),
                      ),
                      const SizedBox(height: 44),

                      // زر المتابعة
                      AnimatedOpacity(
                        opacity: _isCommercial != null ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              gradient: _isCommercial == null
                                  ? const LinearGradient(
                                      colors: [Color(0xFF2A3548), Color(0xFF1E2A3B)])
                                  : LinearGradient(
                                      colors: _isCommercial == false
                                          ? [
                                              AppTheme.primaryBlue,
                                              AppTheme.neonCyan,
                                            ]
                                          : [
                                              const Color(0xFF059669),
                                              AppTheme.neonGreen,
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              boxShadow: _isCommercial != null
                                  ? [
                                      BoxShadow(
                                        color: (_isCommercial == false
                                                ? AppTheme.neonCyan
                                                : AppTheme.neonGreen)
                                            .withOpacity(0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  _isCommercial != null ? _saveAndContinue : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusLg),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "متابعة",
                                    style: AppTheme.getTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required String description,
    required dynamic icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
          border: Border.all(
            color: isSelected 
                ? activeColor.withOpacity(0.6) 
                : (isDark ? AppTheme.darkBorder.withOpacity(0.2) : Colors.black.withOpacity(0.08)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.18),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0x0D2563EB),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          activeColor.withOpacity(0.12),
                          isDark ? AppTheme.darkCard : Colors.white.withOpacity(0.92),
                        ]
                      : [
                          isDark ? AppTheme.darkBg.withOpacity(0.6) : Colors.white.withOpacity(0.95),
                          isDark ? AppTheme.darkCard.withOpacity(0.3) : Colors.white.withOpacity(0.85),
                        ],
                ),
              ),
              child: Row(
                children: [
                  // أيقونة النوع
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? activeColor.withOpacity(0.15)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                      border: Border.all(
                        color: isSelected
                            ? activeColor.withOpacity(0.4)
                            : (isDark ? AppTheme.darkBorder.withOpacity(0.2) : Colors.black.withOpacity(0.08)),
                      ),
                    ),
                    child: FaIcon(
                      icon,
                      size: 26,
                      color: isSelected ? activeColor : (isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary.withOpacity(0.6)),
                    ),
                  ),
                  const SizedBox(width: 18),

                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: AppTheme.getTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              subtitle,
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? activeColor
                                    : (isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary.withOpacity(0.7)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: AppTheme.getTextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // مؤشر الاختيار
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? activeColor
                            : (isDark ? AppTheme.darkBorder : Colors.black.withOpacity(0.2)),
                        width: 2,
                      ),
                      color: isSelected ? activeColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
import '../l10n/app_localizations.dart';
import '../widgets/smart_energy_logo.dart';
import '../widgets/lottie_widgets.dart';
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
    final loc = AppLocalizations.of(context);

    return Directionality(
      textDirection: loc.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: const Color(0xFF070E1D),
      body: Stack(
        children: [
          // خلفية متدرجة
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/stitch_space_bg.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.28), const Color(0xFF070E1D).withOpacity(0.95)],
              ),
              backgroundBlendMode: BlendMode.darken,
            ),
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
                      const SmartEnergyLogo(size: 82),
                      const SizedBox(height: 8),
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
                        child: PremiumLottie(
                          key: ValueKey(_isCommercial),
                          assetPath: AppAnimations.conceptSmartHome,
                          width: 100,
                          height: 100,
                          fallbackIcon: FontAwesomeIcons.house,
                          fallbackColor: isDark ? AppTheme.neonCyan : AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // العنوان الرئيسي
                      Text(
                        loc.tr('selectAccountType'),
                        style: AppTheme.getTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.tr('manageSpacesDesc'),
                        style: AppTheme.getTextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.72),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // كرت النوع الشخصي
                      _buildTypeCard(
                        title: loc.tr('personal'),
                        subtitle: loc.tr('personal'),
                        description: loc.tr('personalDesc'),
                        icon: FontAwesomeIcons.houseUser,
                        isSelected: _isCommercial == false,
                        activeColor: AppTheme.neonCyan,
                        onTap: () => setState(() => _isCommercial = false),
                      ),
                      const SizedBox(height: 16),

                      // كرت النوع التجاري
                      _buildTypeCard(
                        title: loc.tr('commercial'),
                        subtitle: loc.tr('commercial'),
                        description: loc.tr('commercialDesc'),
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
                                    loc.tr('continueBtn'),
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
                          activeColor.withOpacity(0.20),
                          const Color(0xFF141B2B).withOpacity(0.88),
                        ]
                      : [
                          const Color(0xFF141B2B).withOpacity(0.76),
                          const Color(0xFF232A3A).withOpacity(0.68),
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
                                color: Colors.white,
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
                            color: Colors.white.withOpacity(0.72),
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

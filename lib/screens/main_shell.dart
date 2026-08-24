import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/energy_provider.dart'; // مزود البيانات
import '../l10n/app_localizations.dart';
import 'dashboard_screen.dart';
import 'devices_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'subscription_screen.dart';
import 'profile_screen.dart';
import 'alerts_protection_screen.dart';
import 'spaces_screen.dart'; // 🟢 بداية: استيراد شاشة إدارة المساحات
import 'security_screen.dart';
import 'login_screen.dart';
import '../widgets/app_logo.dart';

/// ═══════════════════════════════════════════════════════════════
/// القشرة الرئيسية — MainShell (Stitch Dark Premium Shell Design)
/// ═══════════════════════════════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    DashboardScreen(),
    DevicesScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final provider = context.watch<EnergyProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // طبقات النيون المتوهجة المحيطية لتضفي عمقاً زجاجياً خلف الشاشات الفرعية
            if (isDark) ...AppTheme.buildGlowLayers(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(loc, isDark, provider),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: _buildDrawer(context, loc, isDark),
        bottomNavigationBar: _buildBottomNav(loc, isDark),
      ),
    );
  }

  /// ── الشريط العلوي النحيف (Stitch Glassmorphism Header) ──
  Widget _buildTopBar(AppLocalizations loc, bool isDark, EnergyProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟢 بداية: زر ترويسة هامبرغر انسيابي ثلاثي الأسطر مع ارتداد لمسي
          _InteractiveScale(
            key: const Key('hamburger_menu_btn'),
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                ),
              ),
              child: const FaIcon(
                FontAwesomeIcons.bars,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // 🔵 نهاية: زر ترويسة هامبرغر
          
          // 🟢 بداية: شعار الترويسة الموحد "SmartEnergy" مع الشعار الرسمي
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.webp',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppTheme.neonCyan, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Smart',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              Text(
                'Energy',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          // 🔵 نهاية: شعار الترويسة الموحد
 
          // 🟢 بداية: كبسولة البث المباشر مع وميض نيون متحرك
          Consumer<EnergyProvider>(builder: (context, ep, _) {
            final isLive = ep.isConnected;
            final statusColor = isLive ? AppTheme.neonGreen : const Color(0xFF94A3B8);
            final statusText = isLive ? loc.tr('liveStream') : loc.tr('offline');

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: statusColor.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: AppTheme.getTextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
          // 🔵 نهاية: كبسولة البث المباشر
        ],
      ),
    );
  }

  /// ── شريط التنقل السفلي نظيف وهادئ بدون توهج مشع ──
  Widget _buildBottomNav(AppLocalizations loc, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10192C) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, loc.tr('theDashboard'), isDark),
              _navItem(1, Icons.devices_rounded, loc.tr('devices'), isDark),
              _navItem(2, Icons.bar_chart_rounded, loc.tr('statistics'), isDark),
              _navItem(3, Icons.settings_rounded, loc.tr('settings'), isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return _InteractiveScale(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E2A42) : const Color(0xFFEFF6FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : inactiveColor,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ── القائمة الجانبية المحدثة (Stitch Dark Translucent Drawer) ──
  Widget _buildDrawer(BuildContext context, AppLocalizations loc, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // شعار SmartEnergy الموحد في القائمة الجانبية
              Center(
                child: AppLogo(
                  isDark: isDark,
                  fontSize: 18,
                  iconSize: 22,
                  isHorizontal: true,
                ),
              ),
              const SizedBox(height: 32),

              // 🟢 روابط القائمة الجانبية المحدثة كاملة مع ارتداد لمسي
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _drawerItem(Icons.dashboard_rounded, loc.tr('theDashboard'), 0, isDark),
                      _drawerItem(Icons.memory_rounded, loc.tr('devices'), 1, isDark),
                      _drawerItem(Icons.bar_chart_rounded, loc.tr('statistics'), 2, isDark),
                      _drawerItem(Icons.layers_rounded, loc.tr('spacesLabel'), -1, isDark),
                      _drawerItem(Icons.workspace_premium_rounded, loc.tr('subscriptions'), -2, isDark),
                      _drawerItem(Icons.shield_rounded, loc.tr('security'), -3, isDark),
                      _drawerItem(Icons.settings_rounded, loc.tr('settings'), 3, isDark),
                      _drawerItem(Icons.person_rounded, loc.tr('theProfile'), -4, isDark),
                    ],
                  ),
                ),
              ),

              // 🟢 باقة المشترك الحالية ديناميكياً بناءً على حالة الـ Provider
              Consumer<EnergyProvider>(
                builder: (context, provider, child) {
                  final isCommercial = provider.isCommercial;
                  final planName = isCommercial ? loc.tr('ultimateLabel') : loc.tr('professionalLabel');
                  final badgeColor = isCommercial
                      ? AppTheme.neonGreen
                      : (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: badgeColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: badgeColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${loc.tr('plan')}: $planName',
                            style: AppTheme.getTextStyle(
                              fontSize: 12,
                              color: badgeColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              // تسجيل الخروج
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _InteractiveScale(
                  onTap: () async {
                    Navigator.pop(context);
                    final auth = context.read<AuthService>();
                    final energy = context.read<EnergyProvider>();
                    await energy.clearSession();
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            onLoginSuccess: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const MainShell()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.01),
                      border: Border.all(color: AppTheme.neonRed.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: AppTheme.neonRed, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          loc.tr('signOutLabel'),
                          style: AppTheme.getTextStyle(
                            fontSize: 14,
                            color: AppTheme.neonRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, int targetIndex, bool isDark) {
    final isActive = targetIndex >= 0 && _currentIndex == targetIndex;
    final activeColor = isDark ? AppTheme.neonCyan : AppTheme.primaryBlue;
    final inactiveColor = isDark ? Colors.white.withOpacity(0.55) : AppTheme.lightTextSecondary.withOpacity(0.65);
    final textColor = isActive
        ? (isDark ? Colors.white : AppTheme.lightText)
        : (isDark ? Colors.white.withOpacity(0.7) : AppTheme.lightTextSecondary);

    return _InteractiveScale(
      onTap: () {
        Navigator.pop(context);
        if (targetIndex >= 0) {
          setState(() => _currentIndex = targetIndex);
        } else {
          // التنقل للشاشات الفرعية
          Widget? screen;
          if (targetIndex == -1) screen = const SpacesScreen();
          if (targetIndex == -2) screen = const SubscriptionScreen();
          if (targetIndex == -3) screen = const SecurityScreen();
          if (targetIndex == -4) screen = const ProfileScreen();
          if (screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? Colors.white.withOpacity(0.06) : activeColor.withOpacity(0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? activeColor.withOpacity(0.2) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTheme.getTextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (isActive) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 20,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🟢 حاوية التفاعل التلمسي الحركي (Stitch Interactive Scale Effect)
// ═══════════════════════════════════════════════════════════════
class _InteractiveScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _InteractiveScale({super.key, required this.child, this.onTap});

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

// ═══════════════════════════════════════════════════════════════
// 🟢 وجيدة النبض المستمر للبث المباشر (Stitch Pulsing Dot)
// ═══════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const _PulsingDot({required this.color, this.size = 8});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6 + 0.4 * value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 + 0.4 * value),
                blurRadius: 4 + (6 * value),
                spreadRadius: 1 + (2 * value),
              ),
            ],
          ),
        );
      },
    );
  }
}

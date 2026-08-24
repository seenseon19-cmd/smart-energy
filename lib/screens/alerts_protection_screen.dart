/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة الأمان والحماية — AlertsProtectionScreen (Safety Screen - Stitch Dark Design)
/// الوظيفة: التحكم في حد القدرة العالمي، الفصل التلقائي، ومحاكاة الطوارئ.
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../core/app_animations.dart';

class AlertsProtectionScreen extends StatefulWidget {
  const AlertsProtectionScreen({super.key});

  @override
  State<AlertsProtectionScreen> createState() => _AlertsProtectionScreenState();
}

class _AlertsProtectionScreenState extends State<AlertsProtectionScreen> {
  double _powerLimit = 5000;
  bool _autoDisconnect = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 🟢 تحميل الإعدادات الأمنية المحفوظة محلياً (لا يتم مساس منطق الخلفية)
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _powerLimit = prefs.getDouble('power_limit') ?? 5000;
      _autoDisconnect = prefs.getBool('auto_disconnect') ?? true;
    });
  }

  /// 🟢 حفظ الإعدادات الأمنية محلياً عند تغييرها من قبل المستخدم
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) await prefs.setDouble(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  Widget _buildCard({required Widget child, double radius = 24, bool isStrong = false, bool isDark = false}) {
    return isDark
        ? AppTheme.darkGlassCard(radius: radius, isStrong: isStrong, child: child)
        : AppTheme.glassCard(radius: radius, isStrong: isStrong, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final currentLoad = provider.energyData.power;
    final loadPercentage = (currentLoad / _powerLimit) * 100;

    return Container(
      decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
      child: Stack(
        children: [
          // طبقات النيون المتوهجة المحيطية لتضفي عمقاً زجاجياً خلف الكروت
          ...AppTheme.buildGlowLayers(),

          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: Text(
                loc.tr('alertsProtection'),
                style: AppTheme.getTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppTheme.darkText : AppTheme.lightText),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // 🚨 راية تحذير حمراء متوهجة إذا كان تفعيل الحمل الزائد نشطاً
                  if (provider.isSimulatingOverload) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.redGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonRed.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Lottie.asset(
                              AppAnimations.overloadWarning,
                              fit: BoxFit.contain,
                              repeat: true,
                              errorBuilder: (_, __, ___) => const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('overloadWarning'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.tr('autoDisconnectExplain'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ══════════════════════════════════════
                  // 🟢 كرت حد القدرة العالمي - تصميم Stitch _6 زجاج فاتح
                  // ══════════════════════════════════════
                  _buildCard(
                    isDark: isDark,
                    radius: AppTheme.radius3Xl,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.tr('globalPowerLimitTitle'),
                                      style: AppTheme.getTextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      loc.tr('loadPercentage'),
                                      style: AppTheme.getTextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // شاشة العرض الرقمية والنسبة المئوية للحمل
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.04) : AppTheme.primaryBlue.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${_powerLimit.toInt()}',
                                      style: AppTheme.getTextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'W',
                                        style: AppTheme.getTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.accentCyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentCyan.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: AppTheme.accentCyan.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    '${loadPercentage.toInt()}%',
                                    style: AppTheme.getTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.accentCyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // مؤشر السحب الزلق (Slider Theme) ممتد وعريض نيون سيان
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.accentCyan,
                              inactiveTrackColor: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.3),
                              thumbColor: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                              overlayColor: AppTheme.accentCyan.withOpacity(0.15),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                            ),
                            child: Slider(
                              value: _powerLimit,
                              min: 1000,
                              max: 10000,
                              divisions: 18,
                              onChanged: (v) {
                                  setState(() => _powerLimit = v);
                                  _saveSetting('power_limit', v);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // الاستهلاك الحالي ومراقبة الحالة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentCyan.withOpacity(0.5),
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${loc.tr('currentConsumption')}: ${currentLoad.toInt()} W',
                                style: AppTheme.getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════
                  // 🟢 الكرت الثاني: كبسولة الفصل التلقائي الذكية
                  // ══════════════════════════════════════
                  _buildCard(
                    isDark: isDark,
                    radius: AppTheme.radius2Xl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('autoDisconnectOnOverload'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.tr('autoDisconnectExplain'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _autoDisconnect,
                            onChanged: (v) {
                              setState(() => _autoDisconnect = v);
                              _saveSetting('auto_disconnect', v);
                            },
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.neonGreen,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ══════════════════════════════════════
                  // 🟢 الكرت الثالث: بطاقة محاكاة حالة الطوارئ المتوهجة نيون أحمر
                  // ══════════════════════════════════════
                  _buildCard(
                    isDark: isDark,
                    radius: AppTheme.radius3Xl,
                    isStrong: true,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppTheme.neonRed.withOpacity(0.4) : AppTheme.neonRed.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(AppTheme.radius3Xl),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonRed.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.neonRed.withOpacity(0.2)),
                                ),
                                child: const Icon(Icons.warning_rounded, color: AppTheme.neonRed, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                loc.tr('emergencySimulation'),
                                style: AppTheme.getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loc.tr('emergencyExplain'),
                            style: AppTheme.getTextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // أزرار الطوارئ المتلاصقة هندسياً
                          Row(
                            children: [
                              // زر إعادة التشغيل الشفاف
                              Expanded(
                                child: _InteractiveScale(
                                  onTap: () {
                                    provider.resetSystem();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loc.tr('systemResetSuccess')),
                                        backgroundColor: AppTheme.neonGreen,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                                      border: Border.all(color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      loc.tr('resetSystem'),
                                      textAlign: TextAlign.center,
                                      style: AppTheme.getTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // زر الكارثة المتوهج بالأحمر الفاقع
                              Expanded(
                                child: _InteractiveScale(
                                  onTap: () {
                                    provider.simulateOverload();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loc.tr('overloadTriggered')),
                                        backgroundColor: AppTheme.neonRed,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.redGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.neonRed.withOpacity(0.35),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      loc.tr('triggerOverload'),
                                      textAlign: TextAlign.center,
                                      style: AppTheme.getTextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ══════════════════════════════════════
                  // 🟢 السجلات الأمنية الأخيرة
                  // ══════════════════════════════════════
                  Text(
                    loc.tr('securityLogs'),
                    style: AppTheme.getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildSecurityLogs(loc, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> _buildSecurityLogs(AppLocalizations loc, bool isDark) {
    final logs = [
      {'icon': Icons.login_rounded, 'color': AppTheme.neonGreen, 'title': loc.tr('loginAttempt'), 'detail': 'IP: 192.168.1.x', 'time': '14:32'},
      {'icon': Icons.settings_rounded, 'color': AppTheme.accentAmber, 'title': loc.tr('settingsChanged'), 'detail': loc.tr('autoDisconnect'), 'time': '13:15'},
      {'icon': Icons.warning_amber_rounded, 'color': AppTheme.neonRed, 'title': loc.tr('overloadAlert'), 'detail': '4,200W → 3,800W', 'time': '11:48'},
      {'icon': Icons.login_rounded, 'color': AppTheme.neonGreen, 'title': loc.tr('loginAttempt'), 'detail': 'Mobile App', 'time': '10:05'},
      {'icon': Icons.shield_rounded, 'color': AppTheme.accentCyan, 'title': loc.tr('twoFactorAuth'), 'detail': loc.tr('twoFAEnabled'), 'time': '09:22'},
      {'icon': Icons.warning_amber_rounded, 'color': AppTheme.neonRed, 'title': loc.tr('overloadAlert'), 'detail': '5,100W → 3,500W', 'time': '08:30'},
    ];
    return logs.map((log) {
      final cardChild = Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (log['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (log['color'] as Color).withOpacity(0.2)),
              ),
              child: Icon(log['icon'] as IconData, color: log['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log['title'] as String,
                    style: AppTheme.getTextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkText : AppTheme.lightText),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    log['detail'] as String,
                    style: AppTheme.getTextStyle(fontSize: 11, color: (isDark ? AppTheme.darkText : AppTheme.lightTextSecondary).withOpacity(0.6), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Text(
              log['time'] as String,
              style: AppTheme.getTextStyle(fontSize: 11, color: (isDark ? AppTheme.darkText : AppTheme.lightTextSecondary).withOpacity(0.5), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: isDark
            ? AppTheme.darkGlassCard(radius: 16, child: cardChild)
            : AppTheme.glassCard(radius: 16, child: cardChild),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════
// 🟢 حاوية التفاعل التلمسي الحركي (Stitch Interactive Scale Effect)
// ═══════════════════════════════════════════════════════════════
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

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة الإعدادات — SettingsScreen
/// تقتصر على إعدادات التطبيق العامة: مظهر التطبيق، التنبيهات، اللغة، الأمان والحماية، والدعم
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/lottie_widgets.dart';
import 'alerts_protection_screen.dart';
import 'security_screen.dart';
import 'reports_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    setState(() => _notificationsEnabled = val);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = themeProvider.isDarkMode;

    final cardBg = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accentBlue = Color(0xFF38BDF8);

    final currentLangLabel = localeProvider.locale.languageCode == 'ar' ? 'العربية' : 'English';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            loc.tr('settings'),
            style: AppTheme.getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1️⃣ المظهر والواجهة (Appearance)
                _buildSectionHeader('المظهر والتخصيص', accentBlue),
                _buildGroupCard(
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.nightlight_round, color: accentBlue, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('darkMode'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  isDark ? 'الوضع المظلم مفعل' : 'الوضع المضيء مفعل',
                                  style: AppTheme.getTextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          LottieThemeToggle(
                            isDark: isDark,
                            onToggle: (val) => themeProvider.setTheme(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2️⃣ اللغة والإشعارات (General Preferences)
                _buildSectionHeader('اللغة والتنبيهات', accentBlue),
                _buildGroupCard(
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      iconColor: AppTheme.primaryBlue,
                      title: loc.tr('language'),
                      sideValue: currentLangLabel,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showLanguageModal(context, localeProvider, isDark),
                    ),
                    _buildDivider(isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.neonAmber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_active_outlined, color: AppTheme.neonAmber, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              loc.tr('notifications'),
                              style: AppTheme.getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            activeColor: AppTheme.primaryBlue,
                            onChanged: _toggleNotifications,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3️⃣ الأمان والحماية الذكية
                _buildSectionHeader('الأمان والحماية', accentBlue),
                _buildGroupCard(
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      iconColor: AppTheme.neonGreen,
                      title: 'تنبيهات وحماية الأحمال الكهربائية',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsProtectionScreen()),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      iconColor: accentBlue,
                      title: 'الأمان المتقدم والمصادقة الثنائية (2FA)',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SecurityScreen()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4️⃣ التقارير والدعم الفني
                _buildSectionHeader('التقارير والدعم الفني', accentBlue),
                _buildGroupCard(
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.analytics_outlined,
                      iconColor: AppTheme.primaryBlue,
                      title: 'تقارير استهلاك الطاقة الشهرية',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.headset_mic_outlined,
                      iconColor: accentBlue,
                      title: loc.tr('supportCenter'),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showSupportModal(context, isDark),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppTheme.neonCyan,
                      title: loc.tr('aboutApp'),
                      sideValue: 'v1.0.0',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showAboutModal(context, isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 8),
      child: Text(
        title,
        style: AppTheme.getTextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required Color cardBg,
    required Color cardBorder,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? sideValue,
    required Color textPrimary,
    required Color textSecondary,
    VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTheme.getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
            if (sideValue != null) ...[
              Text(
                sideValue,
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (showChevron)
              Icon(Icons.chevron_left_rounded, size: 20, color: textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52,
      color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9),
    );
  }

  void _showLanguageModal(BuildContext context, LocaleProvider localeProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختيار لغة التطبيق',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('العربية (Arabic) 🇱🇾', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: localeProvider.locale.languageCode == 'ar'
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('ar'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('English (الإنجليزية) 🇺🇸', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: localeProvider.locale.languageCode == 'en'
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مركز الدعم والمساعدة',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 12),
              const Text('فريق الدعم الفني جاهز لمساعدتك على مدار الساعة بشأن الأجهزة والمراقبة.'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: AppTheme.primaryBlue),
                title: const Text('البريد الإلكتروني للدعم'),
                subtitle: const Text('support@smartenergy.ly'),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: AppTheme.neonGreen),
                title: const Text('الخط الساخن المباشر'),
                subtitle: const Text('+218 21 000 0000'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutModal(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('عن تطبيق SmartEnergy', style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text(
            'منظومة SmartEnergy هي الحل الذكي الرائد لمراقبة وإدارة استهلاك الطاقة وحماية الشبكات الكهربائية المنزلية والتجارية في ليبيا بتقنيات إنترنت الأشياء (IoT).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

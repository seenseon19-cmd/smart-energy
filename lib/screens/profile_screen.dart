/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة الملف الشخصي — ProfileScreen
/// تقتصر على: صورة المستخدم، الاسم، رقم الحساب الموحد، نوع الحساب، الاشتراك، وسجل النشاط
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/secure_storage_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../providers/energy_provider.dart';
import 'activity_log_screen.dart';
import 'login_screen.dart';
import 'subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SecureStorageService.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final path = (uid != null && uid.isNotEmpty)
        ? await prefs.getString('profile_image_path_$uid')
        : await prefs.getString('profile_image_path_guest');
    if (mounted) setState(() => _profileImagePath = path);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (image != null) {
      final prefs = await SecureStorageService.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await prefs.setString('profile_image_path_$uid', image.path);
      } else {
        await prefs.setString('profile_image_path_guest', image.path);
      }
      setState(() => _profileImagePath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthService>();
    final provider = context.watch<EnergyProvider>();
    final isDark = themeProvider.isDarkMode;

    final fbUser = FirebaseAuth.instance.currentUser;
    final displayName = auth.displayName.isNotEmpty
        ? auth.displayName
        : (fbUser?.displayName?.isNotEmpty == true ? fbUser!.displayName! : 'المستخدم');

    final isConnected = provider.isConnected;
    final accountNumber = auth.accountNumber.isNotEmpty ? auth.accountNumber : 'ES-99284-HOM/COM';

    final cardBg = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accentBlue = Color(0xFF38BDF8);

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
            loc.tr('theProfile'),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // 1. هيدر الملف الشخصي (الصورة، الاسم، رقم الحساب، حالة الاتصال)
                _buildHeader(
                  context,
                  isDark: isDark,
                  displayName: displayName,
                  isConnected: isConnected,
                  accountNumber: accountNumber,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  auth: auth,
                ),

                const SizedBox(height: 24),

                // 2. كرت بيانات الحساب والاشتراك
                _buildSectionHeader('بيانات الحساب والاشتراك', accentBlue),
                _buildGroupCard(
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  children: [
                    _buildSettingsTile(
                      icon: Icons.badge_outlined,
                      iconColor: accentBlue,
                      title: loc.tr('accountType'),
                      sideValue: provider.isCommercial ? 'حساب تجاري (Commercial)' : 'حساب سكني (Residential)',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      showChevron: false,
                      onTap: null,
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: Colors.amber,
                      title: loc.tr('upgradePlan'),
                      sideValue: 'الباقة المتميزة Pro',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      ),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.credit_card_rounded,
                      iconColor: AppTheme.neonGreen,
                      title: 'طرق الدفع وإدارة الفواتير',
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => _showPaymentMethodsModal(context, isDark),
                    ),
                    _buildDivider(isDark),
                    _buildSettingsTile(
                      icon: Icons.history_rounded,
                      iconColor: AppTheme.primaryBlue,
                      title: loc.tr('activityHistory'),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ActivityLogScreen()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. زر تسجيل الخروج الكامل
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.neonRed, size: 20),
                    label: Text(
                      loc.tr('logout'),
                      style: AppTheme.getTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.neonRed,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.neonRed.withOpacity(0.4), width: 1.5),
                      backgroundColor: AppTheme.neonRed.withOpacity(0.06),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _showSignOutDialog(context, auth, provider),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required bool isDark,
    required String displayName,
    required bool isConnected,
    required String accountNumber,
    required Color textPrimary,
    required Color textSecondary,
    required AuthService auth,
  }) {
    final subText = auth.displayEmail.isNotEmpty ? auth.displayEmail : (auth.displayPhone.isNotEmpty ? auth.displayPhone : 'مستخدم منصة الطاقة الذكية');

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF38BDF8) : AppTheme.primaryBlue,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF38BDF8) : AppTheme.primaryBlue).withOpacity(0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: ClipOval(
                child: _profileImagePath != null
                    ? Image.file(
                        File(_profileImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _defaultAvatar(isDark),
                      )
                    : _defaultAvatar(isDark),
              ),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF38BDF8) : AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF070C18) : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          style: AppTheme.getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: AppTheme.getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 10),

        // رقم الحساب وحالة الاتصال
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: accountNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رقم الحساب بنجاح 📋'), duration: Duration(seconds: 2)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 12, color: isDark ? Colors.white60 : Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      accountNumber,
                      style: AppTheme.getTextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isConnected ? AppTheme.neonGreen : AppTheme.neonAmber).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: (isConnected ? AppTheme.neonGreen : AppTheme.neonAmber).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isConnected ? AppTheme.neonGreen : AppTheme.neonAmber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'متصل' : 'تجريبي',
                    style: AppTheme.getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isConnected ? AppTheme.neonGreen : AppTheme.neonAmber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _defaultAvatar(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
      child: Icon(
        Icons.person_rounded,
        size: 52,
        color: isDark ? const Color(0xFF38BDF8) : AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: AppTheme.getTextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
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

  void _showPaymentMethodsModal(BuildContext context, bool isDark) {
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
                'طرق الدفع المسجلة',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.credit_card, color: AppTheme.primaryBlue, size: 28),
                title: const Text('بطاقة مصرفية •••• 4242'),
                subtitle: const Text('تنتهي في 12/28 - افتراضية'),
                trailing: const Icon(Icons.check_circle_rounded, color: AppTheme.neonGreen),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text('إضافة طريقة دفع جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthService auth, EnergyProvider energy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من الحساب؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              energy.clearSession();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      onLoginSuccess: () {
                        Navigator.of(context).pushReplacementNamed('/main');
                      },
                    ),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

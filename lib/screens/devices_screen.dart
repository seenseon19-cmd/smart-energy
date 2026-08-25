import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../models/device_model.dart';
import '../widgets/device_card.dart';
import '../widgets/lottie_widgets.dart';
import '../core/app_animations.dart';
import 'add_device_screen.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إدارة الأجهزة الذكية — DevicesScreen
/// إدارة أجهزة الـ ESP32 وتعيين المنافذ مع إزالة أي شاشة بيضاء أو أخطاء برمجية
/// ══════════════════════════════════════════════════════════════════════════════
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final devices = provider.currentSpaceDevices;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final cardBg = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ══════════════════════════════════════
                    // ترويسة العنوان + زر إضافة جهاز
                    // ══════════════════════════════════════
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('devices'),
                              style: AppTheme.getTextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.tr('deviceControlSub'),
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // زر إضافة جهاز
                        _InteractiveScale(
                          onTap: () async {
                            final addedName = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
                            );
                            if (addedName != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context).tr('deviceAdded').replaceAll('{name}', addedName)),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  loc.tr('addDevice'),
                                  style: AppTheme.getTextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // بطاقة الأتمتة الذكية — حركة توعوية وليست إعلانًا.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        children: [
                          PremiumLottie(
                            assetPath: AppAnimations.smartHomesDevices,
                            width: 74,
                            height: 74,
                            fallbackIcon: Icons.home_work_rounded,
                            fallbackColor: const Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.tr('devices'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  loc.tr('deviceControlSub'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ══════════════════════════════════════
                    // شريط فلاتر المساحات
                    // ══════════════════════════════════════
                    Text(
                      loc.tr('spacesLabel'),
                      style: AppTheme.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: provider.spaces.map((space) {
                          final isSelected = space.id == provider.currentSpaceId;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _InteractiveScale(
                              onTap: () => provider.switchSpace(space.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF2563EB))
                                      : cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF38BDF8)
                                        : cardBorder,
                                  ),
                                ),
                                child: Text(
                                  space.name,
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ══════════════════════════════════════
                    // كبسولات ملخص الأجهزة
                    // ══════════════════════════════════════
                    Row(
                      children: [
                        _buildStatusBadge(
                          label: loc.tr('total'),
                          value: '${devices.length}/${provider.currentSpaceDeviceLimit}',
                          color: const Color(0xFF38BDF8),
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(
                          label: loc.tr('active'),
                          value: '${devices.where((d) => d.isOn).length}',
                          color: const Color(0xFF10B981),
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(
                          label: loc.tr('inactive'),
                          value: '${devices.where((d) => !d.isOn).length}',
                          color: const Color(0xFF64748B),
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ══════════════════════════════════════
                    // قائمة الأجهزة
                    // ══════════════════════════════════════
                    if (devices.isEmpty)
                      _buildEmptyState(context, isDark, loc)
                    else
                      ...devices.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: DeviceCard(
                            device: device,
                            onToggle: () => provider.toggleDevice(device.id),
                            onDelete: () => _showDeleteDialog(context, loc, provider, device, isDark),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10192C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.devices_rounded, size: 40, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 14),
          Text(
            loc.tr('noDevicesYet'),
            style: AppTheme.getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.tr('addDeviceEmptyHint'),
            textAlign: TextAlign.center,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () async {
              final addedName = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
              );
              if (addedName != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).tr('deviceAdded').replaceAll('{name}', addedName)),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            label: Text(
              loc.tr('addDevice'),
              style: AppTheme.getTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required String label,
    required String value,
    required Color color,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: AppTheme.getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTheme.getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AppLocalizations loc,
    EnergyProvider provider,
    DeviceModel device,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 24),
                const SizedBox(width: 8),
                Text(
                  loc.tr('deleteDevice'),
                  style: AppTheme.getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            content: Text(
              loc.tr('deleteDeviceConfirm').replaceAll('{name}', device.name),
              style: AppTheme.getTextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  loc.tr('cancel'),
                  style: AppTheme.getTextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await provider.removeDevice(device.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف جهاز "${device.name}" بنجاح'),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                },
                child: Text(
                  loc.tr('deleteDevice'),
                  style: AppTheme.getTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // مودال إضافة جهاز جديد — خالي 100% من الأخطاء والشاشات البيضاء
  // ══════════════════════════════════════════════════════════════
  void _showAddDeviceModal(
    BuildContext context,
    AppLocalizations loc,
    EnergyProvider provider,
    bool isDark,
  ) {
    if (provider.isCurrentSpaceFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.tr('maxDevicesReached').replaceAll('{limit}', '${provider.currentSpaceDeviceLimit}')),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final wattCtrl = TextEditingController(text: '100');
    String selectedRelay = '';
    String selectedIcon = 'plug';
    String? localError;

    final isCommercial = provider.isCommercial;
    final presets = isCommercial
        ? [
            {'name': 'التبريد المركزي', 'watt': '3500', 'icon': 'snowflake'},
            {'name': 'اليافطة والإنارة', 'watt': '400', 'icon': 'lightbulb'},
            {'name': 'شاشات العرض', 'watt': '600', 'icon': 'tv'},
            {'name': 'سيرفر البيانات', 'watt': '1000', 'icon': 'plug'},
            {'name': 'ماكينة القهوة', 'watt': '1800', 'icon': 'kitchen'},
          ]
        : [
            {'name': 'تكييف الصالة', 'watt': '1500', 'icon': 'snowflake'},
            {'name': 'الثلاجة', 'watt': '300', 'icon': 'kitchen'},
            {'name': 'سخان الماء', 'watt': '2000', 'icon': 'droplet'},
            {'name': 'الإنارة الرئيسية', 'watt': '100', 'icon': 'lightbulb'},
            {'name': 'التلفاز', 'watt': '150', 'icon': 'tv'},
            {'name': 'الغسالة', 'watt': '800', 'icon': 'plug'},
          ];

    final Map<String, String> occupiedRelays = {};
    for (final device in provider.devices) {
      if (device.relayId.isNotEmpty) {
        occupiedRelays[device.relayId] = device.name;
      }
    }

    // تعيين أول منفذ متاح تلقائياً
    for (final relay in DeviceModel.availableRelays) {
      if (!occupiedRelays.containsKey(relay)) {
        selectedRelay = relay;
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط السحب
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
                            loc.tr('addDevice'),
                            style: AppTheme.getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),

                      if (localError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            localError!,
                            style: AppTheme.getTextStyle(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // اقتراحات سريعة
                      Text(
                        loc.tr('quickSuggestions'),
                        style: AppTheme.getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: presets.length,
                          itemBuilder: (context, i) {
                            final p = presets[i];
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    nameCtrl.text = p['name'] ?? '';
                                    wattCtrl.text = p['watt'] ?? '100';
                                    selectedIcon = p['icon'] ?? 'plug';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    '+ ${p['name']}',
                                    style: AppTheme.getTextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF38BDF8),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // اسم الجهاز
                      _inputField(
                        controller: nameCtrl,
                        label: loc.tr('deviceName'),
                        hint: 'مثال: تكييف غرفة النوم',
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // الاستهلاك بالواط
                      _inputField(
                        controller: wattCtrl,
                        label: loc.tr('wattage'),
                        hint: 'مثال: 1500',
                        keyboardType: TextInputType.number,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // شبكة منافذ الـ ESP32
                      Text(
                        loc.tr('selectRelayPin'),
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final relayId = DeviceModel.availableRelays[index];
                          final relayNum = index + 1;
                          final isUsed = occupiedRelays.containsKey(relayId);
                          final isSelected = selectedRelay == relayId;

                          return GestureDetector(
                            onTap: isUsed
                                ? null
                                : () => setSheetState(() => selectedRelay = relayId),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : (isUsed
                                        ? const Color(0xFFEF4444).withOpacity(0.1)
                                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8)
                                      : (isUsed ? const Color(0xFFEF4444).withOpacity(0.3) : Colors.transparent),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pin $relayNum',
                                    style: AppTheme.getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white
                                          : (isUsed ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black)),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isUsed ? loc.tr('reserved') : loc.tr('available'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 9,
                                      color: isSelected
                                          ? Colors.white70
                                          : (isUsed ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // أيقونة الجهاز
                      Text(
                        loc.tr('deviceIcon'),
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: DeviceModel.iconMap.entries.map((e) {
                            final isSelected = selectedIcon == e.key;
                            return GestureDetector(
                              onTap: () => setSheetState(() => selectedIcon = e.key),
                              child: Container(
                                width: 48,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8).withOpacity(0.18)
                                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                                  ),
                                ),
                                child: Icon(
                                  e.value,
                                  size: 20,
                                  color: isSelected ? const Color(0xFF38BDF8) : (isDark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // زر الحفظ
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) {
                              setSheetState(() => localError = loc.tr('enterDeviceName'));
                              return;
                            }
                            if (selectedRelay.isEmpty) {
                              setSheetState(() => localError = loc.tr('selectAvailableRelay'));
                              return;
                            }
                            final wattage = int.tryParse(wattCtrl.text.trim()) ?? 100;

                            provider.addDevice(
                              DeviceModel(
                                id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                iconKey: selectedIcon,
                                relayId: selectedRelay,
                                wattage: wattage,
                              ),
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loc.tr('deviceAdded').replaceAll('{name}', name)),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          },
                          child: Text(
                            loc.tr('saveAndAddDevice'),
                            style: AppTheme.getTextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTheme.getTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.getTextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

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
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}

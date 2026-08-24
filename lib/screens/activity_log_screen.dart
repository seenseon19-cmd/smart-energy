/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة سجل النشاط — ActivityLogScreen
/// ══════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../services/firebase_service.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final firebaseService = FirebaseService();
    final energyProvider = context.watch<EnergyProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final scaffoldBg = isDark ? const Color(0xFF070C18) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF070C18) : const Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.tr('activityHistory'),
            style: AppTheme.getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, size: 22, color: textPrimary),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
          child: SafeArea(
            child: Stack(
              children: [
                ...AppTheme.buildGlowLayers(),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firebaseService.activityLogsStream,
                  builder: (context, snapshot) {
                    final fbLogs = snapshot.data ?? [];
                    final localLogs = energyProvider.localLogs;
                    
                    // دمج السجلات الحقيقية من الـ Provider والسحابة مع إزالة التكرار
                    final List<Map<String, dynamic>> combinedLogs = [];
                    final Set<String> seenKeys = {};

                    for (final log in [...localLogs, ...fbLogs]) {
                      final key = '${log['device']}_${log['action']}_${log['time'] ?? log['timestamp']}';
                      if (!seenKeys.contains(key)) {
                        seenKeys.add(key);
                        combinedLogs.add(log);
                      }
                    }

                    final displayLogs = combinedLogs.isEmpty ? _demoLogs(loc) : combinedLogs;
                    
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      itemCount: displayLogs.length,
                      itemBuilder: (_, i) => _buildItem(context, displayLogs[i], loc, isDark),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dt;
    try {
      if (timestamp is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is double) {
        dt = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
      } else if (timestamp is DateTime) {
        dt = timestamp;
      } else if (timestamp is String) {
        final parsed = int.tryParse(timestamp);
        if (parsed != null) {
          dt = DateTime.fromMillisecondsSinceEpoch(parsed);
        } else {
          dt = DateTime.tryParse(timestamp) ?? DateTime.now();
        }
      } else if (timestamp is Map) {
        dt = DateTime.now();
      } else {
        return timestamp.toString();
      }
    } catch (_) {
      dt = DateTime.now();
    }

    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (isToday) {
      return 'اليوم $timeStr';
    }
    return '${dt.day}/${dt.month} $timeStr';
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> log, AppLocalizations loc, bool isDark) {
    final action = log['action']?.toString() ?? '';
    final isActionOn = action.toLowerCase().contains('on') || action.contains('تشغيل') || action.contains('إضافة');
    final color = isActionOn ? AppTheme.neonGreen : AppTheme.neonRed;
    final icon = isActionOn ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff;
    final timeText = _formatTime(log['timestamp'] ?? log['time']);
    final spaceText = log['space'] != null ? ' [${log['space']}]' : '';

    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: FaIcon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${log['device'] ?? ''}$spaceText',
              style: AppTheme.getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$action • ${log['trigger'] ?? ''}',
              style: AppTheme.getTextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        Text(
          timeText,
          style: AppTheme.getTextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
          ),
        ),
      ]),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isDark
          ? AppTheme.darkGlassCard(radius: 18, child: cardContent)
          : AppTheme.glassCard(radius: 18, child: cardContent),
    );
  }

  List<Map<String, dynamic>> _demoLogs(AppLocalizations loc) {
    final now = DateTime.now();
    return [
      {'device': loc.tr('airConditioning'), 'action': 'ON', 'trigger': loc.tr('userManual'), 'time': now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch},
      {'device': loc.tr('waterHeater'), 'action': 'OFF', 'trigger': loc.tr('systemAuto'), 'time': now.subtract(const Duration(minutes: 18)).millisecondsSinceEpoch},
      {'device': loc.tr('livingRoom'), 'action': 'ON', 'trigger': loc.tr('timerSchedule'), 'time': now.subtract(const Duration(minutes: 32)).millisecondsSinceEpoch},
      {'device': loc.tr('kitchen'), 'action': 'OFF', 'trigger': loc.tr('userManual'), 'time': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch},
      {'device': loc.tr('airConditioning'), 'action': 'OFF', 'trigger': loc.tr('systemAuto'), 'time': now.subtract(const Duration(hours: 1, minutes: 30)).millisecondsSinceEpoch},
      {'device': loc.tr('waterHeater'), 'action': 'ON', 'trigger': loc.tr('userManual'), 'time': now.subtract(const Duration(hours: 2)).millisecondsSinceEpoch},
      {'device': loc.tr('livingRoom'), 'action': 'OFF', 'trigger': loc.tr('timerSchedule'), 'time': now.subtract(const Duration(hours: 3)).millisecondsSinceEpoch},
      {'device': loc.tr('kitchen'), 'action': 'ON', 'trigger': loc.tr('userManual'), 'time': now.subtract(const Duration(hours: 4, minutes: 15)).millisecondsSinceEpoch},
      {'device': loc.tr('airConditioning'), 'action': 'ON', 'trigger': loc.tr('timerSchedule'), 'time': now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch},
      {'device': loc.tr('waterHeater'), 'action': 'OFF', 'trigger': loc.tr('systemAuto'), 'time': now.subtract(const Duration(hours: 6, minutes: 45)).millisecondsSinceEpoch},
    ];
  }
}

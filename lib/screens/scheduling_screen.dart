/// شاشة جدولة الأجهزة — SchedulingScreen
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});
  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final List<_ScheduleItem> _schedules = [
    _ScheduleItem(
      device: 'ac', nameAr: 'تكييف الهواء', nameEn: 'Air Conditioning',
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 22, minute: 0),
      days: [false, true, true, true, true, true, false], isActive: true,
    ),
    _ScheduleItem(
      device: 'heater', nameAr: 'السخان', nameEn: 'Water Heater',
      startTime: const TimeOfDay(hour: 5, minute: 30),
      endTime: const TimeOfDay(hour: 7, minute: 0),
      days: [true, true, true, true, true, true, true], isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              loc.tr('deviceScheduling'),
              style: AppTheme.getTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: FaIcon(FontAwesomeIcons.arrowRight, size: 18, color: isDark ? AppTheme.darkText : AppTheme.lightText),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _InteractiveScale(
                  onTap: () => _addSchedule(context, loc),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              ...AppTheme.buildGlowLayers(),
              _schedules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: 60, color: isDark ? AppTheme.darkText.withOpacity(0.3) : AppTheme.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            loc.tr('noSchedules'),
                            style: AppTheme.getTextStyle(
                              fontSize: 16, 
                              color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: _schedules.length,
                      itemBuilder: (_, i) => _buildCard(context, _schedules[i], i, loc, isDark),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _ScheduleItem s, int idx, AppLocalizations loc, bool isDark) {
    final dayLabels = [
      loc.tr('sunday'), loc.tr('monday'), loc.tr('tuesday'),
      loc.tr('wednesday'), loc.tr('thursday'), loc.tr('friday'), loc.tr('saturday'),
    ];
    final cardContent = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(
                  s.device == 'ac' ? FontAwesomeIcons.snowflake : FontAwesomeIcons.droplet,
                  color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      loc.isArabic ? s.nameAr : s.nameEn,
                      style: AppTheme.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.isActive ? loc.tr('scheduleActive') : loc.tr('deviceOff'),
                      style: AppTheme.getTextStyle(
                        fontSize: 12,
                        color: s.isActive 
                            ? (isDark ? AppTheme.neonGreen : AppTheme.accentGreen) 
                            : (isDark ? AppTheme.darkText.withOpacity(0.4) : AppTheme.lightTextSecondary),
                      ),
                    ),
                  ]
                ),
              ),
              Switch(
                value: s.isActive,
                onChanged: (v) => setState(() => s.isActive = v),
                activeThumbColor: Colors.white,
                activeTrackColor: isDark ? AppTheme.neonGreen : AppTheme.accentGreen,
              ),
            ]
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: s.startTime);
                      if (t != null) setState(() => s.startTime = t);
                    },
                    child: Column(
                      children: [
                        FaIcon(FontAwesomeIcons.play, size: 12, color: isDark ? AppTheme.neonGreen : AppTheme.accentGreen),
                        const SizedBox(height: 6),
                        Text(
                          s.startTime.format(context),
                          style: AppTheme.getTextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.lightBorder.withOpacity(0.5),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final t = await showTimePicker(context: context, initialTime: s.endTime);
                      if (t != null) setState(() => s.endTime = t);
                    },
                    child: Column(
                      children: [
                        FaIcon(FontAwesomeIcons.stop, size: 12, color: isDark ? AppTheme.neonRed : AppTheme.accentRed),
                        const SizedBox(height: 6),
                        Text(
                          s.endTime.format(context),
                          style: AppTheme.getTextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkText : AppTheme.lightText,
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ]
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (d) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _InteractiveScale(
                  onTap: () => setState(() => s.days[d] = !s.days[d]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: s.days[d] ? AppTheme.primaryGradient : null,
                      color: s.days[d] ? null : (isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: s.days[d] 
                            ? AppTheme.accentCyan.withOpacity(0.5) 
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayLabels[d],
                        style: AppTheme.getTextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: s.days[d] ? Colors.white : (isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _InteractiveScale(
              onTap: () => setState(() => _schedules.removeAt(idx)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.neonRed : AppTheme.accentRed).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(FontAwesomeIcons.trash, size: 12, color: isDark ? AppTheme.neonRed : AppTheme.accentRed),
                    const SizedBox(width: 6),
                    Text(
                      loc.tr('delete'),
                      style: AppTheme.getTextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.neonRed : AppTheme.accentRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]
      ),
    );

    return isDark 
        ? AppTheme.darkGlassCard(child: cardContent) 
        : AppTheme.glassCard(child: cardContent);
  }

  void _addSchedule(BuildContext context, AppLocalizations loc) {
    setState(() => _schedules.add(_ScheduleItem(
      device: 'ac', nameAr: 'جهاز جديد', nameEn: 'New Device',
      startTime: const TimeOfDay(hour: 8, minute: 0),
      endTime: const TimeOfDay(hour: 20, minute: 0),
      days: List.filled(7, true), isActive: true,
    )));
  }
}

class _ScheduleItem {
  final String device, nameAr, nameEn;
  TimeOfDay startTime, endTime;
  List<bool> days;
  bool isActive;
  _ScheduleItem({
    required this.device, required this.nameAr, required this.nameEn,
    required this.startTime, required this.endTime, required this.days, required this.isActive,
  });
}

// ═══════════════════════════════════════════════════════════════
// 🟢 حاوية التفاعل اللمسي (Stitch Interactive Scale Effect)
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

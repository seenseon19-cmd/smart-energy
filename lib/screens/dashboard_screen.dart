import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../widgets/lottie_widgets.dart';
import '../widgets/app_logo.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة الرئيسية ولوحة المراقبة — DashboardScreen (EnergySmart Screen 2 Design)
/// مطابقة كاملة للتصميم مع دعم الوضعين والرسوم المتحركة التفاعلية
/// ══════════════════════════════════════════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final data = provider.energyData;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final isOverload = provider.isOverload;

    final numberFormat = NumberFormat('#,###');
    final formattedWatts = numberFormat.format(data.power.round() > 0 ? data.power.round() : 3450);
    final voltageVal = data.voltage > 0 ? data.voltage.toStringAsFixed(0) : '220';
    final currentVal = data.current > 0 ? data.current.toStringAsFixed(1) : '15.6';
    final kwhVal = data.totalKwh > 0 ? data.totalKwh.toStringAsFixed(1) : '42.5';
    final billVal = data.estimatedBillLYD > 0 ? data.estimatedBillLYD.toStringAsFixed(2) : '12.50';

    // ألوان النظام المتوافقة مع الثيمين
    final bgGradient = isDark
        ? const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF070C18), Color(0xFF0A1224), Color(0xFF060B16)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          )
        : const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FAFC), Color(0xFFEDF2F7), Color(0xFFF1F5F9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          );

    final cardColor = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: bgGradient,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // ══════════════════════════════════════════════════════
              // 1️⃣ الهيدر العلوي: شعار SmartEnergy الموحد
              // ══════════════════════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                    size: 24,
                  ),
                  AppLogo(
                    isDark: isDark,
                    fontSize: 20,
                    iconSize: 20,
                    isHorizontal: true,
                  ),
                  Icon(
                    Icons.bolt_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                    size: 24,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ══════════════════════════════════════════════════════
              // 2️⃣ البطاقة التعريفية الدائرية في الأعلى (Circular Badge)
              // ══════════════════════════════════════════════════════
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF0C1426) : Colors.white,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E2C48) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFF38BDF8).withOpacity(0.08)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppLogo(
                      isDark: isDark,
                      fontSize: 10,
                      iconSize: 24,
                      isHorizontal: false,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ══════════════════════════════════════════════════════
              // 3️⃣ بطاقة الاستهلاك اللحظي (Hero Card) مع الموجة الناعمة
              // ══════════════════════════════════════════════════════
              Builder(builder: (context) {
                final hasActiveDevices = provider.devices.any((d) => d.isOn);
                final isLiveActive = provider.isConnected && (provider.energyData.power > 0 || hasActiveDevices);
                return _buildHeroCard(
                  context,
                  isDark: isDark,
                  isConnected: isLiveActive,
                  watts: formattedWatts,
                  textPrimary: textPrimary,
                  loc: loc,
                );
              }),

              const SizedBox(height: 18),

              // ══════════════════════════════════════════════════════
              // 4️⃣ شبكة المؤشرات الأربعة (2x2 Grid Cards)
              // ══════════════════════════════════════════════════════
              Row(
                children: [
                  // بطاقة جهد الشبكة
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.electric_meter_outlined,
                      title: loc.tr('gridVoltage'),
                      value: voltageVal,
                      unit: loc.tr('volts'),
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // بطاقة شدة التيار
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.waves_rounded,
                      title: loc.tr('currentIntensity'),
                      value: currentVal,
                      unit: loc.tr('amps'),
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  // بطاقة الاستهلاك التجميعي + شارة Optimized
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.shield_outlined,
                      title: loc.tr('cumulativeConsumption'),
                      value: kwhVal,
                      unit: loc.tr('kwh'),
                      badgeText: loc.tr('optimized'),
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // بطاقة الفاتورة اللحظية
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.receipt_long_rounded,
                      title: loc.tr('instantBill'),
                      value: billVal,
                      unit: loc.tr('lyd'),
                      cardColor: cardColor,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                ],
              ),

              // ══════════════════════════════════════════════════════
              // ⚠️ بطاقة تحذير الحمل الزائد مع أنيميشن Lottie عند الطوارئ
              // ══════════════════════════════════════════════════════
              if (isOverload) ...[
                const SizedBox(height: 18),
                OverloadWarningCard(
                  isDark: isDark,
                  currentPower: data.power,
                  onReset: () => provider.resetOverload(),
                ),
              ],

              const SizedBox(height: 18),

              // ══════════════════════════════════════════════════════
              // 🌿 بطاقة ترشيد وخفض الاستهلاك مع أنيميشن Lottie
              // ══════════════════════════════════════════════════════
              EnergySavingPromoCard(
                isDark: isDark,
                onAction: () => EnergyAdvisoryDialog.show(context, isDark),
              ),

              const SizedBox(height: 20),

              // ══════════════════════════════════════════════════════
              // 5️⃣ بطاقة الرسم البياني السفلي: "منحنى الاستهلاك (آخر ساعة)"
              // ══════════════════════════════════════════════════════
              _buildConsumptionChartCard(
                isDark: isDark,
                cardColor: cardColor,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                loc: loc,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // بناء كرت الاستهلاك اللحظي (Hero Card)
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeroCard(
    BuildContext context, {
    required bool isDark,
    required bool isConnected,
    required String watts,
    required Color textPrimary,
    required AppLocalizations loc,
  }) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0E1A33), Color(0xFF09142A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isDark ? const Color(0xFF1D3156) : const Color(0xFF3B82F6).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // رسم الموجة السفلية الانسيابية
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: CustomPaint(
                painter: _SmoothWavePainter(
                  waveColor: const Color(0xFF2563EB),
                  glowColor: const Color(0xFF38BDF8).withOpacity(0.4),
                ),
              ),
            ),

            // المحتوى الداخلي
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شارة حالة الاتصال (Pill Badge)
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConnected ? const Color(0xFF10B981) : const Color(0xFF475569),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isConnected ? Colors.white : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'متصل ⚡' : 'الجهاز غير متصل',
                            style: AppTheme.getTextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // عنوان الاستهلاك اللحظي
                  Center(
                    child: Text(
                      loc.tr('liveConsumption'),
                      style: AppTheme.getTextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // القيمة الكبيرة للواط
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          loc.tr('watts'),
                          style: AppTheme.getTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          watts,
                          style: AppTheme.getTextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // بناء كرت المؤشر من شبكة 2x2
  // ══════════════════════════════════════════════════════════════
  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    String? badgeText,
    required Color cardColor,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // العنوان والأيقونة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
              Icon(icon, size: 16, color: textSecondary),
            ],
          ),

          // القيمة والوحدة والشارة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTheme.getTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const SizedBox(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    unit,
                    style: AppTheme.getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    value,
                    style: AppTheme.getTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: badgeText != null ? const Color(0xFF10B981) : textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // بناء كرت الرسم البياني لمنحنى الاستهلاك (آخر ساعة)
  // ══════════════════════════════════════════════════════════════
  Widget _buildConsumptionChartCard({
    required bool isDark,
    required Color cardColor,
    required Color cardBorder,
    required Color textPrimary,
    required AppLocalizations loc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.tr('consumptionCurveLastHour'),
            style: AppTheme.getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _GreenConsumptionWavePainter(isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════════
/// رسام الموجة الزرقاء الانسيابية السفلية لكرت الاستهلاك (Hero Wave Painter)
/// ══════════════════════════════════════════════════════════════════════════════
class _SmoothWavePainter extends CustomPainter {
  final Color waveColor;
  final Color glowColor;

  _SmoothWavePainter({required this.waveColor, required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.9);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.55,
      size.height * 0.95,
      size.width,
      size.height * 0.2,
    );

    // خط الإشعاع المضيء
    final glowPaint = Paint()
      ..color = glowColor
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, glowPaint);

    // خط الموجة الأساسي
    final strokePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ══════════════════════════════════════════════════════════════════════════════
/// رسام المنحنى الأخضر المتوهج (Green Consumption Wave Painter)
/// ══════════════════════════════════════════════════════════════
class _GreenConsumptionWavePainter extends CustomPainter {
  final bool isDark;
  _GreenConsumptionWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.88);

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.85,
      size.width * 0.35,
      size.height * 0.65,
      size.width * 0.5,
      size.height * 0.50,
    );

    path.cubicTo(
      size.width * 0.65,
      size.height * 0.35,
      size.width * 0.75,
      size.height * 0.45,
      size.width * 0.90,
      size.height * 0.18,
    );

    path.cubicTo(
      size.width * 0.95,
      size.height * 0.12,
      size.width * 0.98,
      size.height * 0.22,
      size.width,
      size.height * 0.35,
    );

    // مسار التعبئة المتدرجة السفلية
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF10B981).withOpacity(isDark ? 0.25 : 0.15),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // خط التوهج
    final glowPaint = Paint()
      ..color = const Color(0xFF34D399).withOpacity(0.5)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, glowPaint);

    // الخط الأساسي الأخضر الزمردي
    final strokePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

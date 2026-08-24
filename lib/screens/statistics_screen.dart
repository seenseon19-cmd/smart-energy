import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../core/app_animations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 2; // month

  /// 🟢 توليد بيانات محاكاة ديناميكية للرسم البياني عندما لا توجد بيانات فعلية
  bool get _isDemoMode => true; // الإحصائيات تستخدم محاكاة دائماً للرسم البياني لأنها لا تربط ببيانات تاريخية

  List<FlSpot> _generateChartSpots(double basePower) {
    final rng = Random(42); // بذرة ثابتة لنفس النمط
    int pointCount;
    switch (_selectedPeriod) {
      case 0: pointCount = 24; break; // يومي (ساعات)
      case 1: pointCount = 7; break;  // أسبوعي (أيام)
      case 2: pointCount = 12; break; // شهري (أشهر)
      case 3: pointCount = 12; break; // سنوي (أشهر)
      default: pointCount = 12;
    }
    final base = basePower > 0 ? basePower : 1500.0;
    return List.generate(pointCount, (i) {
      final sinFactor = sin(i * 0.5 + _selectedPeriod) * 0.3;
      final noise = (rng.nextDouble() - 0.5) * 0.2;
      final val = base * (0.4 + sinFactor + noise + (i % 3) * 0.15);
      return FlSpot(i.toDouble(), val.clamp(200, 4500));
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final data = provider.energyData;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final periods = [loc.tr('day'), loc.tr('week'), loc.tr('month'), loc.tr('year')];

    // ألوان تفاعلية ديناميكية للرسم الدائري وقائمة المكونات
    final colorAc = isDark ? AppTheme.neonCyan : AppTheme.primaryBlue;
    final colorHeater = isDark ? AppTheme.accentCyan : AppTheme.accentCyan;
    final colorLighting = isDark ? AppTheme.accentAmber : AppTheme.accentAmber;
    final colorKitchen = isDark ? AppTheme.neonGreen : AppTheme.accentGreen;
    final colorOther = isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
        child: Stack(
          children: [
            ...AppTheme.buildGlowLayers(),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ══════════════════════════════════════════════════════
                      // 📊 كرت البطل التفاعلي لتحليلات الطاقة (Analytics Hero Card)
                      // ══════════════════════════════════════════════════════
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF10192C) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(isDark ? 0.12 : 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // أنيميشن التحليلات Lottie Hero
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: Lottie.asset(
                                AppAnimations.analyticsHero,
                                fit: BoxFit.contain,
                                repeat: true,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.insights_rounded,
                                  color: Color(0xFF38BDF8),
                                  size: 60,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'تحليلات الذكاء الاصطناعي ⚡',
                                      style: AppTheme.getTextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF38BDF8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'كفاءة الاستهلاك ممتازة',
                                    style: AppTheme.getTextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'استهلاكك الحالي ضمن النطاق الآمن والموفر للطاقة بنسبة تحسين 18%.',
                                    style: AppTheme.getTextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      height: 1.3,
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

                      // العنوان الرئيسي
                      Text(
                        loc.tr('smartInsights'),
                        style: AppTheme.getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.tr('realtimeDataCurves'),
                              style: AppTheme.getTextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                          // 🟢 شارة وضع العرض التوضيحي
                          if (_isDemoMode)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.science_rounded, color: AppTheme.accentAmber, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    loc.tr('demoMode'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 10,
                                      color: AppTheme.accentAmber,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // منتقي الفترة التفاعلي
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.08) : AppTheme.lightBorder.withOpacity(0.5),
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: List.generate(periods.length, (i) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == i
                                      ? (isDark ? const Color(0xFF2563EB) : const Color(0xFF2563EB))
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  periods[i],
                                  textAlign: TextAlign.center,
                                  style: AppTheme.getTextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedPeriod == i ? Colors.white : (isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── الرسم البياني — Gradient Area Chart ──
                      isDark
                          ? AppTheme.darkGlassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildChartContent(loc, isDark, data),
                            )
                          : AppTheme.glassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildChartContent(loc, isDark, data),
                            ),
                      const SizedBox(height: 20),

                      // ── توزيع الطاقة — Donut Chart + Legend ──
                      isDark
                          ? AppTheme.darkGlassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildDistributionContent(loc, isDark, colorAc, colorHeater, colorLighting, colorKitchen, colorOther),
                            )
                          : AppTheme.glassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildDistributionContent(loc, isDark, colorAc, colorHeater, colorLighting, colorKitchen, colorOther),
                            ),
                      const SizedBox(height: 20),

                      // ── الفاتورة المتوقعة ──
                      isDark
                          ? AppTheme.darkGlassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildBillContent(loc, isDark, data),
                            )
                          : AppTheme.glassCard(
                              radius: AppTheme.radius2Xl,
                              child: _buildBillContent(loc, isDark, data),
                            ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent(AppLocalizations loc, bool isDark, dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  FontAwesomeIcons.chartArea, 
                  size: 14, 
                  color: isDark ? AppTheme.neonCyan : AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                loc.tr('powerConsumption'),
                style: AppTheme.getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ]
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: isDark ? Colors.white.withOpacity(0.08) : AppTheme.lightBorder.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: AppTheme.getTextStyle(
                        fontSize: 10,
                        color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}h',
                      style: AppTheme.getTextStyle(
                        fontSize: 10,
                        color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateChartSpots(data.power),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [AppTheme.neonCyan, AppTheme.accentCyan] 
                        : [AppTheme.primaryBlue, AppTheme.accentCyan],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [
                              AppTheme.neonCyan.withOpacity(0.15),
                              AppTheme.neonCyan.withOpacity(0.01),
                            ]
                          : [
                              AppTheme.primaryBlue.withOpacity(0.2),
                              AppTheme.accentCyan.withOpacity(0.02),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(0)} W',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  )).toList(),
                ),
              ),
            )),
          ),
        ]
      ),
    );
  }

  Widget _buildDistributionContent(
    AppLocalizations loc,
    bool isDark,
    Color colorAc,
    Color colorHeater,
    Color colorLighting,
    Color colorKitchen,
    Color colorOther,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.neonCyan.withOpacity(0.15) : AppTheme.accentCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  FontAwesomeIcons.chartPie, 
                  size: 14, 
                  color: isDark ? AppTheme.neonCyan : AppTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                loc.tr('energyDistribution'),
                style: AppTheme.getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
            ]
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // الرسم الدائري
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 36,
                  sections: _buildPieSections(colorAc, colorHeater, colorLighting, colorKitchen, colorOther),
                  borderData: FlBorderData(show: false),
                )),
              ),
              const SizedBox(width: 20),
              // قائمة توضيحية
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(loc.tr('acLabel'), 40, colorAc, isDark),
                    _legendItem(loc.tr('heaterLabel'), 30, colorHeater, isDark),
                    _legendItem(loc.tr('lightingLabel'), 15, colorLighting, isDark),
                    _legendItem(loc.tr('kitchenLabel'), 10, colorKitchen, isDark),
                    _legendItem(loc.tr('otherLabel'), 5, colorOther, isDark),
                  ],
                ),
              ),
            ],
          ),
        ]
      ),
    );
  }

  Widget _buildBillContent(AppLocalizations loc, bool isDark, dynamic data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.greenGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.neonGreen : AppTheme.accentGreen).withOpacity(0.3), 
                  blurRadius: 12,
                )
              ],
            ),
            child: const FaIcon(FontAwesomeIcons.fileInvoiceDollar, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  loc.tr('predictedBill'),
                  style: AppTheme.getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.tr('basedOnUsage'),
                  style: AppTheme.getTextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                  ),
                ),
              ]
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: [
              Text(
                data.estimatedBillLYD.toStringAsFixed(2),
                style: AppTheme.getTextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppTheme.neonGreen : AppTheme.accentGreen,
                ),
              ),
              Text(
                'LYD',
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.neonGreen : AppTheme.accentGreen,
                ),
              ),
            ]
          ),
        ]
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Color colorAc,
    Color colorHeater,
    Color colorLighting,
    Color colorKitchen,
    Color colorOther,
  ) {
    final data = [
      (40.0, colorAc),
      (30.0, colorHeater),
      (15.0, colorLighting),
      (10.0, colorKitchen),
      (5.0, colorOther),
    ];
    return data.map((item) => PieChartSectionData(
      value: item.$1,
      color: item.$2,
      radius: 20,
      showTitle: false,
    )).toList();
  }

  Widget _legendItem(String label, double pct, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTheme.getTextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          Text(
            '$pct%',
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
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

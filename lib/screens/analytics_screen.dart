/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة رؤى الاستهلاك — AnalyticsScreen (Stitch _9 Insights & Analytics)
/// الوظيفة: عرض الرسوم البيانية المتطورة وتصدير تقارير PDF بالعملة الليبية
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../services/auth_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isGenerating = false;
  int _timeFilterIndex = 0; // 0: يومي, 1: أسبوعي, 2: شهري, 3: مخصص

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final data = provider.energyData;
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'رؤى الاستهلاك',
              style: AppTheme.getTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppTheme.darkText : AppTheme.lightText),
            ),
          ),
          body: Stack(
            children: [
              // 🟢 بداية: طبقات النيون المتوهجة المحيطية لتضفي عمقاً زجاجياً خلف الكروت
              ...AppTheme.buildGlowLayers(),
              // 🔵 نهاية: طبقات النيون
    
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ══════════════════════════════════════
                    // عنوان الصفحة والوصف
                    // ══════════════════════════════════════
                    Text(
                      loc.tr('smartEnergyAnalytics'),
                      style: AppTheme.getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "بيانات لحظية ومنحنيات تفاعلية لمساحة النشطة حالياً",
                      style: AppTheme.getTextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
    
                    // 🟢 بداية: كبسولة الفلترة الزمنية العلوية الزجاجية
                    _buildTimeFilter(isDark),
                    // 🔵 نهاية: كبسولة الفلترة الزمنية
                    const SizedBox(height: 16),
    
                    // 🟢 بداية: شارة ساعات الذروة المضيئة بنبرة تحذيرية
                    _buildPeakHoursBadge(),
                    const SizedBox(height: 24),
    
                    // ══════════════════════════════════════
                    // 🟢 بداية: كرت الرسم البياني الرئيسي (المائي المنساب)
                    // ══════════════════════════════════════
                    isDark
                        ? AppTheme.darkGlassCard(
                            radius: 24,
                            isStrong: true,
                            child: _buildChartContent(data, isDark),
                          )
                        : AppTheme.glassCard(
                            radius: 24,
                            isStrong: true,
                            child: _buildChartContent(data, isDark),
                          ),
                    // 🔵 نهاية: كرت الرسم البياني الرئيسي
                    const SizedBox(height: 24),
    
                    // ══════════════════════════════════════
                    // كروت الـ KPI الأربعة
                    // ══════════════════════════════════════
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            Icons.bolt_rounded,
                            loc.tr('mainsVoltage'),
                            data.voltage.toStringAsFixed(1),
                            'V',
                            AppTheme.accentAmber,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            Icons.speed_rounded,
                            loc.tr('currentLabel'),
                            data.current.toStringAsFixed(2),
                            'A',
                            AppTheme.accentCyan,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            Icons.show_chart_rounded,
                            loc.tr('totalConsumption'),
                            data.totalKwh.toStringAsFixed(2),
                            'kWh',
                            AppTheme.neonGreen,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            Icons.monetization_on_rounded,
                            loc.tr('estimatedBill'),
                            data.estimatedBillLYD.toStringAsFixed(2),
                            'LYD',
                            AppTheme.accentPurple,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
    
                    // ══════════════════════════════════════
                    // الفاتورة المتوقعة — كرت زجاجي فخم
                    // ══════════════════════════════════════
                    isDark
                        ? AppTheme.darkGlassCard(
                            radius: 24,
                            child: _buildBillContent(loc, data, isDark),
                          )
                        : AppTheme.glassCard(
                            radius: 24,
                            child: _buildBillContent(loc, data, isDark),
                          ),
                    const SizedBox(height: 24),
    
                    // ══════════════════════════════════════
                    // 🟢 بداية: كرت التصدير السفلي الزجاجي الفاخر مع زر التصدير العريض
                    // ══════════════════════════════════════
                    isDark
                        ? AppTheme.darkGlassCard(
                            radius: 24,
                            child: _buildExportCardContent(context, loc, data, isDark),
                          )
                        : AppTheme.glassCard(
                            radius: 24,
                            child: _buildExportCardContent(context, loc, data, isDark),
                          ),
                    // 🔵 نهاية: كرت التصدير السفلي
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(dynamic data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, size: 18, color: AppTheme.accentCyan),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'معدلات الاستهلاك اليومية (kWh)',
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                ],
              ),
              Text(
                'مباشر',
                style: AppTheme.getTextStyle(
                  fontSize: 11,
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // رسم بياني تفاعلي بأشرطة مائية زرقاء وسيانية
          _InteractiveChart(totalKwh: data.totalKwh, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildBillContent(AppLocalizations loc, dynamic data, bool isDark) {
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
                  color: AppTheme.neonGreen.withOpacity(0.25),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_rounded, size: 24, color: Colors.white),
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
                const SizedBox(height: 4),
                Text(
                  'بناءً على الاستهلاك الحالي والمساحة',
                  style: AppTheme.getTextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.estimatedBillLYD.toStringAsFixed(2),
                style: AppTheme.getTextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neonGreen,
                ),
              ),
              Text(
                'LYD',
                style: AppTheme.getTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neonGreen.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportCardContent(BuildContext context, AppLocalizations loc, dynamic data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'تقارير الاستهلاك الشاملة',
            style: AppTheme.getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'قم بتصدير البيانات التفصيلية كملف PDF لمشاركتها أو حفظها.',
            style: AppTheme.getTextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _InteractiveScale(
            key: const Key('pdf_export_btn'),
            onTap: _isGenerating ? null : () => _generatePdf(context, loc, data),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isGenerating)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    _isGenerating ? 'جاري تصدير التقرير...' : 'تصدير تقرير الاستهلاك الشامل (PDF)',
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // كبسولة الفلترة الزمنية
  // ══════════════════════════════════════════════════════════════
  Widget _buildTimeFilter(bool isDark) {
    final filters = ['يومي', 'أسبوعي', 'شهري', 'مخصص'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = _timeFilterIndex == i;
          return Expanded(
            child: _InteractiveScale(
              onTap: () {
                setState(() {
                  _timeFilterIndex = i;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentCyan.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentCyan.withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[i],
                  style: AppTheme.getTextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppTheme.accentCyan : (isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // شارة ساعات الذروة
  // ══════════════════════════════════════════════════════════════
  Widget _buildPeakHoursBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.neonAmber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonAmber.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonAmber.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const _PulsingDot(color: AppTheme.neonAmber, size: 8),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ساعات الذروة المرتفعة: 6 PM - 9 PM',
              style: AppTheme.getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.neonAmber,
              ),
            ),
          ),
          const Icon(Icons.warning_amber_rounded, color: AppTheme.neonAmber, size: 18),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // بطاقة KPI زجاجية
  // ══════════════════════════════════════════════════════════════
  Widget _buildKpiCard(IconData icon, String label, String value, String unit, Color color, bool isDark) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.getTextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.getTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: AppTheme.getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return isDark
        ? AppTheme.darkGlassCard(
            radius: AppTheme.radiusLg,
            child: cardContent,
          )
        : AppTheme.glassCard(
            radius: AppTheme.radiusLg,
            child: cardContent,
          );
  }

  // ══════════════════════════════════════════════════════════════
  // 🔒 دالة توليد تقرير PDF — منطق التوليد لا يُعدَّل!
  // ══════════════════════════════════════════════════════════════
  Future<void> _generatePdf(BuildContext ctx, AppLocalizations loc, dynamic data) async {
    setState(() => _isGenerating = true);
    try {
      final arabicFont = await PdfGoogleFonts.cairoRegular();
      final arabicBold = await PdfGoogleFonts.cairoBold();
      if (!ctx.mounted) return;
      final auth = Provider.of<AuthService>(ctx, listen: false);

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBold),
      );

      pdf.addPage(
        pw.Page(
          textDirection: pw.TextDirection.rtl,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pCtx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#2563EB'),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'SmartEnergy',
                      style: pw.TextStyle(font: arabicBold, fontSize: 28, color: PdfColors.white),
                    ),
                    pw.Text(
                      auth.displayName.isNotEmpty ? auth.displayName : 'User',
                      style: pw.TextStyle(font: arabicBold, fontSize: 14, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text(
                  'تقرير رؤى الاستهلاك',
                  style: pw.TextStyle(font: arabicBold, fontSize: 18),
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  _pdfBox(arabicFont, arabicBold, 'إجمالي الطاقة', '${data.totalKwh.toStringAsFixed(2)} kWh'),
                  pw.SizedBox(width: 16),
                  _pdfBox(arabicFont, arabicBold, 'الجهد الحالي', '${data.voltage.toStringAsFixed(1)} V'),
                  pw.SizedBox(width: 16),
                  _pdfBox(arabicFont, arabicBold, 'الفاتورة المقدرة', '${data.estimatedBillLYD.toStringAsFixed(2)} LYD'),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                children: [
                  _pdfBox(arabicFont, arabicBold, 'القدرة الحالية', '${data.power.toStringAsFixed(0)} W'),
                  pw.SizedBox(width: 16),
                  _pdfBox(arabicFont, arabicBold, 'التيار', '${data.current.toStringAsFixed(2)} A'),
                  pw.SizedBox(width: 16),
                  _pdfBox(arabicFont, arabicBold, 'المتوسط اليومي', '${(data.totalKwh / 30).toStringAsFixed(1)} kWh'),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                'SmartEnergy v2.0 — تقرير آلي',
                style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey),
              ),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (f) async => pdf.save());
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التقرير بنجاح ✅'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppTheme.neonRed,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  pw.Expanded _pdfBox(pw.Font font, pw.Font bold, String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(font: bold, fontSize: 16),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🟢 الرسم البياني التفاعلي مع تلميحات طائرة
// ═══════════════════════════════════════════════════════════════
class _InteractiveChart extends StatefulWidget {
  final double totalKwh;
  final bool isDark;
  const _InteractiveChart({required this.totalKwh, required this.isDark});

  @override
  State<_InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<_InteractiveChart> {
  int? _hoveredIndex;
  final List<String> days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

  @override
  Widget build(BuildContext context) {
    final values = [
      widget.totalKwh * 0.12,
      widget.totalKwh * 0.18,
      widget.totalKwh * 0.14,
      widget.totalKwh * 0.20,
      widget.totalKwh * 0.10,
      widget.totalKwh * 0.16,
      widget.totalKwh * 0.10,
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final ratio = maxVal > 0 ? (values[i] / maxVal) : 0.0;
              final isHovered = _hoveredIndex == i;
              final isToday = i == DateTime.now().weekday % 7;
              final barColor = isToday ? AppTheme.neonCyan : AppTheme.accentPurple;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _hoveredIndex = (_hoveredIndex == i) ? null : i;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // القيمة اللحظية المعروضة
                        Text(
                          values[i].toStringAsFixed(1),
                          style: AppTheme.getTextStyle(
                            fontSize: 10,
                            fontWeight: isHovered || isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isHovered || isToday ? barColor : (widget.isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary.withOpacity(0.5)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // الشريط المنساب المتوهج
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          height: (120 * ratio).clamp(12.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor.withOpacity(0.9),
                                barColor.withOpacity(isHovered ? 0.6 : 0.2),
                              ],
                            ),
                            border: Border.all(
                              color: isHovered ? AppTheme.accentCyan : Colors.transparent,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isHovered || isToday
                                ? [
                                    BoxShadow(
                                      color: barColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // اسم اليوم
                        Text(
                          days[i].substring(0, 2),
                          style: AppTheme.getTextStyle(
                            fontSize: 12,
                            fontWeight: isToday || isHovered ? FontWeight.w800 : FontWeight.w600,
                            color: isToday || isHovered ? AppTheme.accentCyan : (widget.isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          // بطاقة التلميح الطائرة (Floating Tooltip Layout)
          if (_hoveredIndex != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: widget.isDark
                    ? AppTheme.darkGlassCard(
                        radius: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard.withOpacity(0.95),
                            border: Border.all(color: AppTheme.accentCyan.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                days[_hoveredIndex!],
                                style: AppTheme.getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkText.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${values[_hoveredIndex!].toStringAsFixed(2)} kWh',
                                style: AppTheme.getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.accentCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : AppTheme.glassCard(
                        radius: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            border: Border.all(color: AppTheme.accentCyan.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                days[_hoveredIndex!],
                                style: AppTheme.getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${values[_hoveredIndex!].toStringAsFixed(2)} kWh',
                                style: AppTheme.getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.accentCyan,
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🟢 حاوية التفاعل اللمسي (Stitch Interactive Scale Effect)
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
// 🟢 وجيدة النبض المستمر (Stitch Pulsing Dot)
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

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة التقارير والفواتير — ReportsScreen (Corporate Electricity Invoice PDF)
/// الوظيفة: تصدير فاتورة كهرباء مؤسسية رسمية بالعربية مع مشاركة واتساب
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../services/auth_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;

  final List<String> _monthsAr = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];
  final List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

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
              loc.tr('energyReports'),
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
              ...AppTheme.buildGlowLayers(),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.tr('selectMonth'),
                      style: AppTheme.getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InteractiveScale(
                      key: const Key('month_picker_btn'),
                      onTap: () => _showMonthPicker(context, loc, isDark),
                      child: isDark
                          ? AppTheme.darkGlassCard(
                              radius: 20,
                              child: _buildMonthPickerContent(loc, isDark),
                            )
                          : AppTheme.glassCard(
                              radius: 20,
                              child: _buildMonthPickerContent(loc, isDark),
                            ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      loc.tr('monthlyReport'),
                      style: AppTheme.getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            Icons.bolt_rounded,
                            loc.tr('totalKwh'),
                            '${data.totalKwh.toStringAsFixed(1)} kWh',
                            AppTheme.accentCyan,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            Icons.show_chart_rounded,
                            loc.tr('avgDaily'),
                            '${(data.totalKwh / 30).toStringAsFixed(1)} kWh',
                            AppTheme.accentPurple,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _summaryCard(
                      Icons.monetization_on_rounded,
                      loc.tr('totalCost'),
                      '${data.estimatedBillLYD.toStringAsFixed(1)} LYD',
                      AppTheme.neonGreen,
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // زر تصدير الفاتورة المؤسسية الرسمي
                    _InteractiveScale(
                      key: const Key('export_pdf_btn'),
                      onTap: _isGenerating ? null : () => _generateCorporatePdf(context, loc, provider),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentCyan.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGenerating)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            else
                              const Icon(Icons.picture_as_pdf_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              'تصدير فاتورة الكهرباء الرسمية (PDF)',
                              style: AppTheme.getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InteractiveScale(
                      key: const Key('share_whatsapp_btn'),
                      onTap: () => _shareWhatsApp(loc, data),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.5)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.share_rounded, size: 18, color: Color(0xFF25D366)),
                            const SizedBox(width: 8),
                            Text(
                              loc.tr('shareWhatsapp'),
                              style: AppTheme.getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF25D366),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildMonthPickerContent(AppLocalizations loc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.tr('pickMonthYear'),
                  style: AppTheme.getTextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.isArabic
                      ? '${_monthsAr[_selectedMonth - 1]} $_selectedYear'
                      : '${_monthsEn[_selectedMonth - 1]} $_selectedYear',
                  style: AppTheme.getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary),
        ],
      ),
    );
  }

  Widget _summaryCard(IconData icon, String label, String value, Color color, bool isDark) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkText.withOpacity(0.5) : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.getTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );

    return isDark
        ? AppTheme.darkGlassCard(radius: 20, child: cardContent)
        : AppTheme.glassCard(radius: 20, child: cardContent);
  }

  void _showMonthPicker(BuildContext context, AppLocalizations loc, bool isDark) {
    int tmpMonth = _selectedMonth;
    int tmpYear = _selectedYear;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => isDark
        ? AppTheme.darkGlassCard(
            radius: 28,
            child: _buildPickerSheetContent(ctx, loc, isDark, tmpMonth, tmpYear),
          )
        : AppTheme.glassCard(
            radius: 28,
            child: _buildPickerSheetContent(ctx, loc, isDark, tmpMonth, tmpYear),
          ),
    );
  }

  Widget _buildPickerSheetContent(BuildContext ctx, AppLocalizations loc, bool isDark, int startMonth, int startYear) {
    int tmpMonth = startMonth;
    int tmpYear = startYear;

    return StatefulBuilder(
      builder: (ctx, ss) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.tr('pickMonthYear'),
              style: AppTheme.getTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => ss(() => tmpYear--),
                  icon: Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: isDark ? AppTheme.darkText : AppTheme.lightText),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$tmpYear',
                    style: AppTheme.getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => ss(() => tmpYear++),
                  icon: Icon(Icons.keyboard_arrow_left_rounded, size: 24, color: isDark ? AppTheme.darkText : AppTheme.lightText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: 12,
              itemBuilder: (_, i) {
                final sel = (i + 1) == tmpMonth;
                return GestureDetector(
                  onTap: () => ss(() => tmpMonth = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: sel ? AppTheme.primaryGradient : null,
                      color: sel ? null : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? AppTheme.accentCyan.withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        loc.isArabic ? _monthsAr[i] : _monthsEn[i],
                        style: AppTheme.getTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : (isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _InteractiveScale(
              onTap: () {
                setState(() {
                  _selectedMonth = tmpMonth;
                  _selectedYear = tmpYear;
                });
                Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  loc.tr('save'),
                  style: AppTheme.getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 🟢 بناء فاتورة الـ PDF المؤسسية الرسمية المطابقة لفواتير الكهرباء
  // ══════════════════════════════════════════════════════════════
  Future<void> _generateCorporatePdf(BuildContext ctx, AppLocalizations loc, EnergyProvider provider) async {
    setState(() => _isGenerating = true);
    try {
      final arabicFont = await PdfGoogleFonts.cairoRegular();
      final arabicBold = await PdfGoogleFonts.cairoBold();
      if (!ctx.mounted) return;

      final auth = Provider.of<AuthService>(ctx, listen: false);
      final data = provider.energyData;
      final monthName = _monthsAr[_selectedMonth - 1];
      final userName = auth.displayName.isNotEmpty ? auth.displayName : 'مستخدم الطاقة الذكية';
      final isCommercial = provider.isCommercial;
      final spaceTypeLabel = isCommercial ? 'المكتب التجاري (تعرفة تجارية)' : 'المنزل السكني (تعرفة منزلية)';
      final serviceFee = 5.0; // رسوم العداد والخدمة
      final totalKwh = data.totalKwh;
      final consumptionCost = data.estimatedBillLYD;
      final grandTotal = consumptionCost + serviceFee;

      final pdf = pw.Document(
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBold),
      );

      final navyPrimary = PdfColor.fromHex('#00457F');
      final cyanAccent = PdfColor.fromHex('#0051D5');
      final greenSuccess = PdfColor.fromHex('#10B981');
      final greyBorder = PdfColor.fromHex('#E2E8F0');
      final lightBgColor = PdfColor.fromHex('#F8FAFC');

      pdf.addPage(
        pw.Page(
          textDirection: pw.TextDirection.rtl,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pCtx) => pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // 1️⃣ Header الترويسة العليا المؤسسية
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: navyPrimary,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SmartEnergy', textDirection: pw.TextDirection.ltr, style: pw.TextStyle(font: arabicBold, fontSize: 24, color: PdfColors.white)),
                          pw.Text('نظام إدارة وحماية الطاقة الذكية', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicFont, fontSize: 10, color: PdfColors.cyan100)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('فاتورة استهلاك الطاقة الكهربائية', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicBold, fontSize: 14, color: PdfColors.white)),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: pw.BoxDecoration(
                              color: greenSuccess,
                              borderRadius: pw.BorderRadius.circular(20),
                            ),
                            child: pw.Text('حالة الفاتورة: مصدورة ومدفوعة', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicBold, fontSize: 9, color: PdfColors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // 2️⃣ كارت بيانات الحساب والمشترك (Account Details Card)
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: lightBgColor,
                    border: pw.Border.all(color: greyBorder),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          _infoCell(arabicFont, arabicBold, 'رقم العداد / الحساب:', auth.accountNumber),
                          _infoCell(arabicFont, arabicBold, 'اسم المشترك:', userName),
                          _infoCell(arabicFont, arabicBold, 'نوع المساحة:', spaceTypeLabel),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(color: greyBorder, thickness: 0.8),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          _infoCell(arabicFont, arabicBold, 'تاريخ إصدار الفاتورة:', '${DateTime.now().day}/$_selectedMonth/$_selectedYear'),
                          _infoCell(arabicFont, arabicBold, 'فترة الاستهلاك:', '$monthName $_selectedYear'),
                          _infoCell(arabicFont, arabicBold, 'آخر موعد للسداد:', '30/$monthName/$_selectedYear'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // 3️⃣ شريط الحساب المالي الإجمالي (Billing Summary Bar)
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#EEF2FF'),
                    border: pw.Border.all(color: cyanAccent, width: 1.2),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المعادلة المالية الإجمالية:', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicBold, fontSize: 11, color: navyPrimary)),
                      pw.Row(
                        children: [
                          pw.Text('استهلاك (${consumptionCost.toStringAsFixed(2)} LYD)', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicFont, fontSize: 10)),
                          pw.Text(' + ', style: pw.TextStyle(font: arabicBold, fontSize: 10)),
                          pw.Text('رسوم عداد (${serviceFee.toStringAsFixed(2)} LYD)', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicFont, fontSize: 10)),
                          pw.Text(' = ', style: pw.TextStyle(font: arabicBold, fontSize: 12)),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: pw.BoxDecoration(
                              color: navyPrimary,
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.Text(
                              'المبلغ المطلوب: ${grandTotal.toStringAsFixed(2)} LYD',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(font: arabicBold, fontSize: 13, color: PdfColors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // 4️⃣ جدول القراءات الفنية والتفاصيل (Technical Readings Table - Zebra Striping)
                pw.Text('تفاصيل القراءات الفنية والاستهلاك:', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicBold, fontSize: 12, color: navyPrimary)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: greyBorder, width: 0.8),
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: navyPrimary),
                      children: [
                        _tableHeader(arabicBold, 'فترة القراءة'),
                        _tableHeader(arabicBold, 'القراءة السابقة (kWh)'),
                        _tableHeader(arabicBold, 'القراءة الحالية (kWh)'),
                        _tableHeader(arabicBold, 'صافي الاستهلاك'),
                        _tableHeader(arabicBold, 'سعة القاطع / التعرفة'),
                      ],
                    ),
                    // Row 1 (Zebra Light)
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        _tableCell(arabicFont, '01/$_selectedMonth/$_selectedYear - 30/$_selectedMonth/$_selectedYear'),
                        _tableCell(arabicFont, '1,250.00'),
                        _tableCell(arabicFont, '${(1250.0 + totalKwh).toStringAsFixed(2)}'),
                        _tableCell(arabicBold, '${totalKwh.toStringAsFixed(1)} kWh'),
                        _tableCell(arabicFont, '63A / $spaceTypeLabel'),
                      ],
                    ),
                    // Row 2 (Zebra Striped)
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightBgColor),
                      children: [
                        _tableCell(arabicFont, 'المجموع المالي للحركات'),
                        _tableCell(arabicFont, '-'),
                        _tableCell(arabicFont, '-'),
                        _tableCell(arabicBold, '${consumptionCost.toStringAsFixed(2)} LYD'),
                        _tableCell(arabicFont, 'تعرفة الفئة الأولى'),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // 5️⃣ التذييل والختم الإلكتروني (Footer & QR Verification)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(color: greyBorder, width: 1.0)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('هذه الفاتورة مستخرجة آلياً من نظام SmartEnergy لإدارة الطاقة الذكية ولا تحتاج إلى توقيع.', textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text('SMARTER ENERGY. BETTER FUTURE.', style: pw.TextStyle(font: arabicBold, fontSize: 9, color: navyPrimary)),
                        ],
                      ),
                      pw.Container(
                        width: 48,
                        height: 48,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: navyPrimary, width: 1),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Center(
                          child: pw.Text('QR CODE\nVERIFIED', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: arabicBold, fontSize: 6, color: navyPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (f) async => pdf.save());
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(loc.tr('reportGenerated')),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.neonRed,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  pw.Expanded _infoCell(pw.Font font, pw.Font bold, String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(value, textDirection: pw.TextDirection.rtl, style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColor.fromHex('#00457F'))),
        ],
      ),
    );
  }

  pw.Padding _tableHeader(pw.Font font, String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        title,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.white),
      ),
    );
  }

  pw.Padding _tableCell(pw.Font font, String content) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        content,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromHex('#1E293B')),
      ),
    );
  }

  Future<void> _shareWhatsApp(AppLocalizations loc, dynamic data) async {
    final m = loc.isArabic ? _monthsAr[_selectedMonth - 1] : _monthsEn[_selectedMonth - 1];
    final msg = '📊 SmartEnergy — $m $_selectedYear\n⚡ ${data.totalKwh.toStringAsFixed(1)} kWh\n💰 ${data.estimatedBillLYD.toStringAsFixed(1)} LYD';
    try {
      await Share.share(msg);
    } catch (_) {}
  }
}

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

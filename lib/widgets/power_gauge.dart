import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🟢 بداية: مؤشر الطاقة الدائري النيوني الفاخر (Stitch Power Gauge Widget)
/// يعرض هذا العنصر معدل الاستهلاك اللحظي للطاقة الكلية بالواط.
/// تم حقن تصميمه البصري ونظام توهج النيون الفاخر من تصميم Stitch الشاشة _2
/// ═══════════════════════════════════════════════════════════════
class PowerGauge extends StatefulWidget {
  final double power;
  final double maxPower;

  const PowerGauge({
    super.key,
    required this.power,
    this.maxPower = 5000,
  });

  @override
  State<PowerGauge> createState() => _PowerGaugeState();
}

class _PowerGaugeState extends State<PowerGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldPower = 0;

  @override
  void initState() {
    super.initState();
    // متحرك القراءات الحية المتجاوب والسلس
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.power)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(PowerGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.power != widget.power) {
      _oldPower = oldWidget.power;
      _animation = Tween<double>(begin: _oldPower, end: widget.power)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final percentage = (value / widget.maxPower).clamp(0.0, 1.0);
        
        // 🟢 تحديد تدرج ألوان النيون المشعة المتجاوبة مع نسبة الحمل من تصميم Stitch
        final color = percentage > 0.8
            ? AppTheme.neonRed
            : (percentage > 0.5 ? AppTheme.neonAmber : AppTheme.neonCyan);

        final textColor = isDark ? Colors.white : AppTheme.lightText;
        final subColor = isDark ? Colors.white.withOpacity(0.6) : AppTheme.lightTextSecondary.withOpacity(0.6);
        
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🟢 بداية: توهج النيون الدائري المحيط بالمؤشر من خلفية تصميم Stitch _2
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(isDark ? 0.18 : 0.08),
                      blurRadius: 50,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              // 🔵 نهاية: توهج النيون الدائري

              // 🟢 بداية: حلقة القياس ثنائية اللون بنظام الرسم المتقدم CustomPaint
              CustomPaint(
                size: const Size(240, 240),
                painter: _NeonGaugePainter(
                  percentage: percentage,
                  gaugeColor: color,
                ),
              ),
              // 🔵 نهاية: حلقة القياس

              // 🟢 بداية: القراءة الرقمية الضخمة للواط بنمط خط Cairo المتوافق مع Stitch
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: AppTheme.getTextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ).copyWith(
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "WATTS",
                    style: AppTheme.getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: subColor,
                    ).copyWith(
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              // 🔵 نهاية: القراءة الرقمية
            ],
          ),
        );
      },
    );
  }
}

/// 🎨 رسام القوس النيوني المطور لمنصة Stitch
class _NeonGaugePainter extends CustomPainter {
  final double percentage;
  final Color gaugeColor;
  _NeonGaugePainter({required this.percentage, required this.gaugeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // 🟢 القوس الخلفي للزجاج المطفأ من Stitch
    final bgPaint = Paint()
      ..color = AppTheme.lightBorder.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, bgPaint,
    );

    // 🟢 علامات التدريج الدقيقة والأنيقة
    for (int i = 0; i <= 36; i++) {
      final angle = startAngle + (sweepAngle * i / 36);
      final isMain = i % 9 == 0;
      final innerR = radius - (isMain ? 18 : 14);
      final outerR = radius - 10;
      final p1 = Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle));
      final p2 = Offset(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle));
      canvas.drawLine(
        p1, p2,
        Paint()
          ..color = AppTheme.textMuted.withOpacity(isMain ? 0.35 : 0.15)
          ..strokeWidth = isMain ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    if (percentage <= 0) return;

    // 🟢 طبقة التوهج النيون الخارجية المضيئة
    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [AppTheme.primaryBlue.withOpacity(0.4), gaugeColor.withOpacity(0.4)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * percentage, false, glowPaint,
    );

    // 🟢 القوس الرئيسي الملون للقدرة المستمرة
    final fgPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [AppTheme.primaryBlue, AppTheme.accentCyan, gaugeColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * percentage, false, fgPaint,
    );

    // 🟢 النقطة المضيئة المتحركة في نهاية مؤشر القدرة
    final angle = startAngle + sweepAngle * percentage;
    final dotCenter = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    // توهج النقطة النيوني
    canvas.drawCircle(
      dotCenter, 10,
      Paint()
        ..color = gaugeColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // النواة اللامعة للنقطة
    canvas.drawCircle(dotCenter, 5, Paint()..color = Colors.white);
    canvas.drawCircle(dotCenter, 2.5, Paint()..color = gaugeColor);
  }

  @override
  bool shouldRepaint(covariant _NeonGaugePainter old) =>
      old.percentage != percentage || old.gaugeColor != gaugeColor;
}
/// 🔵 نهاية: مؤشر الطاقة الدائري النيوني الفاخر

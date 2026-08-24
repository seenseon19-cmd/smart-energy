import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// ودجت شعار التطبيق الموحد — AppLogo
/// الوظيفة: تقديم هوية بصرية موحدة لشعار SmartEnergy عبر الشاشات
/// ═══════════════════════════════════════════════════════════════
class AppLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool isDark;
  final bool isHorizontal;
  final bool showText;

  const AppLogo({
    super.key,
    this.iconSize = 24,
    this.fontSize = 20,
    this.isDark = true,
    this.isHorizontal = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    final iconWidget = Container(
      padding: EdgeInsets.all(iconSize * 0.35),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38BDF8), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(iconSize * 0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.bolt_rounded,
        color: Colors.white,
        size: iconSize,
      ),
    );

    if (!showText) return iconWidget;

    final textWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Smart',
          style: AppTheme.getTextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          'Energy',
          style: AppTheme.getTextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF38BDF8),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: iconSize * 0.45),
          textWidget,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 8),
          textWidget,
        ],
      );
    }
  }
}

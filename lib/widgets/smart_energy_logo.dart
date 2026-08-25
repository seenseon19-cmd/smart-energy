import 'package:flutter/material.dart';

/// الشعار الرسمي الوحيد للتطبيق.
///
/// يُستخدم الأصل نفسه في جميع الشاشات، بينما يحدد الاستدعاء الحجم المناسب
/// للسياق: كبير في Splash/Login/Register، وصغير في الواجهات الداخلية.
class SmartEnergyLogo extends StatelessWidget {
  final double size;
  final Alignment alignment;
  final EdgeInsetsGeometry margin;
  final BoxFit fit;
  final String semanticLabel;

  const SmartEnergyLogo({
    super.key,
    this.size = 96,
    this.alignment = Alignment.center,
    this.margin = EdgeInsets.zero,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'SmartEnergy',
  });

  static const String assetPath = 'assets/images/smart_energy_official_logo.webp';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Align(
        alignment: alignment,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: fit,
          filterQuality: FilterQuality.high,
          semanticLabel: semanticLabel,
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.bolt_rounded, color: Color(0xFF84CC16)),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'smart_energy_logo.dart';

/// غلاف توافق للمراجع القديمة؛ المصدر الحقيقي هو SmartEnergyLogo.
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
    // iconSize يبقى مدخلًا توافقياً حتى لا تنكسر الشاشات القديمة.
    return SmartEnergyLogo(
      size: showText ? (isHorizontal ? iconSize * 2.2 : iconSize * 3.2) : iconSize,
      semanticLabel: 'SmartEnergy',
    );
  }
}

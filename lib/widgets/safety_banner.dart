/// شريط الأمان — SafetyBanner (Lovable Neon Glass)
/// يعرض حالة الحماية (آمن/تحذير) بناءً على القدرة الحالية
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../core/app_animations.dart';

class SafetyBanner extends StatelessWidget {
  final double power;
  final double limit;
  const SafetyBanner({super.key, required this.power, this.limit = 5000});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isOverload = power > limit;
    final color = isOverload ? AppTheme.accentRed : AppTheme.accentGreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(children: [
            if (isOverload)
              SizedBox(
                width: 28,
                height: 28,
                child: Lottie.network(
                  AppAnimations.overloadWarning,
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (_, __, ___) => Icon(Icons.warning_rounded, color: color, size: 18),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_rounded, color: color, size: 18),
              ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              isOverload ? loc.tr('highLoadWarning') : loc.tr('overloadProtectionActive'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
              ),
              child: Text(isOverload ? loc.tr('alert') : loc.tr('secure'),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
            ),
          ]),
        ),
      ),
    );
  }
}

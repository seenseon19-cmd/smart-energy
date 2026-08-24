/// ══════════════════════════════════════════════════════════════════════════════
/// مكونات الرسوم المتحركة Lottie — LottieWidgets
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_animations.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// 1. زر تبديل الثيم المتحرك — LottieThemeToggle
/// ══════════════════════════════════════════════════════════════════════════════
class LottieThemeToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final double size;

  const LottieThemeToggle({
    super.key,
    required this.isDark,
    required this.onToggle,
    this.size = 48,
  });

  @override
  State<LottieThemeToggle> createState() => _LottieThemeToggleState();
}

class _LottieThemeToggleState extends State<LottieThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      value: widget.isDark ? 0.5 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant LottieThemeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark) {
      if (widget.isDark) {
        _controller.animateTo(0.5, curve: Curves.easeInOut);
      } else {
        _controller.animateTo(0.0, curve: Curves.easeInOut);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final nextState = !widget.isDark;
    widget.onToggle(nextState);
    if (nextState) {
      _controller.animateTo(0.5, curve: Curves.easeInOut);
    } else {
      _controller.animateTo(0.0, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: widget.size + 16,
        height: widget.size * 0.7 + 10,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isDark
              ? const Color(0xFF1E2A42)
              : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF38BDF8).withOpacity(0.3)
                : const Color(0xFF2563EB).withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB))
                  .withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              widget.isDark ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            SizedBox(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              child: Lottie.network(
                AppAnimations.themeToggle,
                controller: _controller,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    widget.isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    color: widget.isDark ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                    size: 20,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════════
/// 2. زر تشغيل الطاقة المتحرك — LottiePowerToggle
/// ══════════════════════════════════════════════════════════════════════════════
class LottiePowerToggle extends StatefulWidget {
  final bool isOn;
  final VoidCallback onToggle;
  final double size;
  final bool isDark;

  const LottiePowerToggle({
    super.key,
    required this.isOn,
    required this.onToggle,
    this.size = 40,
    this.isDark = true,
  });

  @override
  State<LottiePowerToggle> createState() => _LottiePowerToggleState();
}

class _LottiePowerToggleState extends State<LottiePowerToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: widget.isOn ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant LottiePowerToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn) {
      if (widget.isOn) {
        _controller.animateTo(1.0, curve: Curves.easeInOut);
      } else {
        _controller.animateTo(0.0, curve: Curves.easeInOut);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOn = widget.isOn;
    final isDark = widget.isDark;

    return GestureDetector(
      onTap: () {
        widget.onToggle();
        if (!isOn) {
          _controller.animateTo(1.0, curve: Curves.easeInOut);
        } else {
          _controller.animateTo(0.0, curve: Curves.easeInOut);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn
              ? AppTheme.neonGreen.withOpacity(0.18)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          border: Border.all(
            color: isOn
                ? AppTheme.neonGreen
                : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08)),
            width: 1.5,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Lottie.network(
            AppAnimations.powerToggle,
            controller: _controller,
            width: widget.size * 0.75,
            height: widget.size * 0.75,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.power_settings_new_rounded,
                size: widget.size * 0.5,
                color: isOn
                    ? AppTheme.neonGreen
                    : (isDark ? Colors.white.withOpacity(0.35) : AppTheme.lightTextSecondary.withOpacity(0.5)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════════
/// 3. بطاقة ترشيد وخفض الاستهلاك — EnergySavingPromoCard
/// ══════════════════════════════════════════════════════════════════════════════
class EnergySavingPromoCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onAction;

  const EnergySavingPromoCard({
    super.key,
    required this.isDark,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // الأنيميشن
          SizedBox(
            width: 72,
            height: 72,
            child: Lottie.network(
              AppAnimations.energySavingPromo,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.energy_savings_leaf_rounded,
                color: Color(0xFF10B981),
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // النصوص والتفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ترشيد الطاقة 🌿',
                        style: AppTheme.getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'وفر حتى 25% من استهلاك الكهرباء',
                  style: AppTheme.getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'إيقاف الأجهزة غير الضرورية وقت الذروة يقلل من فاتورتك الشهرية بشكل فعال.',
                  style: AppTheme.getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
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
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════════
/// 4. نافذة التنبيه الإرشادي للترشيد — EnergyAdvisoryDialog
/// ══════════════════════════════════════════════════════════════════════════════
class EnergyAdvisoryDialog extends StatelessWidget {
  final bool isDark;

  const EnergyAdvisoryDialog({super.key, required this.isDark});

  static Future<void> showOnce(BuildContext context, bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool('energy_advisory_dialog_shown') ?? false;
    if (!alreadyShown) {
      await prefs.setBool('energy_advisory_dialog_shown', true);
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => EnergyAdvisoryDialog(isDark: isDark),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أنيميشن الإرشاد
              SizedBox(
                width: 140,
                height: 140,
                child: Lottie.network(
                  AppAnimations.energyAdvisoryDialog,
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Color(0xFFF59E0B),
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'إرشادات السلامة وترشيد الطاقة',
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'يقوم نظام الطاقة الذكي بمراقبة الأحمال وحمايتك من ارتفاع الجهد. نوصي بتوزيع استهلاك الأجهزة الثقيلة وتجنب تشغيلها دفعة واحدة.',
                style: AppTheme.getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'فهمت، متابعة للوحة التحكم ✅',
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════════════════════════
/// 5. بطاقة تحذير الحمل الزائد — OverloadWarningCard
/// ══════════════════════════════════════════════════════════════════════════════
class OverloadWarningCard extends StatelessWidget {
  final bool isDark;
  final double currentPower;
  final VoidCallback? onReset;

  const OverloadWarningCard({
    super.key,
    required this.isDark,
    required this.currentPower,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // أنيميشن التحذير
          SizedBox(
            width: 60,
            height: 60,
            child: Lottie.network(
              AppAnimations.overloadWarning,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ تحذير: زيادة في الحمل الكهربائي!',
                  style: AppTheme.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الاستهلاك الحالي (${currentPower.toStringAsFixed(0)}W) تجاوز الحد الآمن. تم تفعيل بروتوكول الحماية.',
                  style: AppTheme.getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إعادة ضبط', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/device_model.dart';
import '../l10n/app_localizations.dart';
import 'lottie_widgets.dart';

/// ═══════════════════════════════════════════════════════════════
/// 🟢 بداية: بطاقة التحكم الذكي بالجهاز (Stitch Premium Device Card)
/// تم حقن تصميمها الهيكلي من شاشة شبكة الأجهزة الذكية لـ Stitch الشاشة _4
/// وتجسيد تأثير التفاعل الحركي وتأثير الرمادي عند الإيقاف OFF.
/// ═══════════════════════════════════════════════════════════════
class DeviceCard extends StatefulWidget {
  final DeviceModel device;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;
  final bool isDark;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
    this.onDelete,
    this.isDark = false,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isPressed = false;

  /// 🟢 بداية: تخصيص الألوان الدائرية للأيقونات ديناميكياً لتناسب طبيعة الجهاز
  Color _getDeviceColor() {
    switch (widget.device.iconKey) {
      case 'snowflake':
      case 'temperature':
        return AppTheme.neonCyan;
      case 'kitchen':
      case 'blender':
        return const Color(0xFF10B981); // أخضر زمردي نشط
      case 'droplet':
      case 'shower':
      case 'fire':
        return AppTheme.neonAmber;
      case 'lightbulb':
      case 'bolt':
        return const Color(0xFFFBBF24); // أصفر متوهج للإنارة
      case 'tv':
      case 'computer':
        return const Color(0xFF8B5CF6); // بنفسجي ذكي للأجهزة التقنية
      case 'couch':
        return const Color(0xFFF97316); // برتقالي مريح للمساحات المعيشية
      default:
        return AppTheme.neonCyan;
    }
  }
  /// 🔵 نهاية: تخصيص الألوان الدائرية للأيقونات

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isOn = widget.device.isOn;
    final deviceColor = _getDeviceColor();

    // 🟢 بداية: هيكل التفاعل التلمسي الحركي عند الضغط (تقلص الحجم بنسبة 98%) من تصميم Stitch
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onToggle,
      onLongPress: widget.onDelete,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Opacity(
          // 🟢 تأثير التعتيم بنسبة 75% للأجهزة المطفأة (OFF) لجذب الانتباه للأجهزة النشطة
          opacity: isOn ? 1.0 : 0.75,
          child: widget.isDark
              ? AppTheme.darkGlassCard(
                  radius: AppTheme.radius2Xl,
                  isStrong: isOn,
                  child: _buildCardContent(isOn, deviceColor, loc),
                )
              : AppTheme.glassCard(
                  radius: AppTheme.radius2Xl,
                  isStrong: isOn,
                  child: _buildCardContent(isOn, deviceColor, loc),
                ),
        ),
      ),
    );
  }

  Widget _buildCardContent(bool isOn, Color deviceColor, AppLocalizations loc) {
    final isDark = widget.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        // تدرج لوني خفيف للغاية عند التشغيل ليعكس وهج الإشارة
        color: isOn
            ? deviceColor.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radius2Xl),
        border: Border.all(
          color: isOn
              ? deviceColor.withOpacity(0.3)
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
          width: isOn ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🟢 أيقونة الجهاز الذكي الدائرية الملونة المتوهجة بنظام نيون ثنائي اللون
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isOn
                      ? deviceColor.withOpacity(0.12)
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOn
                        ? deviceColor.withOpacity(0.25)
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06)),
                  ),
                  boxShadow: isOn
                      ? [
                          // 🟢 وهج نيون مضيء خلف الأيقونة النشطة من تصميم Stitch _4
                          BoxShadow(
                            color: deviceColor.withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ]
                      : [],
                ),
                child: FaIcon(
                  widget.device.icon,
                  size: 18,
                  color: isOn ? deviceColor : (isDark ? Colors.white.withOpacity(0.4) : AppTheme.lightTextSecondary.withOpacity(0.4)),
                ),
              ),
              // 🟢 زر طاقة دائري متحرك (Lottie Power Toggle)
              LottiePowerToggle(
                isOn: isOn,
                onToggle: widget.onToggle,
                isDark: isDark,
                size: 38,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الجهاز بخط Cairo
              Text(
                widget.device.name,
                style: AppTheme.getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? (isOn ? Colors.white : Colors.white.withOpacity(0.6))
                      : (isOn ? AppTheme.lightText : AppTheme.lightTextSecondary),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // مؤشر نبض الحالة الدائري الصغير
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOn ? AppTheme.neonGreen : (isDark ? Colors.white.withOpacity(0.3) : AppTheme.lightTextSecondary.withOpacity(0.3)),
                      boxShadow: isOn
                          ? [
                              BoxShadow(
                                color: AppTheme.neonGreen.withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOn ? loc.tr('deviceOn') : loc.tr('deviceOff'),
                    style: AppTheme.getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isOn
                          ? AppTheme.neonGreen
                          : (isDark ? Colors.white.withOpacity(0.4) : AppTheme.lightTextSecondary),
                    ),
                  ),
                  const Spacer(),
                  // قراءة الاستهلاك المحددة بالواط
                  Text(
                    '${widget.device.wattage}W',
                    style: AppTheme.getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white.withOpacity(0.3) : AppTheme.lightTextSecondary.withOpacity(0.5),
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
}
/// 🔵 نهاية: بطاقة التحكم الذكي بالجهاز

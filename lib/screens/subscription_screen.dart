/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة باقات الاشتراك — SubscriptionScreen (Stitch Dark Premium Design)
/// الوظيفة: عرض 4 باقات ملونة (مجاني، برونزي، احترافي، ذهبي) مع تبديل شخصي/تجاري
/// ══════════════════════════════════════════════════════════════════════════════
// 🚨 تنبيه أمني صارم للذكاء الاصطناعي: ممنوع تعديل منطق حفظ بيانات الاشتراك أو الربط بقاعدة البيانات الخلفية!
// 🚨 عملك محصور في المظهر البصري لـ Stitch _7 وتصميم الكروت المتدرجة الأربعة والأزرار التفاعلية بالتعليقات العربية.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isCommercial = false;
  int _selectedDuration = 0; // شهر

  int _getPlanIndex(String planKey, bool isCommercial) {
    if (isCommercial) {
      switch (planKey) {
        case 'basic': return 1;
        case 'pro':   return 2;
        case 'gold':  return 3;
        case 'free':
        default:      return 0;
      }
    } else {
      switch (planKey) {
        case 'bronze': return 1;
        case 'pro':    return 2;
        case 'gold':   return 3;
        case 'free':
        default:       return 0;
      }
    }
  }

  String _getPlanKeyFromIndex(int index, bool isCommercial) {
    if (isCommercial) {
      switch (index) {
        case 1: return 'basic';
        case 2: return 'pro';
        case 3: return 'gold';
        default: return 'free';
      }
    } else {
      switch (index) {
        case 1: return 'bronze';
        case 2: return 'pro';
        case 3: return 'gold';
        default: return 'free';
      }
    }
  }

  /// 🟢 حساب السعر ديناميكياً مع تطبيق الخصومات (10% لـ 3 أشهر و20% لـ سنة) كإضافة نوعية للـ UX
  String _getPriceText(_Tier tier, AppLocalizations loc) {
    if (tier.price == '0') return loc.tr('free');
    final double basePrice = double.tryParse(tier.price) ?? 0.0;
    double finalPrice = basePrice;
    String durationLabel = 'شهر';
    
    if (_selectedDuration == 1) {
      finalPrice = (basePrice * 3) * 0.9; // خصم 10% لفترة 3 أشهر
      durationLabel = '3 أشهر';
    } else if (_selectedDuration == 2) {
      finalPrice = (basePrice * 12) * 0.8; // خصم 20% لفترة سنة كاملة
      durationLabel = 'سنة';
    }
    
    return '${finalPrice.toInt()} د.ل / $durationLabel';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final energyProvider = context.watch<EnergyProvider>();
    final commercialEligible = energyProvider.hasActiveCommercialSpace;
    final isCommercial = _isCommercial && commercialEligible;
    final currentPlanKey = isCommercial ? energyProvider.commercialPlan : energyProvider.residentialPlan;
    final activeIndex = _getPlanIndex(currentPlanKey, isCommercial);

    final plans = isCommercial ? _commercialPlans(loc) : _personalPlans(loc);
    final durations = ['شهر', '3 أشهر', 'سنة'];
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: isDark ? AppTheme.darkBackgroundDecoration : AppTheme.lightBackgroundDecoration,
        child: Stack(
          children: [
            // طبقات النيون المتوهجة المحيطية لتضفي عمقاً زجاجياً خلف الباقات
            ...AppTheme.buildGlowLayers(),

            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  loc.tr('upgradePlan'),
                  style: AppTheme.getTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppTheme.darkText : AppTheme.lightText),
                ),
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // ══════════════════════════════════════
                    // 🟢 مفتاح التبديل البيضاوي المركزي للخطط (شخصي / تجاري)
                    // ══════════════════════════════════════
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _tab(
                            loc.tr('personal'), 
                            !_isCommercial,
                            isDark,
                            () => setState(() { _isCommercial = false; }),
                          ),
                          const SizedBox(width: 4),
                          if (commercialEligible) ...[
                            const SizedBox(width: 4),
                            _tab(
                              loc.tr('commercial'),
                              isCommercial,
                              isDark,
                              () => setState(() => _isCommercial = true),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ══════════════════════════════════════
                    // 🟢 مبدل المدد البيضاوي (شهر / 3 أشهر / سنة)
                    // ══════════════════════════════════════
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08)),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: List.generate(3, (i) => Expanded(
                          child: _InteractiveScale(
                            onTap: () => setState(() => _selectedDuration = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: _selectedDuration == i ? AppTheme.primaryGradient : null,
                                color: _selectedDuration == i ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: _selectedDuration == i
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryBlue.withOpacity(0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                durations[i],
                                textAlign: TextAlign.center,
                                style: AppTheme.getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedDuration == i ? Colors.white : (isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary),
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ══════════════════════════════════════
                    // 🟢 شبكة عرض الباقات الأربعة العمودية الساحرة
                    // ══════════════════════════════════════
                    ...plans.asMap().entries.map((e) => _buildCard(e.value, e.key, activeIndex, loc, isDark, energyProvider)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 كبسولة التبويب المخصصة لتبديل نوع الباقات شخصي/تجاري
  Widget _tab(String label, bool sel, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: _InteractiveScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: sel ? AppTheme.primaryGradient : null,
            color: sel ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: sel ? Colors.white : (isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  /// 🟢 بناء كروت الباقات الأربعة بتصميم زجاجي وتدرجات لونية مطابقة لـ Stitch _7
  Widget _buildCard(_Tier tier, int index, int activeIndex, AppLocalizations loc, bool isDark, EnergyProvider energyProvider) {
    final isCommercialContext = _isCommercial && energyProvider.hasActiveCommercialSpace;
    final isPro = tier.name == loc.tr('professionalPlan');
    final isGold = tier.name == loc.tr('goldPlan');
    final isActivePlan = (index == activeIndex);
    final sel = isActivePlan;

    // 🟡 لون التمييز: ذهبي للباقة الذهبية، سيان للاحترافية، أزرق للبقية
    final Color accentColor = isGold
        ? AppTheme.accentAmber
        : (isPro ? (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue) : AppTheme.accentCyan);

    Widget cardBody = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟡 شريط التدرج الذهبي العلوي للباقة الذهبية فقط
          if (isGold) ...[
            Container(
              width: double.infinity,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name,
                      style: AppTheme.getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isGold ? AppTheme.accentAmber : (isDark ? AppTheme.darkText : AppTheme.lightText),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.dur,
                      style: AppTheme.getTextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActivePlan || tier.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    // 🟡 الباقة الذهبية تستخدم AppTheme.goldGradient كخلفية للشارة
                    gradient: isGold ? AppTheme.goldGradient : null,
                    color: isGold ? null : accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: isGold ? Colors.transparent : accentColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    isActivePlan ? 'الباقة النشطة ✅' : tier.badge!,
                    style: AppTheme.getTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isGold ? Colors.white : accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getPriceText(tier, loc),
            style: AppTheme.getTextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isGold ? AppTheme.accentAmber : (isDark ? AppTheme.neonCyan : AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          ...tier.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: isGold ? AppTheme.accentAmber : (isDark ? AppTheme.neonCyan : AppTheme.accentCyan),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: AppTheme.getTextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          
          // 🟢 بداية: زر الترقية التفاعلي المضاء (Upgrade / Activate Button) بأسفل الكرت
          const SizedBox(height: 20),
          _InteractiveScale(
            onTap: isActivePlan ? null : () {
              final newPlanKey = _getPlanKeyFromIndex(index, isCommercialContext);
              if (isCommercialContext) {
                energyProvider.setCommercialPlan(newPlanKey);
              } else {
                energyProvider.setResidentialPlan(newPlanKey);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تفعيل باقة ${tier.name} بنجاح ✅'),
                  backgroundColor: AppTheme.neonGreen,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                // 🟡 زر الذهبية يستخدم AppTheme.goldGradient
                gradient: isGold && !isActivePlan ? AppTheme.goldGradient : null,
                color: isGold
                    ? null
                    : (isActivePlan
                        ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05))
                        : AppTheme.primaryBlue),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActivePlan
                      ? (isDark ? AppTheme.darkBorder.withOpacity(0.2) : Colors.black.withOpacity(0.1))
                      : Colors.transparent,
                ),
                boxShadow: isGold && !isActivePlan
                    ? [
                        BoxShadow(
                          color: AppTheme.accentAmber.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                isActivePlan ? 'الباقة الحالية' : 'ترقية وتفعيل الباقة',
                style: AppTheme.getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isActivePlan
                      ? (isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary)
                      : Colors.white,
                ),
              ),
            ),
          ),
          // 🔵 نهاية: زر الترقية التفاعلي
        ],
      ),
    );

    // بناء الكرت زجاجياً أو متدرجاً
    return GestureDetector(
      onTap: isActivePlan ? null : () {
        final newPlanKey = _getPlanKeyFromIndex(index, isCommercialContext);
        if (isCommercialContext) {
          energyProvider.setCommercialPlan(newPlanKey);
        } else {
          energyProvider.setResidentialPlan(newPlanKey);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        child: isDark
            ? AppTheme.darkGlassCard(
                radius: 24,
                isStrong: sel || isPro || isGold,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isGold
                          ? AppTheme.accentAmber.withOpacity(0.7)
                          : (isPro 
                              ? AppTheme.neonCyan.withOpacity(0.8) 
                              : (sel ? AppTheme.neonCyan.withOpacity(0.5) : Colors.transparent)),
                      width: isGold ? 2.0 : (isPro ? 2.5 : (sel ? 1.5 : 0.0)),
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: cardBody,
                ),
              )
            : AppTheme.glassCard(
                radius: 24,
                isStrong: sel || isPro || isGold,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isGold
                          ? AppTheme.accentAmber.withOpacity(0.7)
                          : (isPro 
                              ? AppTheme.primaryBlue.withOpacity(0.8) 
                              : (sel ? AppTheme.accentCyan.withOpacity(0.5) : Colors.transparent)),
                      width: isGold ? 2.0 : (isPro ? 2.5 : (sel ? 1.5 : 0.0)),
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: cardBody,
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // الباقات الشخصية الـ 4 بألوان متدرجة
  // ══════════════════════════════════════════════════════════════
  List<_Tier> _personalPlans(AppLocalizations l) => [
    _Tier(
      l.tr('free'), '0', l.tr('free'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 2', l.tr('basicDashboard')],
      null, null, null,
    ),
    _Tier(
      l.tr('basicPlan'), '15', l.tr('oneMonth'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 6', l.tr('consumption30Days'), l.tr('reports')],
      null,
      const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      const Color(0xFF7C3AED),
    ),
    _Tier(
      l.tr('professionalPlan'), '35', l.tr('threeMonths'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 15', l.tr('reports'), l.tr('scheduling'), l.tr('smartAlerts')],
      'الباقة الحالية',
      const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      AppTheme.accentCyan,
    ),
    _Tier(
      l.tr('goldPlan'), '50', l.tr('unlimited'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: ${l.tr('unlimited')}', l.tr('reports'), l.tr('scheduling'), l.tr('prioritySupport'), l.tr('support247')],
      l.tr('bestValue'),
      AppTheme.goldGradient,
      AppTheme.accentAmber,
    ),
  ];

  // ══════════════════════════════════════════════════════════════
  // الباقات التجارية الـ 4
  // ══════════════════════════════════════════════════════════════
  List<_Tier> _commercialPlans(AppLocalizations l) => [
    _Tier(
      l.tr('free'), '0', l.tr('free'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 5'],
      null, null, null,
    ),
    _Tier(
      l.tr('basicPlan'), '50', l.tr('oneMonth'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 20', l.tr('reports')],
      null,
      const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      const Color(0xFF7C3AED),
    ),
    _Tier(
      l.tr('professionalPlan'), '120', l.tr('threeMonths'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: 50', l.tr('reports'), l.tr('scheduling')],
      l.tr('mostPopular'),
      const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF10B981)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      AppTheme.accentCyan,
    ),
    _Tier(
      l.tr('goldPlan'), '400', l.tr('unlimited'),
      [l.tr('monitoring'), '${l.tr('maxDevices')}: ${l.tr('unlimited')}', l.tr('reports'), l.tr('prioritySupport')],
      l.tr('bestValue'),
      AppTheme.goldGradient,
      AppTheme.accentAmber,
    ),
  ];
}

class _Tier {
  final String name, price, dur;
  final List<String> features;
  final String? badge;
  final LinearGradient? gradient;
  final Color? glowColor;
  const _Tier(this.name, this.price, this.dur, this.features, this.badge, this.gradient, this.glowColor);
}

// ═══════════════════════════════════════════════════════════════
// 🟢 حاوية التفاعل التلمسي الحركي (Stitch Interactive Scale Effect)
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

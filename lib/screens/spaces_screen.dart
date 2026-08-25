/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إدارة المساحات والزونات الديناميكية — SpacesScreen
/// الوظيفة: إضافة، حذف، والتنقل بين المساحات الفعلية للمستخدم برياضيات الاستهلاك اللحظي
/// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../models/space_model.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final provider = context.watch<EnergyProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final spaces = provider.spaces;
    final currentSpaceId = provider.currentSpaceId;

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
              loc.tr('spacesLabel'),
              style: AppTheme.getTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkText : AppTheme.lightText,
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: FaIcon(FontAwesomeIcons.arrowRight, color: isDark ? AppTheme.darkText : AppTheme.lightText, size: 18),
            ),
          ),
          body: Stack(
            children: [
              ...AppTheme.buildGlowLayers(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ترويسة العنوان + زر إضافة مساحة جديدة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.tr('yourSmartSpaces'),
                              style: AppTheme.getTextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppTheme.darkText : AppTheme.lightText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.tr('manageSpacesDesc'),
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        _InteractiveScale(
                          onTap: () => _showAddSpaceDialog(context, provider, isDark, loc),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 12),
                                const SizedBox(width: 6),
                                Text(
                                  loc.tr('addSpace'),
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
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
                    const SizedBox(height: 16),

                    // قائمة المساحات الديناميكية
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: spaces.length,
                        itemBuilder: (context, index) {
                          final space = spaces[index];
                          final isSelected = currentSpaceId == space.id;
                          final devicesCount = provider.devicesCountForSpace(space.id);
                          final spacePower = provider.powerForSpace(space.id);
                          final isCommercial = space.type == 'commercial';
                          final Color iconColor = isCommercial ? AppTheme.neonAmber : AppTheme.accentCyan;
                          final spaceTag = isCommercial ? loc.tr('commercialLabel') : loc.tr('residentialLabel');

                          final cardContent = Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: iconColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: iconColor.withOpacity(0.25)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: iconColor.withOpacity(0.15),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: FaIcon(
                                              isCommercial ? FontAwesomeIcons.building : FontAwesomeIcons.house,
                                              color: iconColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  space.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  spaceTag,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.neonGreen.withOpacity(0.15)
                                                : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)),
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(
                                                color: isSelected ? AppTheme.neonGreen.withOpacity(0.5) : Colors.transparent),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: isSelected ? AppTheme.neonGreen : Colors.grey,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isSelected ? loc.tr('active') : loc.tr('dormant'),
                                                style: AppTheme.getTextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: isSelected ? AppTheme.neonGreen : (isDark ? Colors.white60 : AppTheme.lightTextSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (spaces.length > 1) ...[
                                          const SizedBox(width: 4),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            icon: const FaIcon(FontAwesomeIcons.trashCan, color: AppTheme.neonRed, size: 15),
                                            onPressed: () => _showDeleteSpaceDialog(context, provider, space, isDark, loc),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                                        ),
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.plug, color: iconColor, size: 16),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loc.tr('devicesCount').replaceAll('{count}', '$devicesCount'),
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                                  ),
                                                ),
                                                Text(
                                                  loc.tr('connectedDevices'),
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.06)),
                                        ),
                                        child: Row(
                                          children: [
                                            const FaIcon(FontAwesomeIcons.bolt, color: AppTheme.neonGreen, size: 16),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${spacePower.toStringAsFixed(1)} kW/h',
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                                  ),
                                                ),
                                                Text(
                                                  loc.tr('currentConsumptionLabel'),
                                                  style: AppTheme.getTextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _InteractiveScale(
                                  onTap: () {
                                    provider.switchSpace(space.id);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: isSelected ? AppTheme.greenGradient : AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isSelected ? AppTheme.neonGreen : AppTheme.accentCyan)
                                              .withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FaIcon(
                                          isSelected ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.arrowRightArrowLeft,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isSelected ? loc.tr('activeNow') : loc.tr('switchToControl'),
                                          style: AppTheme.getTextStyle(
                                            fontSize: 13,
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

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: isDark
                                ? AppTheme.darkGlassCard(radius: 20, isStrong: isSelected, child: cardContent)
                                : AppTheme.glassCard(radius: 20, isStrong: isSelected, child: cardContent),
                          );
                        },
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
  }

  void _showAddSpaceDialog(BuildContext context, EnergyProvider provider, bool isDark, AppLocalizations loc) {
    final nameCtrl = TextEditingController();
    String selectedType = 'residential';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.5)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const FaIcon(FontAwesomeIcons.layerGroup, color: AppTheme.accentCyan, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  loc.tr('addNewSpace'),
                  style: AppTheme.getTextStyle(
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: AppTheme.getTextStyle(
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: loc.tr('spaceName'),
                        labelStyle: AppTheme.getTextStyle(
                          color: isDark ? AppTheme.darkText.withOpacity(0.6) : AppTheme.lightTextSecondary,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E2A42) : const Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.tr('spaceTypeAndLimit'),
                      style: AppTheme.getTextStyle(
                        color: isDark ? AppTheme.darkText.withOpacity(0.9) : AppTheme.lightTextSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDlgState(() => selectedType = 'residential'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                color: selectedType == 'residential' ? AppTheme.accentCyan.withOpacity(0.18) : (isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedType == 'residential' ? AppTheme.accentCyan : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const FaIcon(FontAwesomeIcons.house, color: AppTheme.accentCyan, size: 22),
                                  const SizedBox(height: 8),
                                  Text(
                                    loc.tr('residential'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.tr('limit8Devices'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDlgState(() => selectedType = 'commercial'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                color: selectedType == 'commercial' ? AppTheme.neonAmber.withOpacity(0.18) : (isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedType == 'commercial' ? AppTheme.neonAmber : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const FaIcon(FontAwesomeIcons.building, color: AppTheme.neonAmber, size: 22),
                                  const SizedBox(height: 8),
                                  Text(
                                    loc.tr('commercial'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.tr('limit12Devices'),
                                    style: AppTheme.getTextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(loc.tr('cancel'), style: AppTheme.getTextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: isSaving ? null : () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى إدخال اسم المساحة'),
                        backgroundColor: Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  final exists = provider.spaces.any(
                    (s) => s.name.trim().toLowerCase() == name.toLowerCase(),
                  );
                  if (exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚠️ توجد مساحة باسم "$name" مسبقاً! يرجى اختيار اسم مختلف.'),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  setDlgState(() => isSaving = true);
                  try {
                    await provider.addSpace(name, selectedType);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تمت إضافة مساحة "$name" بنجاح ✅'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      setDlgState(() => isSaving = false);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ أثناء إضافة المساحة: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                    : Text(loc.tr('createSpace'), style: AppTheme.getTextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteSpaceDialog(BuildContext context, EnergyProvider provider, SpaceModel space, bool isDark, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF10192C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withOpacity(0.4)),
          ),
          title: Text(loc.tr('deleteSpace'), style: AppTheme.getTextStyle(color: isDark ? AppTheme.darkText : AppTheme.lightText, fontSize: 18, fontWeight: FontWeight.w900)),
          content: Text(loc.tr('deleteSpaceConfirm').replaceAll('{name}', space.name), style: AppTheme.getTextStyle(color: isDark ? AppTheme.darkText.withOpacity(0.7) : AppTheme.lightTextSecondary, fontSize: 13)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.tr('cancel'), style: AppTheme.getTextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                try {
                  if (ctx.mounted) Navigator.pop(ctx);
                  await provider.removeSpace(space.id);
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: Text(loc.tr('delete'), style: AppTheme.getTextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
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


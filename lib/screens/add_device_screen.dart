import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/device_model.dart';
import '../providers/energy_provider.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// شاشة إضافة جهاز ذكي جديد — AddDeviceScreen
/// خالية تماماً من الشاشات البيضاء أو أخطاء التقديم
/// ══════════════════════════════════════════════════════════════════════════════
class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wattController = TextEditingController(text: '500');

  String _selectedRelay = '';
  String _selectedIconKey = 'plug';
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _quickPresets = [
    {'name': 'تكييف الصالة', 'watt': '2000', 'icon': 'snowflake'},
    {'name': 'الثلاجة المنزلية', 'watt': '300', 'icon': 'kitchen'},
    {'name': 'سخان الماء', 'watt': '2500', 'icon': 'droplet'},
    {'name': 'التبريد المركزي', 'watt': '3500', 'icon': 'snowflake'},
    {'name': 'الإنارة الرئيسية', 'watt': '150', 'icon': 'lightbulb'},
    {'name': 'التلفاز الذكي', 'watt': '120', 'icon': 'tv'},
    {'name': 'مضخة المياه', 'watt': '1100', 'icon': 'fire'},
    {'name': 'خادم البيانات / الراوتر', 'watt': '80', 'icon': 'wifi'},
    {'name': 'ماكينة القهوة', 'watt': '1400', 'icon': 'kitchen'},
    {'name': 'مروحة التهوية', 'watt': '75', 'icon': 'fan'},
  ];

  final List<Map<String, dynamic>> _availableIcons = [
    {'key': 'plug', 'label': 'مقبس', 'icon': Icons.power_rounded},
    {'key': 'lightbulb', 'label': 'إنارة', 'icon': Icons.lightbulb_rounded},
    {'key': 'snowflake', 'label': 'تكييف', 'icon': Icons.ac_unit_rounded},
    {'key': 'tv', 'label': 'شاشة', 'icon': Icons.tv_rounded},
    {'key': 'kitchen', 'label': 'مطبخ', 'icon': Icons.kitchen_rounded},
    {'key': 'droplet', 'label': 'سخان', 'icon': Icons.water_drop_rounded},
    {'key': 'fan', 'label': 'مروحة', 'icon': Icons.toys_rounded},
    {'key': 'computer', 'label': 'حاسوب', 'icon': Icons.laptop_mac_rounded},
    {'key': 'wifi', 'label': 'شبكة', 'icon': Icons.router_rounded},
    {'key': 'solar', 'label': 'طاقة', 'icon': Icons.solar_power_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDefaultRelay();
    });
  }

  void _initDefaultRelay() {
    final provider = context.read<EnergyProvider>();
    final occupied = <String>{};
    for (final dev in provider.devices) {
      if (dev.relayId.isNotEmpty) {
        occupied.add(dev.relayId);
      }
    }
    for (final relay in DeviceModel.availableRelays) {
      if (!occupied.contains(relay)) {
        setState(() => _selectedRelay = relay);
        break;
      }
    }
    if (_selectedRelay.isEmpty && DeviceModel.availableRelays.isNotEmpty) {
      _selectedRelay = DeviceModel.availableRelays.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wattController.dispose();
    super.dispose();
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _nameController.text = preset['name'] as String;
      _wattController.text = preset['watt'] as String;
      _selectedIconKey = preset['icon'] as String;
      _errorMessage = null;
    });
  }

  Future<void> _submitDevice(EnergyProvider provider, AppLocalizations loc) async {
    if (_isLoading) return;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'يرجى كتابة اسم الجهاز أو اختيار نموذج جاهز');
      return;
    }

    final watt = int.tryParse(_wattController.text.trim()) ?? 0;
    if (watt <= 0) {
      setState(() => _errorMessage = 'يرجى إدخال استهلاك واط صالح أكبر من 0');
      return;
    }

    if (provider.isCurrentSpaceFull) {
      setState(() => _errorMessage = 'تم الوصول للحد الأقصى لأجهزة هذه المساحة');
      return;
    }

    final occupiedRelays = <String, String>{};
    for (final d in provider.devices) {
      if (d.relayId.isNotEmpty) {
        occupiedRelays[d.relayId] = d.name;
      }
    }

    if (_selectedRelay.isNotEmpty && occupiedRelays.containsKey(_selectedRelay)) {
      final occupiedBy = occupiedRelays[_selectedRelay];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ المنفذ (${_selectedRelay.replaceAll('relay', 'مخرج ')}) مشغول مسبقاً بجهاز "$occupiedBy"! يرجى اختيار منفذ متاح.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _errorMessage = 'المنفذ المختار مشغول مسبقاً بجهاز "$occupiedBy"');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final newDevice = DeviceModel(
        id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        iconKey: _selectedIconKey,
        relayId: _selectedRelay,
        wattage: watt,
        isOn: false,
        spaceId: provider.currentSpace.id,
      );

      final success = await provider.addDevice(newDevice);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        final messenger = ScaffoldMessenger.of(context);
        if (mounted) Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('تمت إضافة جهاز "${newDevice.name}" بنجاح ⚡'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() => _errorMessage = 'فشلت إضافة الجهاز، تأكد من عدد الأجهزة المسموح');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ أثناء إضافة الجهاز: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ الجهاز: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final provider = context.watch<EnergyProvider>();

    final cardColor = isDark ? const Color(0xFF10192C) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final Map<String, String> occupiedRelays = {};
    for (final d in provider.devices) {
      if (d.relayId.isNotEmpty) {
        occupiedRelays[d.relayId] = d.name;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            loc.tr('addDevice'),
            style: AppTheme.getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: cardBorder, height: 1),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة المساحة المستهدفة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.room_preferences_rounded, color: Color(0xFF38BDF8), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'إضافة للمساحة: ',
                        style: AppTheme.getTextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        provider.currentSpace.name,
                        style: AppTheme.getTextStyle(fontSize: 14, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.devices.length}/${provider.currentSpaceDeviceLimit}',
                        style: AppTheme.getTextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // رسالة الخطأ إن وجدت
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme.getTextStyle(
                              color: const Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. نماذج الأجهزة السريعة
                Text(
                  'أجهزة شائعة جاهزة:',
                  style: AppTheme.getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickPresets.map((preset) {
                    final isSelected = _nameController.text == preset['name'];
                    return InkWell(
                      onTap: () => _selectPreset(preset),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              preset['name'] as String,
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${preset['watt']}W',
                              style: AppTheme.getTextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : const Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 2. حقل اسم الجهاز
                Text(
                  'اسم الجهاز:',
                  style: AppTheme.getTextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: AppTheme.getTextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'مثال: مكيف الصالون، إنارة الحديقة...',
                    hintStyle: AppTheme.getTextStyle(color: textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF10192C) : Colors.white,
                    prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 3. حقل الاستهلاك التقديري بالواط
                Text(
                  'الاستهلاك التقديري (واط / Watts):',
                  style: AppTheme.getTextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _wattController,
                  keyboardType: TextInputType.number,
                  style: AppTheme.getTextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText: '500',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF10192C) : Colors.white,
                    prefixIcon: const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 20),
                    suffixText: 'Watts',
                    suffixStyle: AppTheme.getTextStyle(color: const Color(0xFFF59E0B), fontWeight: FontWeight.w800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 4. اختيار منفذ ريلي ESP32
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'منفذ ريلي التحكم (ESP32 Relay Output):',
                      style: AppTheme.getTextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                    ),
                    Text(
                      '8 منافذ متوفرة',
                      style: AppTheme.getTextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.3,
                  ),
                  itemCount: DeviceModel.availableRelays.length,
                  itemBuilder: (ctx, index) {
                    final relay = DeviceModel.availableRelays[index];
                    final isOccupied = occupiedRelays.containsKey(relay);
                    final isSelected = _selectedRelay == relay && !isOccupied;
                    final relayNum = 'Relay ${index + 1}';

                    return InkWell(
                      onTap: isOccupied
                          ? null
                          : () {
                              setState(() {
                                _selectedRelay = relay;
                                _errorMessage = null;
                              });
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isOccupied
                              ? (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.04))
                              : (isSelected
                                  ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF2563EB))
                                  : (isDark ? const Color(0xFF10192C) : Colors.white)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isOccupied
                                ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08))
                                : (isSelected
                                    ? const Color(0xFF38BDF8)
                                    : (isDark ? const Color(0xFF10B981).withOpacity(0.4) : const Color(0xFF10B981).withOpacity(0.5))),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              relayNum,
                              style: AppTheme.getTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isOccupied
                                    ? textSecondary.withOpacity(0.4)
                                    : (isSelected ? Colors.white : textPrimary),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isOccupied ? 'غير متاح' : 'متاح',
                              style: AppTheme.getTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isOccupied
                                    ? const Color(0xFFEF4444)
                                    : (isSelected ? Colors.white : const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // 5. اختيار الأيقونة
                Text(
                  'أيقونة الجهاز:',
                  style: AppTheme.getTextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableIcons.map((item) {
                    final key = item['key'] as String;
                    final isSelected = _selectedIconKey == key;
                    final iconData = item['icon'] as IconData;

                    return InkWell(
                      onTap: () => setState(() => _selectedIconKey = key),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF10192C) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : (isDark ? const Color(0xFF1E2A42) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData,
                              size: 24,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['label'] as String,
                              style: AppTheme.getTextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF334155)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // 6. زر حفظ وإضافة الجهاز
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                    ),
                    onPressed: _isLoading ? null : () => _submitDevice(provider, loc),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                loc.tr('saveAndAddDevice'),
                                style: AppTheme.getTextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
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
        ),
      ),
    );
  }
}

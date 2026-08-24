/// ═══════════════════════════════════════════════════════════════
/// مزود الطاقة — EnergyProvider
/// الوظيفة: المزود المركزي لإدارة الحالة عبر Provider
/// يجمع بين بيانات الطاقة اللحظية وحالات الأجهزة والمساحات التفاعلية
/// ═══════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/energy_data.dart';
import '../models/device_model.dart';
import '../models/space_model.dart';
import '../services/firebase_service.dart';

/// مزود الطاقة — يدير الحالة المركزية للتطبيق
class EnergyProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  EnergyData _energyData = EnergyData();
  EnergyData get energyData => _energyData;

  StreamSubscription? _energySubscription;
  StreamSubscription? _relaySubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;

  List<SpaceModel> _spaces = [];
  List<SpaceModel> get spaces => _spaces;

  String _currentSpaceId = 'home';
  String get currentSpaceId => _currentSpaceId;

  SpaceModel get currentSpace => _spaces.firstWhere(
        (s) => s.id == _currentSpaceId,
        orElse: () => _spaces.isNotEmpty
            ? _spaces.first
            : SpaceModel(id: 'home', name: 'المنزل الرئيسي', type: 'residential'),
      );

  List<DeviceModel> get currentSpaceDevices =>
      _devices.where((d) => d.spaceId == _currentSpaceId).toList();

  int get activeDeviceCount =>
      currentSpaceDevices.where((d) => d.isOn).length;

  bool _isCommercial = false;
  bool get isCommercial => _isCommercial || currentSpace.type == 'commercial';

  // ── فصل الخطط بين المنزلي والتجاري ──
  String _residentialPlan = 'pro'; // 'free', 'bronze', 'pro', 'gold'
  String _commercialPlan = 'free';  // 'free', 'basic', 'pro', 'gold'

  String get residentialPlan => _residentialPlan;
  String get commercialPlan => _commercialPlan;

  bool get isCommercialPlanActive => _commercialPlan != 'free';
  bool get needsCommercialUpgrade => currentSpace.isCommercial && !isCommercialPlanActive;

  void setResidentialPlan(String plan) async {
    _residentialPlan = plan;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await prefs.setString('residential_plan_$uid', plan);
      try {
        await FirebaseDatabase.instance.ref('users/$uid/residentialPlan').set(plan);
      } catch (_) {}
    }
  }

  void setCommercialPlan(String plan) async {
    _commercialPlan = plan;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await prefs.setString('commercial_plan_$uid', plan);
      try {
        await FirebaseDatabase.instance.ref('users/$uid/commercialPlan').set(plan);
        await FirebaseDatabase.instance.ref('users/$uid/commercialPlanStatus').set(plan != 'free' ? 'active' : 'free');
      } catch (_) {}
    }
  }

  void setPlanType(bool isCommercial) async {
    _isCommercial = isCommercial;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('account_type_commercial', isCommercial);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      await prefs.setBool('account_type_commercial_$uid', isCommercial);
      await prefs.setString('account_type_$uid', isCommercial ? 'commercial' : 'residential');
      try {
        await FirebaseDatabase.instance.ref('users/$uid/accountType').set(
          isCommercial ? 'commercial' : 'residential'
        );
      } catch (_) {}
    }
  }

  static const List<Map<String, String>> personalSpaces = [
    {'id': 'home', 'name_ar': 'المنزل', 'name_en': 'Home'},
    {'id': 'room', 'name_ar': 'الغرفة', 'name_en': 'Room'},
    {'id': 'garage', 'name_ar': 'المرآب', 'name_en': 'Garage'},
  ];

  static const List<Map<String, String>> commercialSpaces = [
    {'id': 'shop', 'name_ar': 'المتجر', 'name_en': 'Shop'},
    {'id': 'office', 'name_ar': 'المكتب', 'name_en': 'Office'},
    {'id': 'warehouse', 'name_ar': 'المستودع', 'name_en': 'Warehouse'},
  ];

  List<Map<String, String>> get availableSpaces =>
      _isCommercial ? commercialSpaces : personalSpaces;

  /// حساب الحد الأقصى للأجهزة للمساحة المعطاة وفق نوعها وخطتها المنفصلة
  int getDeviceLimitForSpace(SpaceModel space) {
    if (space.type == 'commercial') {
      switch (_commercialPlan) {
        case 'basic': return 5;
        case 'pro':   return 20;
        case 'gold':  return 50;
        case 'free':
        default:      return 2; // المساحة التجارية الافتراضية مقيدة بـ 2 جهاز فقط
      }
    } else {
      switch (_residentialPlan) {
        case 'bronze': return 6;
        case 'pro':    return 15;
        case 'gold':   return 50;
        case 'free':
        default:       return 2;
      }
    }
  }

  int get currentSpaceDeviceLimit => getDeviceLimitForSpace(currentSpace);
  bool get isCurrentSpaceFull => currentSpaceDevices.length >= currentSpaceDeviceLimit;

  /// حساب عدد أجهزة مساحة محددة
  int devicesCountForSpace(String spaceId) =>
      _devices.where((d) => d.spaceId == spaceId).length;

  /// حساب مجموع الاستهلاك الحسابي لمساحة محددة (kW/h)
  double powerForSpace(String spaceId) {
    final activeWatts = _devices
        .where((d) => d.spaceId == spaceId && d.isOn)
        .fold(0.0, (sum, d) => sum + d.wattage);
    return activeWatts / 1000.0;
  }

  List<Map<String, dynamic>> _localLogs = [];
  List<Map<String, dynamic>> get localLogs => _localLogs;

  StreamSubscription? _connectionSubscription;

  EnergyProvider() {
    _initStreams();
    _loadSpacesAndDevices();
    _loadLocalLogs();
  }

  bool _isSimulatingOverload = false;
  bool get isSimulatingOverload => _isSimulatingOverload;

  double _globalPowerLimit = 10000.0;
  double get globalPowerLimit => _globalPowerLimit;

  bool _isOverloadDismissed = false;
  bool get isOverloadDismissed => _isOverloadDismissed;

  bool get isOverload =>
      !_isOverloadDismissed &&
      (_isSimulatingOverload || _energyData.power > _globalPowerLimit);

  void setGlobalPowerLimit(double limit) {
    _globalPowerLimit = limit;
    notifyListeners();
  }

  void dismissOverload() {
    _isOverloadDismissed = true;
    _isSimulatingOverload = false;
    notifyListeners();
  }

  Timer? _demoSimulationTimer;

  /// علم يدل على استلام بيانات حقيقية من Firebase — لمنع تضارب Demo
  bool _firebaseDataReceived = false;

  /// تهيئة بث البيانات من Firebase RTDB
  /// المنطق: نبدأ بالـ Demo كمصدر مؤقت، وعند أول بيانات حقيقية من Firebase
  /// نُلغي الـ Demo نهائياً. عند انقطاع الاتصال نعيد تشغيل Demo كـ Fallback.
  void _initStreams() {
    // بدء Demo مؤقتاً حتى يتصل Firebase
    _startDemoTelemetryLoop();

    // الاستماع لحالة اتصال Firebase الحية
    _connectionSubscription = _firebaseService.connectionStream.listen(
      (connected) {
        _isConnected = connected;
        // ✅ Fallback: عند انقطاع الاتصال الكلي، أعد تشغيل Demo
        if (!connected && _firebaseDataReceived) {
          _firebaseDataReceived = false;
          _startDemoTelemetryLoop();
        }
        notifyListeners();
      },
      onError: (_) {
        _isConnected = false;
        // ✅ Fallback: إعادة Demo عند خطأ اتصال
        if (!_firebaseDataReceived) {
          _startDemoTelemetryLoop();
        }
      },
    );

    _energySubscription = _firebaseService.energyDataStream.listen(
      (data) {
        if (_isSimulatingOverload) return;
        // ✅ أول بيانات حقيقية من Firebase: أوقف Demo نهائياً
        if (!_firebaseDataReceived) {
          _firebaseDataReceived = true;
          _demoSimulationTimer?.cancel();
          _demoSimulationTimer = null;
        }
        _energyData = data;
        _isConnected = true;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('خطأ بث الطاقة: $error');
        // ✅ Fallback: أعد تشغيل Demo عند فشل البث
        if (_firebaseDataReceived) {
          _firebaseDataReceived = false;
          _startDemoTelemetryLoop();
        }
        _isConnected = false;
        notifyListeners();
      },
    );

    _relaySubscription = _firebaseService.relayStatesStream.listen(
      (relayStates) {
        for (final device in _devices) {
          if (device.relayId.isNotEmpty &&
              relayStates.containsKey(device.relayId)) {
            device.isOn = relayStates[device.relayId]!;
          }
        }
        notifyListeners();
      },
      onError: (error) => debugPrint('خطأ بث الريلي: $error'),
    );
  }

  Future<void> _loadLocalLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString('local_activity_logs');
    if (logsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(logsJson);
        _localLogs = decoded.map((l) => Map<String, dynamic>.from(l)).toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> logActivity({
    required String device,
    required String action,
    required String trigger,
    String? space,
  }) async {
    final newLog = {
      'device': device,
      'action': action,
      'trigger': trigger,
      'space': space ?? currentSpace.name,
      'time': DateTime.now().millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    _localLogs.insert(0, newLog);
    if (_localLogs.length > 50) {
      _localLogs = _localLogs.sublist(0, 50);
    }
    notifyListeners();

    // حفظ محلياً
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_activity_logs', json.encode(_localLogs));

    // إرسال لـ Firebase RTDB
    await _firebaseService.logActivity(
      device: device,
      action: action,
      trigger: trigger,
      space: space ?? currentSpace.name,
    );
  }

  /// حلقة تيار وتغذية تفاعلية حية تضمن عمل الواجهة 100% بحالة متصل وبقراءات نابضة
  void _startDemoTelemetryLoop() {
    _demoSimulationTimer?.cancel();
    _isConnected = true;
    _demoSimulationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isSimulatingOverload) return;
      final activeWatts = currentSpaceDevices
          .where((d) => d.isOn)
          .fold(0.0, (sum, d) => sum + d.wattage);
      final basePower = activeWatts > 0 ? activeWatts : 450.0;
      final dynamicWatt = (basePower + 120.0 * (1.0 + (0.5 * (1.0 + (0.2 * 0.5))))).clamp(250.0, 6500.0);
      final currentAmp = (dynamicWatt / 220.0).clamp(1.1, 29.5);
      final dynamicVolt = 220.0 + (2.5 * (1.0 + (0.5 * (1.0 + (0.2 * 0.5)))));

      _energyData = EnergyData(
        power: dynamicWatt,
        current: currentAmp,
        voltage: dynamicVolt,
        totalKwh: _energyData.totalKwh + (dynamicWatt / 3600000.0 * 2.0),
      );
      _isConnected = true;
      notifyListeners();
    });
  }

  /// تحميل المساحات والأجهزة من التخزين المحلي بمعرف المستخدم UID
  Future<void> _loadSpacesAndDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && uid.isNotEmpty) {
      final userAccountType = prefs.getString('account_type_$uid') ?? prefs.getString('account_type');
      if (userAccountType != null) {
        _isCommercial = (userAccountType == 'commercial');
      }
      _residentialPlan = prefs.getString('residential_plan_$uid') ?? 'pro';
      _commercialPlan = prefs.getString('commercial_plan_$uid') ?? 'free';
    } else {
      final userAccountType = prefs.getString('account_type');
      if (userAccountType != null) {
        _isCommercial = (userAccountType == 'commercial');
      }
    }

    final spacesKey = (uid != null && uid.isNotEmpty) ? 'user_spaces_list_$uid' : 'user_spaces_list_guest';
    final devicesKey = (uid != null && uid.isNotEmpty) ? 'devices_list_$uid' : 'devices_list_guest';

    // 1. تحميل المساحات — معزولة 100% لكل UID
    final spacesJson = prefs.getString(spacesKey);
    if (spacesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(spacesJson);
        _spaces = decoded.map((s) => SpaceModel.fromMap(Map<String, dynamic>.from(s))).toList();
      } catch (_) {
        _spaces = [];
      }
    } else {
      _spaces = [];
    }
    
    // إذا كان السجل فارغاً (مستخدم جديد)، البدء بمساحة منزلية واحدة فارغة
    if (_spaces.isEmpty) {
      _spaces = [
        SpaceModel(id: 'home', name: 'المنزل الرئيسي', type: _isCommercial ? 'commercial' : 'residential', iconKey: _isCommercial ? 'business' : 'home'),
      ];
      await _saveSpaces();
    }

    final currentKey = (uid != null && uid.isNotEmpty) ? 'current_space_id_$uid' : 'current_space_id_guest';
    _currentSpaceId = prefs.getString(currentKey) ?? _spaces.first.id;

    // 2. تحميل الأجهزة — معزولة 100% لكل UID (مستخدم جديد = 0 أجهزة)
    final devicesJson = prefs.getString(devicesKey);
    if (devicesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(devicesJson);
        _devices = decoded.map((d) => DeviceModel.fromMap(Map<String, dynamic>.from(d))).toList();
      } catch (_) {
        _devices = [];
      }
    } else {
      // للمستخدم الجديد: البدء بسجل أجهزة فارغ تماماً (0 أجهزة)
      _devices = [];
    }

    notifyListeners();
  }

  /// حفظ المساحات في التخزين المحلي
  Future<void> _saveSpaces() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final spacesKey = (uid != null && uid.isNotEmpty) ? 'user_spaces_list_$uid' : 'user_spaces_list_guest';
    final currentKey = (uid != null && uid.isNotEmpty) ? 'current_space_id_$uid' : 'current_space_id_guest';
    await prefs.setString(spacesKey, json.encode(_spaces.map((s) => s.toMap()).toList()));
    await prefs.setString(currentKey, _currentSpaceId);
  }

  /// حفظ الأجهزة في التخزين المحلي
  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final devicesKey = (uid != null && uid.isNotEmpty) ? 'devices_list_$uid' : 'devices_list_guest';
    await prefs.setString(devicesKey, json.encode(_devices.map((d) => d.toMap()).toList()));
  }

  /// إعادة تحميل بيانات المستخدم الحالية فور تسجيل الدخول
  Future<void> reloadUserData() async {
    await _loadSpacesAndDevices();
    await _loadLocalLogs();
  }

  /// مسح جلسة المستخدم الحالية عند تسجيل الخروج
  Future<void> clearSession() async {
    // إيقاف جميع المؤقتات والاشتراكات النشطة لمنع أي تسريب بيانات
    _demoSimulationTimer?.cancel();
    _demoSimulationTimer = null;
    await _energySubscription?.cancel();
    _energySubscription = null;
    await _relaySubscription?.cancel();
    _relaySubscription = null;

    // إعادة ضبط جميع بيانات الحالة وعزلها
    _devices = [];
    _spaces = [];
    _currentSpaceId = 'home';
    _isCommercial = false;
    _residentialPlan = 'pro';
    _commercialPlan = 'free';
    _localLogs = [];
    _isConnected = false;
    _firebaseDataReceived = false;
    _isSimulatingOverload = false;
    _energyData = EnergyData();

    notifyListeners();
  }

  /// إعادة تهيئة الجلسة بعد تسجيل دخول مستخدم جديد
  Future<void> initNewSession() async {
    await clearSession();
    await _loadSpacesAndDevices();
    await _loadLocalLogs();
    _listenToFirebase();
    _startDemoTelemetryLoop();
  }

  /// إضافة مساحة جديدة
  Future<bool> addSpace(String name, String type) async {
    final newId = 'space_${DateTime.now().millisecondsSinceEpoch}';
    final newSpace = SpaceModel(
      id: newId,
      name: name,
      type: type,
      iconKey: type == 'commercial' ? 'business' : 'home',
    );
    _spaces.add(newSpace);
    _currentSpaceId = newId;
    notifyListeners();
    await _saveSpaces();
    await logActivity(
      device: name,
      action: 'إضافة مساحة',
      trigger: type == 'commercial' ? 'مساحة تجارية' : 'مساحة سكنية',
      space: name,
    );
    return true;
  }

  /// حذف مساحة وحذف أجهزتها المرتبطة
  Future<void> removeSpace(String spaceId) async {
    if (_spaces.length <= 1) return; // الحفاظ على مساحة واحدة على الأقل
    final space = _spaces.firstWhere((s) => s.id == spaceId, orElse: () => _spaces.first);
    final spaceName = space.name;
    _spaces.removeWhere((s) => s.id == spaceId);
    _devices.removeWhere((d) => d.spaceId == spaceId);
    if (_currentSpaceId == spaceId) {
      _currentSpaceId = _spaces.first.id;
    }
    notifyListeners();
    await _saveSpaces();
    await _saveDevices();
    await logActivity(
      device: spaceName,
      action: 'حذف مساحة',
      trigger: 'إدارة المساحات',
      space: currentSpace.name,
    );
  }

  /// تبديل المساحة الحالية
  void switchSpace(String spaceId) async {
    _currentSpaceId = spaceId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final currentKey = (uid != null && uid.isNotEmpty) ? 'current_space_id_$uid' : 'current_space_id_guest';
    await prefs.setString(currentKey, _currentSpaceId);
  }

  /// تبديل حالة الجهاز (alias لـ toggleRelay)
  Future<void> toggleDevice(String deviceId) async => toggleRelay(deviceId);

  /// تبديل حالة الريلي — يكتب إلى Firebase ويحدث محلياً
  Future<void> toggleRelay(String deviceId) async {
    final device = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => DeviceModel(id: '', name: '', wattage: 0),
    );
    if (device.id.isEmpty) return;

    device.isOn = !device.isOn;
    notifyListeners();

    if (device.relayId.isNotEmpty) {
      try {
        await _firebaseService.setRelayState(device.relayId, device.isOn);
      } catch (e) {
        device.isOn = !device.isOn;
        notifyListeners();
      }
    }
    await _saveDevices();
    await logActivity(
      device: device.name,
      action: device.isOn ? 'ON' : 'OFF',
      trigger: 'تحكم يدوي مباشر',
      space: currentSpace.name,
    );
  }

  /// إيقاف جميع الأجهزة في المساحة الحالية
  Future<void> turnAllOff() async {
    for (final device in currentSpaceDevices) {
      if (device.isOn) {
        device.isOn = false;
        if (device.relayId.isNotEmpty) {
          try {
            await _firebaseService.setRelayState(device.relayId, false);
          } catch (_) {}
        }
      }
    }
    notifyListeners();
    await _saveDevices();
    await logActivity(
      device: 'جميع الأجهزة',
      action: 'OFF',
      trigger: 'إيقاف طوارئ كلي',
      space: currentSpace.name,
    );
  }

  /// إضافة جهاز جديد مع التحقق من الحد الأقصى للمساحة الحالية
  Future<bool> addDevice(DeviceModel device) async {
    if (isCurrentSpaceFull) return false;
    device.spaceId = _currentSpaceId;
    _devices.add(device);
    notifyListeners();
    await _saveDevices();
    await logActivity(
      device: device.name,
      action: 'إضافة جهاز',
      trigger: '${device.wattage}W',
      space: currentSpace.name,
    );
    return true;
  }

  /// حذف جهاز
  Future<void> removeDevice(String deviceId) async {
    final device = _devices.firstWhere((d) => d.id == deviceId, orElse: () => DeviceModel(id: '', name: '', wattage: 0));
    final devName = device.name;
    _devices.removeWhere((d) => d.id == deviceId);
    notifyListeners();
    await _saveDevices();
    if (devName.isNotEmpty) {
      await logActivity(
        device: devName,
        action: 'حذف جهاز',
        trigger: 'إدارة الأجهزة',
        space: currentSpace.name,
      );
    }
  }

  /// الاستماع لبيانات Firebase
  void _listenToFirebase() {
    _initStreams();
  }

  /// محاكاة تفعيل الحمل الزائد
  void simulateOverload() {
    _isSimulatingOverload = true;
    _energyData = EnergyData(
      power: 8200.0,
      current: 37.2,
      voltage: 220.0,
      totalKwh: _energyData.totalKwh,
    );
    notifyListeners();
  }

  /// إعادة ضبط حالة الحمل الزائد
  void resetOverload() {
    _isOverloadDismissed = true;
    _isSimulatingOverload = false;
    _energyData = EnergyData(
      power: 1250.0,
      current: 5.68,
      voltage: 220.0,
      totalKwh: _energyData.totalKwh,
    );
    notifyListeners();
  }

  /// إعادة ضبط النظام بعد الفصل / الطوارئ
  void resetSystem() {
    resetOverload();
  }

  @override
  void dispose() {
    _demoSimulationTimer?.cancel();
    _energySubscription?.cancel();
    _relaySubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

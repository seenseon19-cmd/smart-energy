/// ═══════════════════════════════════════════════════════════════
/// الترجمة والتعريب — AppLocalizations
/// الوظيفة: توفير دعم ثنائي اللغة (عربي/إنجليزي) مع RTL
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// كلاس الترجمة — يحتوي على جميع النصوص القابلة للترجمة
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _localizedValues = {
    'appName': {'en': 'SmartEnergy', 'ar': 'الطاقة الذكية'},
    'live': {'en': 'Live', 'ar': 'مباشر'},
    'demo': {'en': 'Demo', 'ar': 'تجريبي'},
    'dashboard': {'en': 'Dashboard', 'ar': 'الرئيسية'},
    'stats': {'en': 'Stats', 'ar': 'الإحصائيات'},
    'devices': {'en': 'Devices', 'ar': 'الأجهزة'},
    'settings': {'en': 'Settings', 'ar': 'الإعدادات'},
    'login': {'en': 'Login', 'ar': 'تسجيل الدخول'},
    'phoneNumber': {'en': 'Phone Number', 'ar': 'رقم الهاتف'},
    'enterPhone': {'en': 'Enter your phone number', 'ar': 'أدخل رقم هاتفك'},
    'sendOtp': {'en': 'Send Verification Code', 'ar': 'إرسال رمز التحقق'},
    'otpCode': {'en': 'Verification Code', 'ar': 'رمز التحقق'},
    'enterOtp': {'en': 'Enter the 6-digit code', 'ar': 'أدخل الرمز المكون من 6 أرقام'},
    'verify': {'en': 'Verify', 'ar': 'تحقق'},
    'otpSent': {'en': 'Code sent to', 'ar': 'تم إرسال الرمز إلى'},
    'resendOtp': {'en': 'Resend Code', 'ar': 'إعادة إرسال الرمز'},
    'welcomeLogin': {'en': 'Welcome to SmartEnergy', 'ar': 'مرحباً بك في الطاقة الذكية'},
    'loginSubtitle': {'en': 'Monitor and control your home energy', 'ar': 'راقب وتحكم في طاقة منزلك'},
    'signUpSubtitle': {'en': 'Create an account to take full control of your energy', 'ar': 'أنشئ حساباً للتحكم الكامل في طاقتك'},
    'or': {'en': 'OR', 'ar': 'أو'},
    'guestEnergyProfile': {'en': 'SmartEnergy Guest', 'ar': 'زائر الطاقة الذكية'},
    'continueAsGuest': {'en': 'Continue as guest', 'ar': 'متابعة كزائر'},
    'invalidPhone': {'en': 'Please enter a valid Libyan phone number', 'ar': 'يرجى إدخال رقم هاتف ليبي صالح'},
    'invalidOtp': {'en': 'Invalid verification code', 'ar': 'رمز التحقق غير صحيح'},
    'profile': {'en': 'Profile', 'ar': 'الملف الشخصي'},
    'guest': {'en': 'Guest', 'ar': 'زائر'},
    'user': {'en': 'User', 'ar': 'مستخدم'},
    'displayName': {'en': 'Display Name', 'ar': 'اسم العرض'},
    'save': {'en': 'Save', 'ar': 'حفظ'},
    'profileUpdated': {'en': 'Profile updated', 'ar': 'تم تحديث الملف الشخصي'},
    'accountSettings': {'en': 'Account Settings', 'ar': 'إعدادات الحساب'},
    'accountType': {'en': 'Account Type', 'ar': 'نوع الحساب'},
    'accountTypeLabel': {'en': 'Account Type', 'ar': 'نوع الحساب'},
    'personal': {'en': 'Personal', 'ar': 'شخصي'},
    'commercial': {'en': 'Commercial', 'ar': 'تجاري'},
    'currentLabel': {'en': 'CURRENT', 'ar': 'التيار'},
    'estimatedBill': {'en': 'ESTIMATED BILL', 'ar': 'الفاتورة المتوقعة'},
    'totalConsumption': {'en': 'Total Consumption', 'ar': 'إجمالي الاستهلاك'},
    'deviceControl': {'en': 'Device Control', 'ar': 'التحكم بالأجهزة'},
    'allOff': {'en': 'All Off', 'ar': 'إيقاف الكل'},
    'realtimePower': {'en': 'Real-time Power', 'ar': 'الطاقة اللحظية'},
    'mainsVoltage': {'en': 'Mains Voltage', 'ar': 'جهد الشبكة'},
    'turnAllOff': {'en': 'Turn All Off?', 'ar': 'إيقاف كل الأجهزة؟'},
    'turnAllOffDesc': {'en': 'This will turn off all connected devices.', 'ar': 'سيتم إيقاف جميع الأجهزة المتصلة.'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'turnAllOffBtn': {'en': 'Turn All Off', 'ar': 'إيقاف الكل'},
    'overloadProtectionActive': {'en': 'Overload Protection: Active', 'ar': 'حماية الأحمال الزائدة: نشطة'},
    'highLoadWarning': {'en': 'Warning: High Load!', 'ar': 'تحذير: حمل عالي!'},
    'secure': {'en': 'SECURE', 'ar': 'آمن'},
    'alert': {'en': 'ALERT', 'ar': 'تنبيه'},
    'deviceOn': {'en': 'ON', 'ar': 'مشغّل'},
    'deviceOff': {'en': 'OFF', 'ar': 'مطفأ'},
    'livingRoom': {'en': 'Living Room', 'ar': 'غرفة المعيشة'},
    'kitchen': {'en': 'Kitchen', 'ar': 'المطبخ'},
    'airConditioning': {'en': 'Air Conditioning', 'ar': 'تكييف الهواء'},
    'waterHeater': {'en': 'Water Heater', 'ar': 'السخان'},
    'active': {'en': 'Active', 'ar': 'نشط'},
    'inactive': {'en': 'Inactive', 'ar': 'غير نشط'},
    'total': {'en': 'Total', 'ar': 'الإجمالي'},
    'allDevices': {'en': 'All Devices', 'ar': 'جميع الأجهزة'},
    'deviceControlSub': {'en': 'Control your devices', 'ar': 'التحكم في أجهزتك'},
    'recentActivity': {'en': 'Recent Activity', 'ar': 'النشاط الأخير'},
    'activityLog': {'en': 'System activity log', 'ar': 'سجل نشاط النظام'},
    'addDevice': {'en': 'Add New Device', 'ar': 'إضافة جهاز جديد'},
    'addDeviceDesc': {'en': 'Connect a new ESP32 relay module\nto add more devices.', 'ar': 'قم بتوصيل وحدة ريلي ESP32 جديدة\nلإضافة المزيد من الأجهزة.'},
    'scanDevices': {'en': 'Scan for Devices', 'ar': 'البحث عن أجهزة'},
    'userManual': {'en': 'User (Manual)', 'ar': 'المستخدم (يدوي)'},
    'systemAuto': {'en': 'System (Auto)', 'ar': 'النظام (تلقائي)'},
    'timerSchedule': {'en': 'Timer (Schedule)', 'ar': 'المؤقت (جدولة)'},
    'deviceName': {'en': 'Device Name', 'ar': 'اسم الجهاز'},
    'wattage': {'en': 'Wattage', 'ar': 'القدرة (واط)'},
    'hardwarePin': {'en': 'Hardware Pin (Relay)', 'ar': 'مخرج الريلي'},
    'hardwarePinDesc': {'en': 'Select the ESP32 relay output.', 'ar': 'اختر مخرج الريلي في ESP32.'},
    'deviceIcon': {'en': 'Device Icon', 'ar': 'أيقونة الجهاز'},
    'noDevicesYet': {'en': 'No devices in this space yet', 'ar': 'لا توجد أجهزة في هذه المساحة بعد'},
    'spaces': {'en': 'Spaces', 'ar': 'المساحات'},
    'home': {'en': 'Home', 'ar': 'المنزل'},
    'shop': {'en': 'Shop', 'ar': 'المتجر'},
    'energyAnalytics': {'en': 'Energy Analytics', 'ar': 'إحصائيات الطاقة'},
    'day': {'en': 'Day', 'ar': 'يوم'},
    'week': {'en': 'Week', 'ar': 'أسبوع'},
    'month': {'en': 'Month', 'ar': 'شهر'},
    'year': {'en': 'Year', 'ar': 'سنة'},
    'powerConsumption': {'en': 'Power Consumption (W)', 'ar': 'استهلاك الطاقة (وات)'},
    'energyDistribution': {'en': 'Energy Distribution', 'ar': 'توزيع الطاقة'},
    'predictedBill': {'en': 'Predicted Bill', 'ar': 'الفاتورة المتوقعة'},
    'basedOnUsage': {'en': 'Based on current usage', 'ar': 'بناءً على الاستهلاك الحالي'},
    'peakUsage': {'en': 'Peak Usage', 'ar': 'وقت الذروة'},
    'noDataYet': {'en': 'No data yet', 'ar': 'لا توجد بيانات بعد'},
    'overloadLimit': {'en': 'OVERLOAD LIMIT', 'ar': 'حد الحمل الزائد'},
    'acLabel': {'en': 'Air Conditioning', 'ar': 'التكييف'},
    'heaterLabel': {'en': 'Water Heater', 'ar': 'السخان'},
    'lightingLabel': {'en': 'Lighting', 'ar': 'الإضاءة'},
    'kitchenLabel': {'en': 'Kitchen', 'ar': 'المطبخ'},
    'otherLabel': {'en': 'Other', 'ar': 'أخرى'},
    'alertsProtection': {'en': 'Alerts & Protection', 'ar': 'التنبيهات والحماية'},
    'globalPowerLimit': {'en': 'Global Power Limit', 'ar': 'حد الطاقة العالمي'},
    'maxPowerDesc': {'en': 'Max total power allowed.', 'ar': 'أقصى استهلاك طاقة مسموح به.'},
    'autoDisconnect': {'en': 'Auto-Disconnect', 'ar': 'الفصل التلقائي'},
    'autoDisconnectDesc': {'en': 'Turn off loads when limit exceeded.', 'ar': 'إيقاف الأحمال عند تجاوز الحد.'},
    'notificationPrefs': {'en': 'Notification Preferences', 'ar': 'إعدادات الإشعارات'},
    'pushNotifications': {'en': 'Push Notifications', 'ar': 'الإشعارات الفورية'},
    'pushNotifDesc': {'en': 'Receive push alerts', 'ar': 'تلقي تنبيهات فورية'},
    'emailAlerts': {'en': 'Email Alerts', 'ar': 'تنبيهات البريد'},
    'emailAlertsDesc': {'en': 'Get email for events', 'ar': 'تلقي إشعارات بالبريد'},
    'smsAlerts': {'en': 'SMS Alerts', 'ar': 'تنبيهات SMS'},
    'smsAlertsDesc': {'en': 'SMS for critical warnings', 'ar': 'رسائل نصية للتحذيرات'},
    'appearance': {'en': 'Appearance', 'ar': 'المظهر'},
    'darkMode': {'en': 'Dark Mode', 'ar': 'الوضع المظلم'},
    'darkModeDesc': {'en': 'Use dark theme', 'ar': 'استخدام المظهر الداكن'},
    'language': {'en': 'Language', 'ar': 'اللغة'},
    'languageDesc': {'en': 'Switch Arabic/English', 'ar': 'التبديل عربي/إنجليزي'},
    'about': {'en': 'About', 'ar': 'حول التطبيق'},
    'appVersion': {'en': 'App Version', 'ar': 'إصدار التطبيق'},
    'deviceId': {'en': 'Device ID', 'ar': 'معرف الجهاز'},
    'firebaseStatus': {'en': 'Firebase Status', 'ar': 'حالة Firebase'},
    'connected': {'en': 'Connected', 'ar': 'متصل'},
    'disconnected': {'en': 'Disconnected', 'ar': 'غير متصل'},
    'signOut': {'en': 'Sign Out', 'ar': 'تسجيل الخروج'},
    'signOutConfirm': {'en': 'Are you sure?', 'ar': 'هل أنت متأكد؟'},
    'onboard1Title': {'en': 'Complete Home Control & Protection', 'ar': 'تحكم كامل وحماية منزلية'},
    'onboard1Desc': {'en': 'Monitor and protect your appliances from voltage fluctuations and overload in real-time.', 'ar': 'راقب واحمِ أجهزة منزلك الكهربائية من تذبذب الجهد الكهربائي وحالات الأحمال الزائدة لحظة بلحظة.'},
    'onboard2Title': {'en': 'Smart Remote Control', 'ar': 'التحكم الذكي عن بُعد'},
    'onboard2Desc': {'en': 'Switch heavy appliances like heaters and ACs on or off from anywhere with a single tap.', 'ar': 'تشغيل وإيقاف الأحمال الثقيلة كالمرجل والتكييف من أي مكان في العالم بلمسة واحدة.'},
    'onboard3Title': {'en': 'Automatic Safety System', 'ar': 'نظام الأمان التلقائي'},
    'onboard3Desc': {'en': 'Protect your home through automatic smart overload disconnection before trip occurs.', 'ar': 'حماية منزلك عبر الفصل الذكي التلقائي للأجهزة ذات الاستهلاك العالي لمنع انقطاع التيار.'},
    'onboard4Title': {'en': 'Financial Savings & Efficiency', 'ar': 'توفير واستدامة مالية'},
    'onboard4Desc': {'en': 'Detailed analytics & monthly reports enabling up to 30% reduction in electricity bills.', 'ar': 'تحليلات دقيقة وتقارير شهريّة مفصلة تمكنك من خفض فاتورة الكهرباء بنسبة تصل إلى 30%.'},
    'secretKeyLabel': {'en': 'Secret Key (Manual Link)', 'ar': 'المفتاح السري (الربط اليدوي)'},
    'copyCode': {'en': 'Copy Key', 'ar': 'نسخ المفتاح'},
    'codeCopied': {'en': '2FA Secret Key copied to clipboard ✅', 'ar': 'تم نسخ مفتاح 2FA السري إلى الحافظة بنجاح ✅'},
    'switchToControl': {'en': 'Switch to Control', 'ar': 'انتقال للتحكم'},
    'next': {'en': 'Next', 'ar': 'التالي'},
    'getStarted': {'en': 'Get Started', 'ar': 'ابدأ الآن'},
    'skip': {'en': 'Skip', 'ar': 'تخطي'},
    'demoModeNote': {'en': 'Demo: Use code 123456', 'ar': 'تجريبي: رمز 123456'},
    'upgradePlan': {'en': 'Upgrade Plan', 'ar': 'ترقية الباقة'},
    'free': {'en': 'Free', 'ar': 'مجاني'},
    'basicPlan': {'en': 'Basic', 'ar': 'أساسي'},
    'proPlan': {'en': 'Pro', 'ar': 'برو'},
    'ultimatePlan': {'en': 'Ultimate', 'ar': 'ألتيميت'},
    'oneMonth': {'en': '1 Month', 'ar': 'شهر واحد'},
    'threeMonths': {'en': '3 Months', 'ar': '3 أشهر'},
    'ultimate': {'en': 'Ultimate', 'ar': 'ألتيميت'},
    'monitoring': {'en': 'Real-time Monitoring', 'ar': 'مراقبة لحظية'},
    'maxDevices': {'en': 'Max Devices', 'ar': 'أقصى عدد أجهزة'},
    'reports': {'en': 'Reports', 'ar': 'التقارير'},
    'scheduling': {'en': 'Scheduling', 'ar': 'الجدولة'},
    'prioritySupport': {'en': 'Priority Support', 'ar': 'دعم أولوية'},
    'unlimited': {'en': 'Unlimited', 'ar': 'غير محدود'},
    'mostPopular': {'en': 'Most Popular', 'ar': 'الأكثر شعبية'},
    'bestValue': {'en': 'Best Value', 'ar': 'أفضل قيمة'},
    'selectPlan': {'en': 'Select Plan', 'ar': 'اختر الباقة'},
    'currentPlanBadge': {'en': 'Current', 'ar': 'الحالية'},
    'activityHistory': {'en': 'Activity History', 'ar': 'سجل النشاط'},
    'energyReports': {'en': 'Energy Reports', 'ar': 'تقارير الطاقة'},
    'totalKwh': {'en': 'Total kWh', 'ar': 'إجمالي الاستهلاك'},
    'avgDaily': {'en': 'Avg Daily', 'ar': 'المتوسط اليومي'},
    'totalCost': {'en': 'Total Cost', 'ar': 'إجمالي التكلفة'},
    'selectMonth': {'en': 'Select Month', 'ar': 'اختر الشهر'},
    'pickMonthYear': {'en': 'Pick Month & Year', 'ar': 'اختر الشهر والسنة'},
    'monthlyReport': {'en': 'Monthly Summary', 'ar': 'ملخص شهري'},
    'exportPdf': {'en': 'Export PDF', 'ar': 'تصدير PDF'},
    'shareWhatsapp': {'en': 'Share via WhatsApp', 'ar': 'مشاركة واتساب'},
    'reportGenerated': {'en': 'Report generated', 'ar': 'تم إنشاء التقرير'},
    'completeProfile': {'en': 'Complete Profile', 'ar': 'أكمل ملفك الشخصي'},
    'welcomeProfile': {'en': 'Tell us about yourself', 'ar': 'أخبرنا عن نفسك'},
    'firstName': {'en': 'First Name', 'ar': 'الاسم الأول'},
    'lastName': {'en': 'Last Name', 'ar': 'اسم العائلة'},
    'age': {'en': 'Age', 'ar': 'العمر'},
    'agreeTerms': {'en': 'I agree to Terms', 'ar': 'أوافق على الشروط'},
    'fillAllFields': {'en': 'Fill all fields', 'ar': 'أكمل جميع الحقول'},
    'mustAgreeTerms': {'en': 'Must agree to terms', 'ar': 'يجب الموافقة على الشروط'},
    'continueBtn': {'en': 'Continue', 'ar': 'متابعة'},
    'selectAccountType': {'en': 'Select Account Type', 'ar': 'اختر نوع الحساب'},
    'personalDesc': {'en': 'Home energy monitoring', 'ar': 'مراقبة طاقة المنزل'},
    'commercialDesc': {'en': 'Business energy monitoring', 'ar': 'مراقبة طاقة الأعمال'},
    'deviceScheduling': {'en': 'Device Scheduling', 'ar': 'جدولة الأجهزة'},
    'noSchedules': {'en': 'No schedules yet', 'ar': 'لا توجد جداول بعد'},
    'scheduleActive': {'en': 'Active', 'ar': 'نشط'},
    'startTime': {'en': 'Start', 'ar': 'بداية'},
    'endTime': {'en': 'End', 'ar': 'نهاية'},
    'selectDays': {'en': 'Select Days', 'ar': 'اختر الأيام'},
    'delete': {'en': 'Delete', 'ar': 'حذف'},
    'addSchedule': {'en': 'Add Schedule', 'ar': 'إضافة جدول'},
    'sunday': {'en': 'Sun', 'ar': 'أحد'},
    'monday': {'en': 'Mon', 'ar': 'اثن'},
    'tuesday': {'en': 'Tue', 'ar': 'ثلا'},
    'wednesday': {'en': 'Wed', 'ar': 'أرب'},
    'thursday': {'en': 'Thu', 'ar': 'خمي'},
    'friday': {'en': 'Fri', 'ar': 'جمع'},
    'saturday': {'en': 'Sat', 'ar': 'سبت'},
    'circuitPriority': {'en': 'Circuit Priority', 'ar': 'أولوية الدوائر'},
    'circuitPriorityDesc': {'en': 'Drag to reorder disconnect priority', 'ar': 'اسحب لترتيب أولوية الفصل'},
    'highPriority': {'en': 'High Priority', 'ar': 'أولوية عالية'},
    'mediumPriority': {'en': 'Medium', 'ar': 'متوسطة'},
    'lowPriority': {'en': 'Low Priority', 'ar': 'أولوية منخفضة'},

    // ── مفاتيح تسجيل الدخول بالبريد الإلكتروني ──
    'loginWithPhone': {'en': 'Login with Phone', 'ar': 'الدخول بالهاتف'},
    'loginWithEmail': {'en': 'Login with Email', 'ar': 'الدخول بالبريد'},
    'email': {'en': 'Email Address', 'ar': 'البريد الإلكتروني'},
    'password': {'en': 'Password', 'ar': 'كلمة السر'},
    'emailHint': {'en': 'example@mail.com', 'ar': 'example@mail.com'},
    'passwordHint': {'en': 'Enter your password', 'ar': 'أدخل كلمة السر'},
    'signIn': {'en': 'Sign In', 'ar': 'تسجيل الدخول'},
    'signUp': {'en': 'Create Account', 'ar': 'إنشاء حساب'},
    'noAccount': {'en': "Don't have an account?", 'ar': 'ليس لديك حساب؟'},
    'haveAccount': {'en': 'Already have an account?', 'ar': 'لديك حساب بالفعل؟'},
    'invalidEmail': {'en': 'Please enter a valid email', 'ar': 'يرجى إدخال بريد إلكتروني صالح'},
    'weakPassword': {'en': 'Password must be at least 6 characters', 'ar': 'كلمة السر يجب أن تكون 6 أحرف على الأقل'},
    'emailNotFound': {'en': 'No account found with this email', 'ar': 'لا يوجد حساب بهذا البريد'},
    'wrongPassword': {'en': 'Incorrect password', 'ar': 'كلمة السر غير صحيحة'},
    'emailInUse': {'en': 'This email is already registered', 'ar': 'هذا البريد مسجل بالفعل'},
    'emailAuthFailed': {'en': 'Authentication failed, try again', 'ar': 'فشل التسجيل، حاول مرة أخرى'},
    'tooManyRequests': {'en': 'Too many attempts, try later', 'ar': 'محاولات كثيرة، حاول لاحقاً'},
    'userDisabled': {'en': 'This account has been disabled', 'ar': 'هذا الحساب معطّل'},
    'or': {'en': 'OR', 'ar': 'أو'},

    // ── مفاتيح تحقق البريد الإلكتروني ──
    'verifyEmailSent': {'en': 'Verification link sent to your email', 'ar': 'تم إرسال رابط التحقق لبريدك'},
    'resendVerification': {'en': 'Resend Verification Email', 'ar': 'إعادة إرسال رابط التحقق'},
    'emailNotVerified': {'en': 'Please verify your email first', 'ar': 'يرجى تأكيد بريدك الإلكتروني أولاً'},

    // ── مفاتيح لوحة القيادة (Dashboard) ──
    'welcomeBack': {'en': 'Welcome back', 'ar': 'مرحباً بعودتك'},
    'liveDashboard': {'en': 'Live Dashboard', 'ar': 'لوحة المراقبة'},
    'liveConnected': {'en': 'Live · Connected', 'ar': 'البث المباشر · متصل'},
    'liveDisconnected': {'en': 'Disconnected', 'ar': 'غير متصل'},
    'activeDevices': {'en': 'Active Devices', 'ar': 'الأجهزة النشطة'},
    'running': {'en': 'Running', 'ar': 'تعمل'},
    'consumptionCurve': {'en': 'Consumption Curve', 'ar': 'منحنى الاستهلاك'},
    'consumptionCurveLastHour': {'en': 'Consumption Curve (Last Hour)', 'ar': 'منحنى الاستهلاك (آخر ساعة)'},
    'liveConsumption': {'en': 'Live Consumption', 'ar': 'الاستهلاك اللحظي'},
    'liveLastHour': {'en': 'Live — Last Hour', 'ar': 'مباشر — آخر ساعة'},
    'gridVoltage': {'en': 'Grid Voltage', 'ar': 'جهد الشبكة'},
    'currentIntensity': {'en': 'Current', 'ar': 'شدة التيار'},
    'cumulativeConsumption': {'en': 'Cumulative Consumption', 'ar': 'الاستهلاك التجميعي'},
    'instantBill': {'en': 'Instant Bill', 'ar': 'الفاتورة اللحظية'},
    'optimized': {'en': 'Optimized', 'ar': 'Optimized'},
    'watts': {'en': 'Watts', 'ar': 'Watts'},
    'demoMode': {'en': 'Demo Mode', 'ar': 'وضع العرض'},
    'tapForDetails': {'en': 'Tap for details', 'ar': 'اضغط للتفاصيل'},
    'metricDetails': {'en': 'Metric Details', 'ar': 'تفاصيل القراءة'},
    'currentValue': {'en': 'Current Value', 'ar': 'القيمة الحالية'},
    'close': {'en': 'Close', 'ar': 'إغلاق'},

    // ── مفاتيح القشرة الرئيسية (MainShell) ──
    'theDashboard': {'en': 'Dashboard', 'ar': 'الرئيسية'},
    'analytics': {'en': 'Statistics', 'ar': 'الإحصائيات'},
    'statistics': {'en': 'Statistics', 'ar': 'الإحصائيات'},
    'spacesLabel': {'en': 'Spaces', 'ar': 'المساحات'},
    'subscriptions': {'en': 'Subscriptions', 'ar': 'الاشتراكات'},
    'security': {'en': 'Security', 'ar': 'الأمان'},
    'theProfile': {'en': 'Profile', 'ar': 'الملف الشخصي'},
    'signOutLabel': {'en': 'Sign Out', 'ar': 'تسجيل الخروج'},
    'plan': {'en': 'Plan', 'ar': 'الباقة'},
    'ultimateLabel': {'en': 'Ultimate', 'ar': 'آلتيميت'},
    'professionalLabel': {'en': 'Professional', 'ar': 'احترافي'},

    // ── مفاتيح الإعدادات (Settings) ──
    'accountSecurity': {'en': 'Account & Security', 'ar': 'الحساب والأمان'},
    'changePassword': {'en': 'Change Password', 'ar': 'تغيير كلمة المرور'},
    'changePasswordDesc': {'en': 'Update your password', 'ar': 'تحديث كلمة المرور'},
    'twoFactorAuth': {'en': 'Two-Factor Auth', 'ar': 'المصادقة الثنائية'},
    'twoFactorDesc': {'en': '2FA verification', 'ar': 'تحقق ثنائي العوامل'},
    'meterDevices': {'en': 'Meter & Devices', 'ar': 'العداد والأجهزة'},
    'calibration': {'en': 'Calibration', 'ar': 'معايرة الحساسات'},
    'calibrationDesc': {'en': 'Calibrate sensors', 'ar': 'معايرة حساسات الجهد والتيار'},
    'otaUpdate': {'en': 'OTA Update', 'ar': 'تحديث OTA'},
    'otaUpdateDesc': {'en': 'Firmware update via air', 'ar': 'تحديث النظام الثابت عبر الهواء'},
    'systemAlerts': {'en': 'System Alerts', 'ar': 'تنبيهات النظام'},
    'systemInfo': {'en': 'System Info', 'ar': 'معلومات النظام'},
    'meterId': {'en': 'Meter ID', 'ar': 'رقم العداد'},
    'serverStatus': {'en': 'Server Status', 'ar': 'حالة الخادم'},

    // ── مفاتيح المصادقة الثنائية (2FA) ──
    'enable2FA': {'en': 'Enable 2FA', 'ar': 'تفعيل المصادقة الثنائية'},
    'scan2FACode': {'en': 'Scan this QR code with your authenticator app', 'ar': 'امسح رمز QR بتطبيق المصادقة'},
    'enter2FACode': {'en': 'Enter 6-digit code', 'ar': 'أدخل الرمز المكون من 6 أرقام'},
    'link2FA': {'en': 'Link', 'ar': 'ربط'},
    'disable2FA': {'en': 'Disable 2FA', 'ar': 'تعطيل المصادقة الثنائية'},
    'disable2FAConfirm': {'en': 'Are you sure you want to disable 2FA?', 'ar': 'هل أنت متأكد من تعطيل المصادقة الثنائية؟'},
    'twoFAEnabled': {'en': '2FA enabled successfully', 'ar': 'تم تفعيل المصادقة الثنائية بنجاح'},
    'twoFADisabled': {'en': '2FA disabled', 'ar': 'تم تعطيل المصادقة الثنائية'},
    'confirm': {'en': 'Confirm', 'ar': 'تأكيد'},

    // ── مفاتيح التنبيهات والحماية (Alerts) ──
    'globalPowerLimitTitle': {'en': 'Global Power Limit', 'ar': 'حد القدرة العالمي'},
    'currentConsumption': {'en': 'Current Consumption', 'ar': 'الاستهلاك الحالي'},
    'autoDisconnectOnOverload': {'en': 'Auto-Disconnect on Overload', 'ar': 'الفصل التلقائي عند التجاوز'},
    'autoDisconnectExplain': {'en': 'Automatically disconnects highest-consumption device to prevent overload', 'ar': 'يتم إيقاف أعلى جهاز استهلاكاً تلقائياً لمنع الحمل الزائد'},
    'emergencySimulation': {'en': 'Emergency Simulation', 'ar': 'محاكاة الطوارئ'},
    'emergencyExplain': {'en': 'Test overload behavior and system response in a safe environment', 'ar': 'اختبار سلوك الحمل الزائد واستجابة النظام في بيئة آمنة'},
    'resetSystem': {'en': 'Reset after disconnect', 'ar': 'إعادة تشغيل بعد الفصل'},
    'triggerOverload': {'en': 'Trigger overload', 'ar': 'تشغيل تحميل زائد'},
    'systemResetSuccess': {'en': 'System reset successfully', 'ar': 'تم إعادة تشغيل النظام بنجاح'},
    'overloadTriggered': {'en': 'Overload simulation triggered', 'ar': 'تم تشغيل محاكاة الحمل الزائد'},
    'overloadWarning': {'en': '⚠️ WARNING: Overload detected! System auto-disconnecting high loads.', 'ar': '⚠️ تحذير: تم رصد حمل زائد! يتم فصل الأحمال العالية تلقائياً.'},
    'securityLogs': {'en': 'Recent Security Logs', 'ar': 'السجلات الأمنية الأخيرة'},
    'loginAttempt': {'en': 'Login attempt', 'ar': 'محاولة دخول'},
    'settingsChanged': {'en': 'Settings changed', 'ar': 'تغيير إعدادات'},
    'overloadAlert': {'en': 'Overload alert', 'ar': 'تنبيه حمل زائد'},
    'loadPercentage': {'en': 'Load', 'ar': 'الحمل'},

    // ── مفاتيح الملف الشخصي (Profile) ──
    'personalData': {'en': 'Certified Personal Data', 'ar': 'البيانات الشخصية الموثقة'},
    'fullName': {'en': 'Full Name', 'ar': 'الاسم الكامل'},
    'enterFullName': {'en': 'Enter your full name', 'ar': 'أدخل اسمك الكامل'},
    'certifiedPhone': {'en': 'Certified Phone 🇱🇾', 'ar': 'رقم الهاتف الموثق 🇱🇾'},
    'emailLabel': {'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'savePersonalData': {'en': 'Save Personal Data', 'ar': 'حفظ البيانات الشخصية'},
    'personalDataSaved': {'en': 'Personal data updated successfully ✅', 'ar': 'تم تحديث البيانات الشخصية الموثقة بنجاح ✅'},
    'commercialPlan': {'en': 'Commercial Plan (Ultimate)', 'ar': 'الخطة التجارية (آلتيميت)'},
    'proPlanLabel': {'en': 'Professional Plan (Pro)', 'ar': 'الخطة الاحترافية (Pro Plan)'},
    'renewalDate': {'en': 'Next renewal: June 28, 2026', 'ar': 'تاريخ التجديد القادم: 28 يونيو 2026'},
    'unifiedAccountId': {'en': 'Unified Account ID (Auto)', 'ar': 'رقم الحساب الموحد (تلقائي)'},
    'unifiedAccountDesc': {'en': 'Shared automatically across your personal and commercial spaces', 'ar': 'موحد بين مساحاتك الشخصية والتجارية ويتشارك تلقائياً'},
    'changeProfilePhoto': {'en': 'Change Photo', 'ar': 'تغيير الصورة'},
    'camera': {'en': 'Camera', 'ar': 'الكاميرا'},
    'gallery': {'en': 'Gallery', 'ar': 'المعرض'},

    // ── مفاتيح OTP المحسّن ──
    'resendIn': {'en': 'Resend in', 'ar': 'إعادة الإرسال بعد'},
    'seconds': {'en': 'seconds', 'ar': 'ثانية'},
    'otpVerified': {'en': 'Code verified successfully', 'ar': 'تم التحقق من الرمز بنجاح'},
    'otpExpired': {'en': 'Code expired, request a new one', 'ar': 'انتهت صلاحية الرمز، اطلب رمزاً جديداً'},

    // ── مفاتيح التحليلات (Analytics) ──
    'smartEnergyAnalytics': {'en': 'Smart Energy Analytics', 'ar': 'إحصائيات الطاقة الذكية'},
    'consumptionInsights': {'en': 'Consumption Insights', 'ar': 'رؤى الاستهلاك'},
    'daily': {'en': 'Daily', 'ar': 'يومي'},
    'weekly': {'en': 'Weekly', 'ar': 'أسبوعي'},
    'monthly': {'en': 'Monthly', 'ar': 'شهري'},
    'custom': {'en': 'Custom', 'ar': 'مخصص'},
    'peakHoursWarning': {'en': 'Peak Hours: 6 PM - 9 PM', 'ar': 'ساعات الذروة المرتفعة: 6 PM - 9 PM'},
    'exportReport': {'en': 'Export Comprehensive Report', 'ar': 'تصدير تقرير شامل'},
    'downloadPdf': {'en': 'Download PDF', 'ar': 'تحميل PDF'},

    // ── أيام الأسبوع الكاملة ──
    'satFull': {'en': 'Saturday', 'ar': 'السبت'},
    'sunFull': {'en': 'Sunday', 'ar': 'الأحد'},
    'monFull': {'en': 'Monday', 'ar': 'الاثنين'},
    'tueFull': {'en': 'Tuesday', 'ar': 'الثلاثاء'},
    'wedFull': {'en': 'Wednesday', 'ar': 'الأربعاء'},
    'thuFull': {'en': 'Thursday', 'ar': 'الخميس'},
    'friFull': {'en': 'Friday', 'ar': 'الجمعة'},

    // ── وحدات القياس (Units) ──
    'volts': {'en': 'V', 'ar': 'V'},
    'amps': {'en': 'A', 'ar': 'A'},
    'kwh': {'en': 'kWh', 'ar': 'kWh'},
    'lyd': {'en': 'LYD', 'ar': 'LYD'},

    // ── مفاتيح المساحات (Spaces) ──
    'yourSmartSpaces': {'en': 'Your Smart Spaces', 'ar': 'مساحاتك الذكية'},
    'manageSpacesDesc': {'en': 'Manage energy locations and max ports', 'ar': 'إدارة مواقع الطاقة والحد الأقصى للمنافذ'},
    'addSpace': {'en': 'Add Space', 'ar': 'إضافة مساحة'},
    'addNewSpace': {'en': 'Add New Space', 'ar': 'إضافة مساحة جديدة'},
    'spaceName': {'en': 'Space Name (e.g. Main Home, Shop, Workshop)', 'ar': 'اسم المساحة (مثل: المنزل الرئيسي، المتجر، الورشة)'},
    'spaceTypeAndLimit': {'en': 'Space type and allowed port limit:', 'ar': 'نوع المساحة وحد المنافذ المسموحة:'},
    'residential': {'en': 'Residential', 'ar': 'منزلية'},
    'limit8Devices': {'en': 'Limit: 8 devices', 'ar': 'حد 8 أجهزة'},
    'limit12Devices': {'en': 'Limit: 12 devices', 'ar': 'حد 12 جهاز'},
    'createSpace': {'en': 'Create Space', 'ar': 'إنشاء المساحة'},
    'connectedDevices': {'en': 'Connected Devices', 'ar': 'الأجهزة المتصلة'},
    'currentConsumptionLabel': {'en': 'Current Consumption', 'ar': 'الاستهلاك الحالي'},
    'activeNow': {'en': 'Active Now', 'ar': 'المساحة النشطة حالياً'},
    'dormant': {'en': 'Dormant', 'ar': 'خامدة'},
    'deleteSpace': {'en': 'Delete Space?', 'ar': 'حذف المساحة؟'},
    'deleteSpaceConfirm': {'en': 'Are you sure you want to delete space "{name}" with all associated devices?', 'ar': 'هل أنت متأكد من حذف مساحة "{name}" مع جميع أجهزتها المرتبطة بها؟'},

    // ── مفاتيح الأجهزة (Devices) ──
    'maxDevicesReached': {'en': 'Maximum devices reached for this space ({limit} devices)', 'ar': 'تم الوصول للحد الأقصى لهذه المساحة ({limit} أجهزة)'},
    'quickSuggestions': {'en': 'Quick device suggestions:', 'ar': 'اقتراحات سريعة للأجهزة:'},
    'selectRelayPin': {'en': 'Select control output (ESP32 Relay Pin):', 'ar': 'اختر مخرج التحكم (ESP32 Relay Pin):'},
    'reserved': {'en': 'Reserved', 'ar': 'محجوز'},
    'available': {'en': 'Available', 'ar': 'متاح'},
    'saveAndAddDevice': {'en': 'Save & Add Device', 'ar': 'حفظ وإضافة الجهاز'},
    'enterDeviceName': {'en': 'Please enter the device name', 'ar': 'يرجى إدخال اسم الجهاز'},
    'selectAvailableRelay': {'en': 'Please select an available Relay output', 'ar': 'يرجى تحديد مخرج Relay متاح'},
    'deviceAdded': {'en': 'Device "{name}" added successfully ✅', 'ar': 'تمت إضافة جهاز "{name}" بنجاح ✅'},
    'deleteDevice': {'en': 'Delete Device', 'ar': 'حذف الجهاز'},
    'deleteDeviceConfirm': {'en': 'Are you sure you want to delete device "{name}"?', 'ar': 'هل أنت متأكد من حذف جهاز "{name}"؟'},
    'addDeviceEmptyHint': {'en': 'Press the "Add Device" button above to connect a new device to the ESP32 outputs.', 'ar': 'اضغط على زر "إضافة جهاز" في الأعلى لربط جهاز جديد بمخارج الـ ESP32.'},

    // ── مفاتيح الإحصائيات (Statistics) ──
    'smartInsights': {'en': 'Smart Energy Insights', 'ar': 'رؤى ذكية لاستهلاكك'},
    'realtimeDataCurves': {'en': 'Real-time data & efficiency curves', 'ar': 'بيانات لحظية ومنحنيات فاعلية'},

    // ── مفاتيح عامة إضافية ──
    'commercialLabel': {'en': '🏢 Commercial (12 device limit)', 'ar': '🏢 تجاري (حد 12 جهاز)'},
    'residentialLabel': {'en': '🏠 Residential (8 device limit)', 'ar': '🏠 منزلي (حد 8 أجهزة)'},
    'devicesCount': {'en': '{count} device', 'ar': '{count} جهاز'},

    // ── مفاتيح الواجهة العامة والإعدادات ──
    'arabicLanguage': {'en': 'Arabic', 'ar': 'العربية'},
    'englishLanguage': {'en': 'English', 'ar': 'الإنجليزية'},
    'chooseAppLanguage': {'en': 'Choose app language', 'ar': 'اختيار لغة التطبيق'},
    'arabicLanguageOption': {'en': 'Arabic 🇱🇾', 'ar': 'العربية (Arabic) 🇱🇾'},
    'englishLanguageOption': {'en': 'English 🇺🇸', 'ar': 'English (الإنجليزية) 🇺🇸'},
    'appearanceCustomization': {'en': 'Appearance & customization', 'ar': 'المظهر والتخصيص'},
    'languageNotifications': {'en': 'Language & notifications', 'ar': 'اللغة والتنبيهات'},
    'securityProtection': {'en': 'Security & protection', 'ar': 'الأمان والحماية'},
    'reportsTechnicalSupport': {'en': 'Reports & technical support', 'ar': 'التقارير والدعم الفني'},
    'darkModeEnabled': {'en': 'Dark mode enabled', 'ar': 'الوضع المظلم مفعل'},
    'lightModeEnabled': {'en': 'Light mode enabled', 'ar': 'الوضع المضيء مفعل'},
    'loadProtectionAlerts': {'en': 'Load protection alerts', 'ar': 'تنبيهات وحماية الأحمال الكهربائية'},
    'advancedSecurity2fa': {'en': 'Advanced security & two-factor authentication (2FA)', 'ar': 'الأمان المتقدم والمصادقة الثنائية (2FA)'},
    'monthlyEnergyReports': {'en': 'Monthly energy consumption reports', 'ar': 'تقارير استهلاك الطاقة الشهرية'},
    'supportDescription': {'en': 'Our support team is ready to help with devices and monitoring around the clock.', 'ar': 'فريق الدعم الفني جاهز لمساعدتك على مدار الساعة بشأن الأجهزة والمراقبة.'},
    'supportEmailTitle': {'en': 'Support email', 'ar': 'البريد الإلكتروني للدعم'},
    'supportPhoneTitle': {'en': 'Direct hotline', 'ar': 'الخط الساخن المباشر'},
    'openAppFailed': {'en': 'Unable to open the requested app on this device', 'ar': 'تعذر فتح التطبيق المطلوب على هذا الجهاز'},
    'supportOpenAbout': {'en': 'About SmartEnergy', 'ar': 'عن تطبيق SmartEnergy'},
    'supportAboutDescription': {'en': 'SmartEnergy is an intelligent solution for monitoring and managing energy consumption and protecting residential and commercial electrical networks in Libya using IoT technology.', 'ar': 'منظومة SmartEnergy هي الحل الذكي الرائد لمراقبة وإدارة استهلاك الطاقة وحماية الشبكات الكهربائية المنزلية والتجارية في ليبيا بتقنيات إنترنت الأشياء (IoT).'},
    'close': {'en': 'Close', 'ar': 'إغلاق'},
    'supportAppVersion': {'en': 'v1.0.0', 'ar': 'v1.0.0'},

    // ── مفاتيح المصادقة البيومترية والبدء ──
    'biometricUnavailable': {'en': 'Biometric authentication is unavailable. Add a fingerprint or Face ID in device settings first.', 'ar': 'المصادقة البيومترية غير متاحة. أضف بصمة أو Face ID من إعدادات الجهاز أولاً.'},
    'biometricEnableReason': {'en': 'Confirm your fingerprint, Face ID, or device passcode to enable biometric sign-in', 'ar': 'يرجى تأكيد البصمة أو رمز القفل لتفعيل الدخول البيومتري'},
    'biometricCancelled': {'en': 'Biometric verification was cancelled or not completed', 'ar': 'لم يتم التحقق من البصمة أو تم إلغاء العملية'},
    'biometricEnabledSuccess': {'en': 'Biometric authentication enabled successfully', 'ar': 'تم تفعيل المصادقة البيومترية بنجاح'},
    'biometricDisabledSuccess': {'en': 'Biometric authentication disabled', 'ar': 'تم إلغاء تفعيل المصادقة البيومترية'},
    'biometricError': {'en': 'Biometric authentication failed. Check device settings and try again.', 'ar': 'تعذر تشغيل المصادقة البيومترية. تحقق من إعدادات الجهاز ثم حاول مرة أخرى.'},
    'biometricNotEnrolled': {'en': 'No fingerprint or face is enrolled on this device. Add one in device settings first.', 'ar': 'لا توجد بصمة أو وجه مسجل على هذا الجهاز. أضف وسيلة بيومترية من إعدادات الجهاز أولاً.'},
    'biometricFailed': {'en': 'The biometric check did not match. Try again or use your password.', 'ar': 'لم تتطابق المصادقة البيومترية. حاول مرة أخرى أو استخدم كلمة المرور.'},
    'biometricLockedOut': {'en': 'Biometrics are temporarily locked. Unlock the device and try again later.', 'ar': 'تم قفل المصادقة البيومترية مؤقتًا. افتح قفل الجهاز وحاول لاحقًا.'},
    'biometricPermanentLockout': {'en': 'Biometrics are permanently locked. Unlock the device with its passcode first.', 'ar': 'تم قفل المصادقة البيومترية نهائيًا. افتح الجهاز باستخدام رمز القفل أولاً.'},
    'biometricLogin': {'en': 'Sign in with biometrics', 'ar': 'الدخول بالبصمة أو الوجه'},
    'biometricLoginReason': {'en': 'Confirm your identity to sign in securely', 'ar': 'أكد هويتك للدخول بأمان'},
    'biometricLoginUnavailable': {'en': 'Biometric sign-in is unavailable. Use your password instead.', 'ar': 'الدخول البيومتري غير متاح. استخدم كلمة المرور بدلاً منه.'},
    'biometricLoginCanceled': {'en': 'Biometric sign-in was canceled. You can use your password instead.', 'ar': 'تم إلغاء الدخول البيومتري. يمكنك استخدام كلمة المرور بدلاً منه.'},
    'usePassword': {'en': 'Use password instead', 'ar': 'استخدام كلمة المرور بدلاً منه'},
    'startupPreparingExperience': {'en': 'Preparing your SmartEnergy experience', 'ar': 'جارٍ تجهيز تجربة SmartEnergy'},
    'startupLoadingProfile': {'en': 'Loading your profile', 'ar': 'جارٍ تحميل ملفك الشخصي'},
    'startupPreparingAccount': {'en': 'Preparing your account', 'ar': 'جارٍ تجهيز حسابك'},
    'startupErrorTitle': {'en': 'Unable to prepare the app', 'ar': 'تعذر تجهيز التطبيق'},
    'startupErrorDescription': {'en': 'Check your connection and try again. No data was lost.', 'ar': 'تحقق من الاتصال ثم أعد المحاولة. لم يتم فقدان أي بيانات.'},
    'retry': {'en': 'Retry', 'ar': 'إعادة المحاولة'},
    'basicPlan': {'en': 'Basic', 'ar': 'البرونزية'},
    'professionalPlan': {'en': 'Professional', 'ar': 'الاحترافية'},
    'goldPlan': {'en': 'Gold', 'ar': 'الذهبية'},
    'basicDashboard': {'en': 'Basic dashboard', 'ar': 'لوحة تحكم أساسية'},
    'consumption30Days': {'en': '30-day consumption history', 'ar': 'سجل استهلاك 30 يوم'},
    'smartAlerts': {'en': 'Smart alerts', 'ar': 'تنبيهات ذكية'},
    'unlimited': {'en': 'Unlimited', 'ar': 'غير محدودة'},
    'support247': {'en': '24/7 technical support', 'ar': 'دعم فني 24/7'},
    'privacyAndTerms': {'en': 'Privacy & terms', 'ar': 'الخصوصية والشروط'},
    'aboutSmartEnergy': {'en': 'About SmartEnergy', 'ar': 'أهمية SmartEnergy'},
    'aboutSmartEnergyText': {'en': 'SmartEnergy helps you monitor energy consumption, protect devices from overloads, and make practical decisions to save electricity at home or at your facility.', 'ar': 'يساعدك SmartEnergy على مراقبة استهلاك الطاقة، حماية الأجهزة من الأحمال الزائدة، واتخاذ قرارات عملية لترشيد الكهرباء في المنزل أو المنشأة.'},
    'privacyPolicy': {'en': 'Privacy policy', 'ar': 'سياسة الخصوصية'},
    'privacyPolicyText': {'en': 'We use account and energy data to provide monitoring, control, and alerts. Data is used within your account and device operations, and we do not sell your personal data. You can request an update or deletion through support.', 'ar': 'نستخدم بيانات الحساب وبيانات الطاقة لتقديم المراقبة والتحكم والتنبيهات. تُستخدم البيانات ضمن حسابك وعمليات التشغيل المرتبطة بأجهزتك، ولا نبيع بياناتك الشخصية. يمكنك طلب تحديث بياناتك أو حذفها عبر الدعم.'},
    'termsOfService': {'en': 'Terms of service', 'ar': 'شروط الخدمة'},
    'termsOfServiceText': {'en': 'The app supports energy management and monitoring, but it is not a replacement for electrical safety systems or a qualified technician. Users are responsible for connecting devices safely and protecting their credentials.', 'ar': 'يُستخدم التطبيق لإدارة الطاقة والمراقبة المساعدة، ولا يُعد بديلاً عن أنظمة السلامة الكهربائية أو فني مؤهل. يتحمل المستخدم مسؤولية ربط الأجهزة وفق الإرشادات والمحافظة على بيانات الدخول.'},
    'supportAndHelp': {'en': 'Support & help', 'ar': 'الدعم والمساعدة'},
    'supportAndHelpText': {'en': 'For questions or privacy requests, contact our support team through WhatsApp or the approved phone number.', 'ar': 'للاستفسارات أو طلبات الخصوصية، تواصل مباشرة مع فريق الدعم عبر واتساب أو الاتصال بالرقم المعتمد.'},
    'contactSupport': {'en': 'Contact support', 'ar': 'تواصل مع الدعم'},
    'lastUpdatedAugust2026': {'en': 'Last updated: August 2026', 'ar': 'آخر تحديث: أغسطس 2026'},
    'registrationConsentRequired': {'en': 'You must accept the privacy policy and terms of use', 'ar': 'يجب الموافقة على سياسة الخصوصية وشروط الاستخدام'},
    'enterEmail': {'en': 'Please enter your email address', 'ar': 'يرجى إدخال البريد الإلكتروني'},
    'enterPassword': {'en': 'Please enter your password', 'ar': 'يرجى إدخال كلمة المرور'},
    'passwordMinLength': {'en': 'Password must be at least 6 characters', 'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'},
    'passwordsMismatch': {'en': 'Passwords do not match', 'ar': 'كلمتا المرور غير متطابقتين'},
    'fillAllFields': {'en': 'Please fill in all fields to continue', 'ar': 'يرجى ملء جميع الحقول للمتابعة'},
    'validAge': {'en': 'Please enter a valid age', 'ar': 'يرجى إدخال عمر صحيح'},
    'enterSpaceName': {'en': 'Please enter a space name', 'ar': 'يرجى إدخال اسم المساحة'},
    'spaceAdded': {'en': 'Space "{name}" added successfully', 'ar': 'تمت إضافة مساحة "{name}" بنجاح'},
    'spaceAddError': {'en': 'Could not add the space. Please try again.', 'ar': 'حدث خطأ أثناء إضافة المساحة. حاول مرة أخرى.'},
    'deviceSaveError': {'en': 'Could not save the device. Please try again.', 'ar': 'حدث خطأ أثناء حفظ الجهاز. حاول مرة أخرى.'},
    'deviceAdded': {'en': 'Device "{name}" added successfully', 'ar': 'تمت إضافة جهاز "{name}" بنجاح'},
    'secretCopied': {'en': 'Secret key copied to clipboard', 'ar': 'تم نسخ المفتاح السري إلى الحافظة'},
    'twoFactorDisabled': {'en': 'Two-factor authentication disabled', 'ar': 'تم تعطيل المصادقة الثنائية'},
    'twoFactorEnabled': {'en': 'Two-factor authentication enabled successfully', 'ar': 'تم تفعيل المصادقة الثنائية بنجاح'},
    'step': {'en': 'Step', 'ar': 'الخطوة'},
    'of': {'en': 'of', 'ar': 'من'},
    'signupCredentialsHint': {'en': 'Enter your basic credentials to start managing your energy', 'ar': 'أدخل بيانات الدخول الأساسية للبدء في إدارة طاقتك'},
    'confirmPassword': {'en': 'Confirm password', 'ar': 'تأكيد كلمة المرور'},
    'iAgreeTo': {'en': 'I agree to', 'ar': 'أوافق على'},
    'privacyTerms': {'en': 'Privacy policy and terms of use', 'ar': 'سياسة الخصوصية وشروط الاستخدام'},
    'nextStep': {'en': 'Continue (next step)', 'ar': 'متابعة (الخطوة التالية)'},
    'alreadyHaveAccount': {'en': 'Already have an account?', 'ar': 'لديك حساب بالفعل؟'},
    'aboutApp': {'en': 'About the app', 'ar': 'عن التطبيق'},
    'authFailed': {'en': 'Authentication failed. Please try again.', 'ar': 'فشلت المصادقة. حاول مرة أخرى.'},
    'liveStream': {'en': 'Live stream', 'ar': 'البث المباشر'},
    'logout': {'en': 'Log out', 'ar': 'تسجيل الخروج'},
    'notifications': {'en': 'Notifications', 'ar': 'الإشعارات'},
    'offline': {'en': 'Offline', 'ar': 'غير متصل'},
    'saveChanges': {'en': 'Save changes', 'ar': 'حفظ التغييرات'},
    'supportCenter': {'en': 'Help & support center', 'ar': 'مركز الدعم والمساعدة'},
  };

  /// ترجمة مفتاح نصي — يعيد الترجمة أو المفتاح نفسه
  String tr(String key) {
    return _localizedValues[key]?[locale.languageCode] ??
        _localizedValues[key]?['en'] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

/// مزود اللغة — يدير حالة اللغة ويحفظها محلياً
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() { _loadSavedLocale(); }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('app_language');
      if (saved == 'ar' || saved == 'en') {
        _locale = Locale(saved!);
        notifyListeners();
      }
    } catch (_) {
      // اللغة الافتراضية العربية تبقى صالحة عند تعذر قراءة التخزين.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['ar', 'en'].contains(locale.languageCode)) return;
    _locale = Locale(locale.languageCode);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', _locale.languageCode);
    } catch (_) {
      // لا نمنع إعادة الرسم الفورية إذا تعذر التخزين المؤقت.
    }
  }

  Future<void> toggleLocale() async {
    await setLocale(_locale.languageCode == 'en'
        ? const Locale('ar') : const Locale('en'));
  }
}

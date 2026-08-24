/// ══════════════════════════════════════════════════════════════════════════════
/// خدمة المصادقة — AuthService
/// ══════════════════════════════════════════════════════════════════════════════
///
/// الوظيفة: إدارة مصادقة المستخدم عبر طريقتين:
///   1. رقم الهاتف الليبي (+218) باستخدام OTP عبر Firebase Phone Auth
///   2. البريد الإلكتروني وكلمة السر مع إرسال رابط تحقق حقيقي
///
/// الميزات:
///   - إرسال OTP حقيقي عبر Firebase Phone Auth
///   - تسجيل الدخول / إنشاء حساب بالبريد الإلكتروني
///   - إرسال رابط تحقق البريد تلقائياً عند إنشاء الحساب
///   - وضع تجريبي بالرمز 123456 كاحتياطي
///   - جلسة مستمرة عبر authStateChanges()
///   - تحديث اسم العرض وحفظه محلياً وفي Firebase
///
/// القيمة المرجعة: ChangeNotifier يدير حالة المصادقة بالكامل
/// ══════════════════════════════════════════════════════════════════════════════

import 'app_logger.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';

/// كلاس خدمة المصادقة — يدير دورة حياة المصادقة بالكامل
class AuthService extends ChangeNotifier {

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 1: المتغيرات الأساسية — Core State
  // ══════════════════════════════════════════════════════════════════════════

  /// مرجع Firebase Auth — نقطة الوصول الوحيدة لخدمات المصادقة
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// كائن المستخدم الحالي من Firebase (null إذا لم يسجل الدخول)
  User? _user;

  /// معرّف التحقق من OTP — يُستخدم لربط الرمز المُرسل بالجلسة
  String? _verificationId;

  /// علم التحميل — يُستخدم لتعطيل الأزرار وعرض مؤشر الانتظار
  bool _isLoading = false;

  /// رسالة الخطأ — مفتاح نصي يُترجم في الواجهة حسب اللغة
  String? _errorMessage;

  /// هل تم إرسال رمز OTP بنجاح
  bool _otpSent = false;

  /// هل تم حسم حالة المصادقة (لإخفاء شاشة التحميل الأولية)
  bool _authResolved = false;

  // ── حالة التسجيل التجريبي (Fallback) ──
  /// هل المستخدم مسجل بالوضع التجريبي (عند فشل Firebase)
  bool _isSimulatedLogin = false;

  /// رقم الهاتف المحفوظ للوضع التجريبي
  String _simulatedPhone = '';

  /// اسم العرض المحفوظ محلياً
  String _displayName = '';

  /// رقم الحساب الفريد والمميز لكل مستخدم
  String _accountNumber = '';

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 2: الخصائص العامة (Getters) — Public Properties
  // ══════════════════════════════════════════════════════════════════════════

  /// الحصول على كائن المستخدم الحالي
  User? get user => _user;

  /// هل المستخدم مسجّل الدخول — حقيقي عبر Firebase أو تجريبي
  bool get isLoggedIn => _user != null || _isSimulatedLogin;

  /// هل المستخدم زائر — لم يسجل الدخول بأي طريقة
  bool get isGuest => _user == null && !_isSimulatedLogin;

  /// هل المستخدم مجهول الهوية
  bool get isAnonymous => _user?.isAnonymous ?? true;

  /// هل جاري تنفيذ عملية (تحميل/إرسال/تحقق)
  bool get isLoading => _isLoading;

  /// رسالة الخطأ الحالية — null إذا لا يوجد خطأ
  String? get errorMessage => _errorMessage;

  /// هل تم إرسال رمز OTP
  bool get otpSent => _otpSent;

  /// هل تم حسم حالة المصادقة الأولية
  bool get authResolved => _authResolved;

  /// رقم الهاتف المعروض — من Firebase أو من الوضع التجريبي
  String get displayPhone => _user?.phoneNumber ?? _simulatedPhone;

  /// البريد الإلكتروني المعروض — من Firebase
  String get displayEmail => _user?.email ?? '';

  /// اسم العرض — الأولوية للاسم المحفوظ محلياً ثم Firebase
  String get displayName => _displayName.isNotEmpty
      ? _displayName
      : (_user?.displayName ?? '');

  /// رقم الحساب الفريد المخصص للمستخدم
  String get accountNumber {
    if (_accountNumber.isNotEmpty) return _accountNumber;
    if (_user != null && _user!.uid.isNotEmpty) {
      final cleanUid = _user!.uid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      final suffix = cleanUid.length >= 6 ? cleanUid.substring(0, 6) : cleanUid.padRight(6, '9');
      return 'SE-LY-$suffix';
    }
    return 'SE-LY-789234';
  }

  /// هل البريد الإلكتروني مُتحقق منه
  bool get isEmailVerified => _user?.emailVerified ?? false;

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 3: التهيئة — Initialization
  // ══════════════════════════════════════════════════════════════════════════

  /// المُنشئ — يبدأ تهيئة المصادقة تلقائياً عند إنشاء الكائن
  AuthService() {
    _init();
  }

  /// تهيئة خدمة المصادقة:
  ///   1. تحميل الجلسة التجريبية المحفوظة من SharedPreferences
  ///   2. الاستماع لتغييرات حالة المصادقة في Firebase
  ///   3. ضمان حسم الحالة خلال ثانيتين كحد أقصى
  Future<void> _init() async {
    // ── تحميل حالة التسجيل التجريبي والمستخدم المحفوظة ──
    final prefs = await SecureStorageService.instance;
    _isSimulatedLogin = kDebugMode && (await prefs.getBool('simulated_login') ?? false);
    _simulatedPhone = (await prefs.getString('simulated_phone')) ?? '';

    final currentUid = _auth.currentUser?.uid;
    if (currentUid != null && currentUid.isNotEmpty) {
      final cleanUid = currentUid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      final suffix = cleanUid.length >= 6 ? cleanUid.substring(0, 6) : cleanUid.padRight(6, '0');
      _accountNumber = 'SE-LY-$suffix';
      await prefs.setString('unique_account_id_$currentUid', _accountNumber);
      _displayName = (await prefs.getString('display_name_$currentUid')) ?? (_auth.currentUser?.displayName ?? '');
    } else {
      _displayName = (await prefs.getString('display_name')) ?? '';
      _accountNumber = (await prefs.getString('unique_account_id_guest')) ?? 'SE-LY-789234';
    }

    // ── الاستماع لتغييرات حالة المصادقة في Firebase ──
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      final p = await SecureStorageService.instance;
      if (user != null && user.uid.isNotEmpty) {
        final cleanUid = user.uid.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
        final suffix = cleanUid.length >= 6 ? cleanUid.substring(0, 6) : cleanUid.padRight(6, '0');
        _accountNumber = 'SE-LY-$suffix';
        await p.setString('unique_account_id_${user.uid}', _accountNumber);
        _displayName = (await p.getString('display_name_${user.uid}')) ?? (user.displayName ?? '');
      } else if (_isSimulatedLogin) {
        _accountNumber = (await p.getString('unique_account_id_simulated')) ?? 'SE-LY-789234';
        _displayName = (await p.getString('display_name')) ?? '';
      }
      _authResolved = true;
      notifyListeners();
    });

    // ── مؤقت أمان: حسم الحالة بعد ثانيتين إذا لم يستجب Firebase ──
    Future.delayed(const Duration(seconds: 2), () {
      if (!_authResolved) {
        _authResolved = true;
        notifyListeners();
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 4: مصادقة الهاتف — Phone OTP Authentication
  // ══════════════════════════════════════════════════════════════════════════

  /// التحقق من صحة رقم الهاتف الليبي وتحويله للصيغة الدولية
  /// يقبل الصيغ: 09XXXXXXXX, 9XXXXXXXX, 218XXXXXXXXX, +218XXXXXXXXX
  ///
  /// المعاملات:
  ///   - [phone]: رقم الهاتف كما أدخله المستخدم
  ///
  /// القيمة المرجعة: الرقم بصيغة +218XXXXXXXXX أو null إذا غير صالح
  static String? validateLibyanPhone(String phone) {
    // إزالة المسافات والأقواس والشرطات
    phone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    // تحويل الصيغ المختلفة إلى الصيغة الدولية الموحدة
    if (phone.startsWith('09')) {
      phone = '+218${phone.substring(1)}'; // 09X → +2189X
    } else if (phone.startsWith('9') && phone.length == 9) {
      phone = '+218$phone'; // 9XXXXXXXX → +2189XXXXXXXX
    } else if (phone.startsWith('218')) {
      phone = '+$phone'; // 218X → +218X
    }

    // التحقق من المطابقة بالتعبير النمطي: +218 ثم 9 ثم 8 أرقام
    final regex = RegExp(r'^\+218(9[0-9]{8})$');
    if (!regex.hasMatch(phone)) return null;

    return phone;
  }

  /// إرسال رمز OTP إلى رقم الهاتف
  /// المنطق: يحاول Firebase الحقيقي أولاً → عند الفشل ينتقل للوضع التجريبي
  ///
  /// المعاملات:
  ///   - [phoneNumber]: رقم الهاتف كما أدخله المستخدم
  Future<void> sendOTP(String phoneNumber) async {
    _setLoading(true);

    // ── التحقق من صحة الرقم ──
    final formattedPhone = validateLibyanPhone(phoneNumber);
    if (formattedPhone == null) {
      _setError('invalid_phone');
      return;
    }

    // ── محاولة إرسال OTP الحقيقي عبر Firebase ──
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        /// التحقق التلقائي (Android فقط) — يتم عند قراءة SMS تلقائياً
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            AppLogger.debug('خطأ في تسجيل الدخول التلقائي: $e');
          }
          _isLoading = false;
          notifyListeners();
        },

        /// فشل التحقق — الانتقال للوضع التجريبي عند أخطاء معينة
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.debug('فشل مصادقة الهاتف: ${e.code} — ${e.message}');
          // أخطاء قابلة للاسترداد → وضع تجريبي
          if (e.code == 'app-not-authorized' ||
              e.code == 'invalid-app-credential' ||
              e.code == 'network-request-failed') {
            _simulateOTPSend(formattedPhone);
          } else {
            // أخطاء أخرى → عرض رسالة خطأ
            _setError('verification_failed');
          }
        },

        /// تم إرسال الرمز بنجاح — حفظ معرّف التحقق
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _otpSent = true;
          _isLoading = false;
          _simulatedPhone = formattedPhone;
          notifyListeners();
        },

        /// انتهاء مهلة الاسترداد التلقائي
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      // ── أي خطأ غير متوقع → وضع تجريبي ──
      AppLogger.debug('خطأ في مصادقة الهاتف: $e');
      _simulateOTPSend(formattedPhone);
    }
  }

  /// إرسال OTP تجريبي — يُستخدم فقط كاحتياطي عند فشل Firebase
  /// الرمز التجريبي الثابت: 123456
  ///
  /// المعاملات:
  ///   - [phone]: رقم الهاتف بالصيغة الدولية
  void _simulateOTPSend(String phone) {
    if (kReleaseMode) {
      _setError('verification_failed');
      _isLoading = false;
      return;
    }
    _simulatedPhone = phone;
    _otpSent = true;
    _isLoading = false;
    _errorMessage = null;
    AppLogger.debug('📱 وضع تجريبي: OTP "123456" أُرسل إلى $phone');
    notifyListeners();
  }

  /// التحقق من رمز OTP المُدخل
  /// المنطق: يحاول Firebase أولاً → عند غياب verificationId يقبل 123456
  ///
  /// المعاملات:
  ///   - [otp]: رمز التحقق المكون من 6 أرقام
  ///
  /// القيمة المرجعة: true إذا نجح التحقق
  Future<bool> verifyOTP(String otp) async {
    _setLoading(true);

    // ── محاولة التحقق الحقيقي عبر Firebase ──
    if (_verificationId != null) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await _auth.signInWithCredential(credential);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        AppLogger.debug('خطأ في التحقق من OTP: $e');
        // فشل التحقق الحقيقي → عرض خطأ
        _setError('invalid_otp');
        return false;
      }
    }

    // ── الاحتياطي التجريبي: قبول "123456" فقط عند غياب verificationId ──
    if (!kReleaseMode && otp == '123456') {
      _isSimulatedLogin = true;
      final prefs = await SecureStorageService.instance;
      await prefs.setBool('simulated_login', true);
      await prefs.setString('simulated_phone', _simulatedPhone);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // ── رمز خاطئ ──
    _setError('invalid_otp');
    return false;
  }

  /// إعادة تعيين تدفق OTP — العودة لحقل إدخال رقم الهاتف
  void resetOTPFlow() {
    _otpSent = false;
    _errorMessage = null;
    _verificationId = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 5: مصادقة البريد الإلكتروني — Email/Password Authentication
  // ══════════════════════════════════════════════════════════════════════════

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة السر
  ///
  /// المعاملات:
  ///   - [email]: البريد الإلكتروني
  ///   - [password]: كلمة السر (6 أحرف كحد أدنى)
  ///
  /// القيمة المرجعة: true إذا نجح تسجيل الدخول
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);

    // ── التحقق من صحة المدخلات ──
    if (!_isValidEmail(email)) { _setError('invalid_email'); return false; }
    if (password.length < 6)   { _setError('weak_password');  return false; }

    // ── محاولة تسجيل الدخول عبر Firebase ──
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.debug('خطأ تسجيل الدخول بالبريد: ${e.code}');
      _setError(_mapEmailError(e.code));
      return false;
    } catch (e) {
      AppLogger.debug('خطأ غير متوقع في تسجيل الدخول: $e');
      _setError('email_auth_failed');
      return false;
    }
  }

  /// إنشاء حساب جديد بالبريد الإلكتروني وكلمة السر
  /// بعد النجاح: يُرسل رابط تحقق حقيقي إلى البريد تلقائياً
  ///
  /// المعاملات:
  ///   - [email]: البريد الإلكتروني
  ///   - [password]: كلمة السر (6 أحرف كحد أدنى)
  ///
  /// القيمة المرجعة: true إذا نجح إنشاء الحساب
  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);

    // ── التحقق من صحة المدخلات ──
    if (!_isValidEmail(email)) { _setError('invalid_email'); return false; }
    if (password.length < 6)   { _setError('weak_password');  return false; }

    // ── محاولة إنشاء الحساب عبر Firebase ──
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // ── إرسال رابط التحقق من البريد تلقائياً ──
      await _sendVerificationEmail(credential.user);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.debug('خطأ إنشاء الحساب: ${e.code}');
      _setError(_mapSignUpError(e.code));
      return false;
    } catch (e) {
      AppLogger.debug('خطأ غير متوقع في إنشاء الحساب: $e');
      _setError('email_auth_failed');
      return false;
    }
  }

  /// إرسال رابط التحقق من البريد الإلكتروني
  /// يُستدعى تلقائياً بعد إنشاء الحساب، ويمكن استدعاؤه يدوياً لإعادة الإرسال
  ///
  /// المعاملات:
  ///   - [user]: كائن المستخدم (اختياري — يستخدم الحالي إذا null)
  Future<void> _sendVerificationEmail([User? user]) async {
    final targetUser = user ?? _user;
    if (targetUser == null) return;

    // لا ترسل إذا البريد مُتحقق منه بالفعل
    if (targetUser.emailVerified) return;

    try {
      await targetUser.sendEmailVerification();
      AppLogger.debug('✉️ تم إرسال رابط التحقق إلى: ${targetUser.email}');
    } catch (e) {
      AppLogger.debug('⚠️ فشل إرسال رابط التحقق: $e');
      // لا نوقف التدفق — الحساب أُنشئ بنجاح حتى لو فشل إرسال الرابط
    }
  }

  /// إعادة إرسال رابط التحقق من البريد — يُستدعى من الواجهة
  Future<void> resendVerificationEmail() async {
    // تحديث بيانات المستخدم للتأكد من حالة التحقق
    await _user?.reload();
    _user = _auth.currentUser;

    await _sendVerificationEmail();
    notifyListeners();
  }

  /// التحقق من حالة تأكيد البريد — يُستدعى عند فتح التطبيق أو يدوياً
  Future<bool> checkEmailVerification() async {
    if (_user == null) return false;

    await _user!.reload();
    _user = _auth.currentUser;
    notifyListeners();

    return _user?.emailVerified ?? false;
  }

  /// إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني
  Future<bool> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (!_isValidEmail(cleanEmail)) {
      _setError('invalid_email');
      return false;
    }
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      AppLogger.debug('خطأ إعادة تعيين كلمة المرور: ${e.code}');
      _setError(_mapEmailError(e.code));
      return false;
    } catch (e) {
      AppLogger.debug('خطأ غير متوقع: $e');
      _setError('email_auth_failed');
      return false;
    }
  }

  /// تغيير كلمة المرور للمستخدم المسجل — يتطلب إعادة المصادقة بكلمة المرور الحالية
  ///
  /// المعاملات:
  ///   - [currentPassword]: كلمة المرور الحالية
  ///   - [newPassword]: كلمة المرور الجديدة
  ///
  /// القيمة المرجعة: Map مع 'success' (bool) و 'message' (String)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'لم يتم العثور على مستخدم مسجل'};
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      return {'success': false, 'message': 'حسابك غير مرتبط ببريد إلكتروني صالح'};
    }

    _setLoading(true);
    try {
      // 1. إعادة المصادقة بكلمة المرور الحالية للتأكد من هوية المستخدم
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. تحديث كلمة المرور الجديدة في Firebase Auth
      await user.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': 'تم تحديث كلمة المرور بنجاح ✅'};
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLogger.debug('خطأ في تغيير كلمة المرور: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return {'success': false, 'message': 'كلمة المرور الحالية غير صحيحة'};
      } else if (e.code == 'weak-password') {
        return {'success': false, 'message': 'كلمة المرور الجديدة ضعيفة جداً (6 خانات على الأقل)'};
      } else if (e.code == 'requires-recent-login') {
        return {'success': false, 'message': 'جلسة الأمان انتهت. يرجى تسجيل الدخول مجدداً'};
      } else {
        return {'success': false, 'message': 'فشل تحديث كلمة المرور (${e.message ?? e.code})'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      AppLogger.debug('خطأ غير متوقع في تغيير كلمة المرور: $e');
      return {'success': false, 'message': 'حدث خطأ أثناء تغيير كلمة المرور'};
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 6: إدارة الحساب — Account Management
  // ══════════════════════════════════════════════════════════════════════════

  /// تحديث اسم العرض وحفظه محلياً وفي Firebase
  ///
  /// المعاملات:
  ///   - [name]: الاسم الجديد
  Future<void> updateDisplayName(String name) async {
    _displayName = name;
    // حفظ الاسم محلياً في SharedPreferences بمعرف المستخدم
    final prefs = await SecureStorageService.instance;
    final uid = _user?.uid;
    if (uid != null && uid.isNotEmpty) {
      await prefs.setString('display_name_$uid', name);
    }
    await prefs.setString('display_name', name);
    // محاولة تحديث الاسم في Firebase (صامت عند الفشل)
    try {
      await _user?.updateDisplayName(name);
    } catch (_) {}
    notifyListeners();
  }

  /// تسجيل الخروج — يمسح جميع حالات المصادقة ويعيد تعيين التطبيق
  Future<void> signOut() async {
    // ── تسجيل الخروج من Firebase ──
    try {
      await _auth.signOut();
    } catch (_) {}

    // ── إعادة تعيين جميع المتغيرات المحلية ──
    _user = null;
    _isSimulatedLogin = false;
    _simulatedPhone = '';
    _displayName = '';
    _otpSent = false;
    _verificationId = null;

    // ── مسح البيانات المحفوظة محلياً ──
    final prefs = await SecureStorageService.instance;
    await prefs.remove('simulated_login');
    await prefs.remove('simulated_phone');
    await prefs.remove('display_name');
    final localPrefs = await SharedPreferences.getInstance();
    await localPrefs.setBool('onboarding_done', false);

    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  القسم 7: دوال مساعدة خاصة — Private Helpers
  // ══════════════════════════════════════════════════════════════════════════

  /// تعيين حالة التحميل مع مسح الأخطاء السابقة
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  /// تعيين رسالة الخطأ وإيقاف التحميل — نمط موحد لتجنب التكرار
  void _setError(String errorKey) {
    _errorMessage = errorKey;
    _isLoading = false;
    notifyListeners();
  }

  /// مسح رسالة الخطأ الحالية — يُستدعى عند التبديل بين الأوضاع
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// التحقق من صحة صيغة البريد الإلكتروني بالتعبير النمطي
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(email.trim());
  }

  /// ترجمة رموز أخطاء Firebase لتسجيل الدخول إلى مفاتيح محلية
  String _mapEmailError(String code) {
    switch (code) {
      case 'user-not-found':      return 'email_not_found';
      case 'wrong-password':
      case 'invalid-credential':  return 'wrong_password';
      case 'too-many-requests':   return 'too_many_requests';
      case 'user-disabled':       return 'user_disabled';
      default:                    return 'email_auth_failed';
    }
  }

  /// ترجمة رموز أخطاء Firebase لإنشاء الحساب إلى مفاتيح محلية
  String _mapSignUpError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'email_in_use';
      case 'weak-password':        return 'weak_password';
      default:                     return 'email_auth_failed';
    }
  }
}

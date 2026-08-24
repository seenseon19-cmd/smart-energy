// ═══════════════════════════════════════════════════════════
//  SmartEnergy ESP32 — الكود النهائي (إنتاج + حماية)
// ═══════════════════════════════════════════════════════════

// ── المكتبات ──
#include <WiFi.h>
#include <WiFiClientSecure.h>          // 🔒 مكتبة SSL/TLS — تشفّر كل البيانات المرسلة
#include <Firebase_ESP_Client.h>       // 🔒 مكتبة Firebase مع دعم التشفير المدمج
#include "EmonLib.h"                   // مكتبة قراءة حساسات الطاقة
#include "secrets.h"                   // 🔒 ملف الأسرار المنفصل (لا يُرفع على GitHub)

// مساعدات Firebase
#include <addons/TokenHelper.h>        // 🔒 إدارة التوكن (رمز المصادقة المؤقت)
#include <addons/RTDBHelper.h>

// ── المنافذ (GPIO) ──
#define VOLTAGE_PIN  34   // حساس الجهد ZMPT101B
#define CURRENT_PIN  35   // حساس التيار SCT-013
#define RELAY_PIN    27   // ريلاي التحكم

// ── ثوابت المعايرة ──
#define V_CAL  234.26     // معامل معايرة الجهد (اضبطه بالملتيميتر)
#define I_CAL  29.00      // معامل معايرة التيار (SCT-013-030)

// ── ثوابت الحماية ──
#define SEND_INTERVAL    2000   // إرسال البيانات كل 2 ثانية
#define RELAY_INTERVAL   500    // فحص الريلاي كل 0.5 ثانية
#define HEARTBEAT_TIME   30000  // نبض حياة كل 30 ثانية
#define MAX_FAILS        5      // 🔒 أقصى أخطاء قبل تفعيل صمام الأمان
#define MAX_WIFI_RETRY   20     // أقصى محاولات اتصال WiFi

// ── الكائنات ──
FirebaseData   fbData;
FirebaseAuth   fbAuth;
FirebaseConfig fbConfig;
EnergyMonitor  emonV, emonI;

// ── المتغيرات ──
double voltage = 0, current_a = 0, power = 0, kwh = 0;
unsigned long tSend = 0, tRelay = 0, tBeat = 0, tEnergy = 0;
int  failCount    = 0;      // 🔒 عدّاد الأخطاء المتتالية
bool safeMode     = false;  // 🔒 وضع الأمان (صمام الأمان)
bool relayState   = false;
String deviceUID  = "";

// ═══════════════════════════════════════════════════════════
//  الدوال المساعدة
// ═══════════════════════════════════════════════════════════

// ── اتصال WiFi ──
bool connectWiFi() {
  Serial.printf("📶 جاري الاتصال بـ %s", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  for (int i = 0; i < MAX_WIFI_RETRY && WiFi.status() != WL_CONNECTED; i++) {
    delay(500); Serial.print(".");
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("✅ متصل! IP: %s | RSSI: %d dBm\n",
                  WiFi.localIP().toString().c_str(), WiFi.RSSI());
    return true;
  }
  Serial.println("❌ فشل الاتصال بالشبكة");
  return false;
}

// ── تهيئة Firebase مع مصادقة آمنة ──
void initFirebase() {
  // 🔒 تعيين مفتاح API — يُستخدم للتحقق من هوية المشروع
  fbConfig.api_key = FIREBASE_API_KEY;
  // 🔒 رابط القاعدة — الاتصال يتم عبر HTTPS (مشفّر تلقائياً)
  fbConfig.database_url = FIREBASE_DB_URL;

  // 🔒 اختيار نوع المصادقة
  if (strlen(DEVICE_EMAIL) > 0) {
    // 🔒 مصادقة بالبريد — أقوى حماية (كل طلب يحمل توكن مرتبط بالحساب)
    fbAuth.user.email    = DEVICE_EMAIL;
    fbAuth.user.password = DEVICE_PASSWORD;
    Serial.println("🔑 المصادقة: بريد الجهاز");
  } else {
    // 🔒 مصادقة مجهولة — Firebase يُنشئ UID فريد للجهاز تلقائياً
    //    هذا يمنع أي طلب بدون توكن من الوصول للبيانات
    Serial.println("🔑 المصادقة: مجهول (Anonymous)");
  }

  // 🔒 callback لمراقبة حالة التوكن (صلاحية، تجديد، خطأ)
  fbConfig.token_status_callback = tokenStatusCallback;

  // 🔒 بدء الاتصال المشفّر — SSL/TLS يُفعَّل تلقائياً من المكتبة
  Firebase.begin(&fbConfig, &fbAuth);
  Firebase.reconnectWiFi(true);

  // انتظار جاهزية التوكن
  unsigned long t = millis();
  while (!Firebase.ready() && millis() - t < 10000) delay(100);

  if (Firebase.ready()) {
    failCount = 0;
    deviceUID = String(fbAuth.token.uid.c_str());
    if (deviceUID.isEmpty()) deviceUID = "esp32";
    Serial.printf("✅ Firebase جاهز | UID: %s\n", deviceUID.c_str());
  } else {
    // 🔒 إذا فشلت المصادقة → تفعيل صمام الأمان فوراً
    enterSafeMode("FIREBASE_INIT_FAIL");
  }
}

// ── 🔒 صمام الأمان — يمنع تنفيذ أي أوامر مجهولة ──
void enterSafeMode(const char* reason) {
  if (safeMode) return;            // لا تكرّر التفعيل
  safeMode = true;
  // 🔒 فصل الريلاي فوراً — حماية الأحمال الكهربائية
  digitalWrite(RELAY_PIN, LOW);
  relayState = false;
  Serial.println("🛑 ══════════════════════════════════");
  Serial.printf("   ⚠️ صمام الأمان مُفعَّل: %s\n", reason);
  Serial.println("   → الريلاي: مفصول | الأوامر: معطّلة");
  Serial.println("🛑 ══════════════════════════════════");
}

// ── إلغاء وضع الأمان ──
void exitSafeMode() {
  if (!safeMode) return;
  safeMode = false;
  failCount = 0;
  Serial.println("✅ صمام الأمان مُلغى — الاتصال مستقر");
}

// ── 🔒 التحقق من صحة القراءات قبل الإرسال ──
bool isDataValid(double v, double c, double p) {
  // 🔒 رفض القيم غير الرقمية (NaN/Infinity) — قد تكون هجمة حقن
  if (isnan(v) || isnan(c) || isnan(p)) return false;
  if (isinf(v) || isinf(c) || isinf(p)) return false;
  // 🔒 رفض القيم خارج النطاق الفيزيائي المنطقي
  if (v < 0 || v > 400)   return false;   // جهد: 0-400V
  if (c < 0 || c > 100)   return false;   // تيار: 0-100A
  if (p < 0 || p > 40000) return false;   // قدرة: 0-40kW
  return true;
}

// ── قراءة الحساسات ──
void readSensors() {
  voltage  = emonV.calcVrms(1480);         // قراءة RMS للجهد
  current_a = emonI.calcIrms(1480);        // قراءة RMS للتيار
  if (voltage < 5.0)   voltage  = 0;      // تصفير الضوضاء
  if (current_a < 0.05) current_a = 0;
  power = voltage * current_a;             // القدرة الظاهرية

  // حساب kWh تراكمي
  unsigned long now = millis();
  if (tEnergy > 0 && power > 0) {
    kwh += (power / 1000.0) * ((now - tEnergy) / 3600000.0);
  }
  tEnergy = now;
}

// ── إرسال البيانات إلى Firebase ──
void sendData() {
  // 🔒 فحص جاهزية Firebase (يعني التوكن صالح والاتصال مشفّر)
  if (!Firebase.ready()) {
    failCount++;
    if (failCount >= MAX_FAILS) enterSafeMode("FIREBASE_DISCONNECTED");
    return;
  }
  // 🔒 فحص صحة البيانات — لا نرسل بيانات تالفة أبداً
  if (!isDataValid(voltage, current_a, power)) {
    Serial.println("⚠️ بيانات غير صالحة — تم التجاهل");
    return;
  }

  FirebaseJson json;
  json.set("voltage",      round(voltage * 10) / 10.0);
  json.set("current",      round(current_a * 100) / 100.0);
  json.set("power",        round(power * 10) / 10.0);
  json.set("total_kwh",    round(kwh * 100) / 100.0);
  json.set("power_factor", (power > 10) ? 0.85 : 0.0);
  json.set("frequency",    50);
  json.set("timestamp/.sv", "timestamp");  // طابع زمني من سيرفر Firebase

  // 🔒 الإرسال عبر HTTPS — البيانات مشفّرة بـ TLS أثناء الانتقال
  if (Firebase.RTDB.setJSON(&fbData, "energy_node", &json)) {
    failCount = 0;
    if (safeMode) exitSafeMode();
    Serial.printf("📤 V=%.1f | I=%.2f | P=%.1f | kWh=%.2f\n",
                  voltage, current_a, power, kwh);
  } else {
    failCount++;
    Serial.printf("❌ خطأ: %s (%d/%d)\n",
                  fbData.errorReason().c_str(), failCount, MAX_FAILS);
    // 🔒 إذا تجاوزت الأخطاء الحد → صمام الأمان
    if (failCount >= MAX_FAILS) enterSafeMode("SEND_FAILS_EXCEEDED");
  }
}

// ── الاستماع لأوامر الريلاي ──
void checkRelay() {
  // 🔒 في وضع الأمان: تجاهل جميع الأوامر من السحابة
  if (safeMode || !Firebase.ready()) return;

  if (Firebase.RTDB.getBool(&fbData, "relays/relay1/state")) {
    bool cmd = fbData.boolData();
    if (cmd != relayState) {
      relayState = cmd;
      digitalWrite(RELAY_PIN, relayState ? HIGH : LOW);
      Serial.printf("🔌 ريلاي: %s\n", relayState ? "تشغيل ⚡" : "إيقاف 🔴");
    }
  }
}

// ── نبض الحياة ──
void heartbeat() {
  if (!Firebase.ready()) return;
  FirebaseJson s;
  s.set("online", true);
  s.set("safe_mode", safeMode);
  s.set("wifi_rssi", WiFi.RSSI());
  s.set("uptime_sec", (int)(millis() / 1000));
  s.set("uid", deviceUID);
  s.set("last_heartbeat/.sv", "timestamp");
  Firebase.RTDB.setJSON(&fbData, "device_status", &s);
}

// ═══════════════════════════════════════════════════════════
//  setup() — التهيئة
// ═══════════════════════════════════════════════════════════
void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("\n╔══════════════════════════════════════╗");
  Serial.println("║  SmartEnergy ESP32 v2.0 (Production) ║");
  Serial.println("╚══════════════════════════════════════╝");

  // إعداد الريلاي — يبدأ مفصولاً (آمن)
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW);

  // تهيئة حساسات الطاقة
  emonV.voltage(VOLTAGE_PIN, V_CAL, 1.7);
  emonI.current(CURRENT_PIN, I_CAL);

  // اتصال WiFi
  if (!connectWiFi()) {
    enterSafeMode("WIFI_FAILED");
  } else {
    initFirebase();
  }

  tEnergy = millis();
  Serial.println("✅ النظام جاهز\n");
}

// ═══════════════════════════════════════════════════════════
//  loop() — الحلقة الرئيسية
// ═══════════════════════════════════════════════════════════
void loop() {
  unsigned long now = millis();

  // 🔒 فحص WiFi — إذا انقطع، فعّل صمام الأمان
  if (WiFi.status() != WL_CONNECTED) {
    if (!connectWiFi()) { enterSafeMode("WIFI_LOST"); delay(5000); return; }
    initFirebase();
  }

  // قراءة الحساسات (دائماً، حتى في وضع الأمان)
  readSensors();

  // إرسال البيانات
  if (now - tSend >= SEND_INTERVAL) { tSend = now; sendData(); }

  // فحص الريلاي
  if (now - tRelay >= RELAY_INTERVAL) { tRelay = now; checkRelay(); }

  // نبض الحياة
  if (now - tBeat >= HEARTBEAT_TIME) { tBeat = now; heartbeat(); }

  delay(10);
}

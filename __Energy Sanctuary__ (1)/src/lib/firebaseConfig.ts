/**
 * ========================================================================
 *  ملف إعدادات Firebase
 *  ------------------------------------------------------------------------
 *  هذا الملف يحتوي على متغيرات الاتصال بمشروع Firebase الخاص بك.
 *  ضع هنا مفاتيح مشروعك من لوحة تحكم Firebase Console.
 *
 *  ⚠️  ملاحظة أمنية:
 *  - مفاتيح Firebase العامة (apiKey, authDomain) آمنة في الواجهة الأمامية.
 *  - لكن الحماية الحقيقية يجب أن تتم عبر قواعد الأمان (Security Rules)
 *    في Firestore و Realtime Database و Storage.
 *  - لا تضع مفاتيح خاصة (Service Account) هنا أبداً.
 *
 *  لتفعيل Firebase فعلياً:
 *    1) شغّل: bun add firebase
 *    2) املأ القيم أدناه من ملف إعدادات مشروعك في Firebase Console.
 *    3) أزل التعليق عن الكتل المعلّمة بـ "TODO: Firebase".
 * ========================================================================
 */

// واجهة (Interface) تصف شكل إعدادات Firebase المطلوبة
export interface FirebaseConfig {
  apiKey: string;          // مفتاح واجهة البرمجة العام
  authDomain: string;      // نطاق المصادقة (مثال: my-app.firebaseapp.com)
  projectId: string;       // معرّف المشروع في Firebase
  storageBucket: string;   // حاوية تخزين الملفات
  messagingSenderId: string; // معرّف خدمة الرسائل
  appId: string;           // معرّف تطبيق Firebase
  databaseURL?: string;    // رابط قاعدة البيانات اللحظية (اختياري)
  measurementId?: string;  // معرّف Google Analytics (اختياري)
}

// كائن الإعدادات — ضع قيم مشروعك هنا
export const firebaseConfig: FirebaseConfig = {
  apiKey: "REPLACE_WITH_YOUR_FIREBASE_API_KEY",
  authDomain: "REPLACE_WITH_YOUR_PROJECT.firebaseapp.com",
  projectId: "REPLACE_WITH_YOUR_PROJECT_ID",
  storageBucket: "REPLACE_WITH_YOUR_PROJECT.appspot.com",
  messagingSenderId: "REPLACE_WITH_YOUR_SENDER_ID",
  appId: "REPLACE_WITH_YOUR_APP_ID",
  databaseURL: "https://REPLACE_WITH_YOUR_PROJECT-default-rtdb.firebaseio.com",
  measurementId: "G-REPLACE_WITH_YOUR_MEASUREMENT_ID",
};

/**
 * تهيئة تطبيق Firebase.
 * عند التركيب الفعلي للمكتبة، استبدل الكتلة أدناه بالكود الحقيقي:
 *
 *   import { initializeApp, type FirebaseApp } from "firebase/app";
 *   import { getAuth, type Auth } from "firebase/auth";
 *   import { getFirestore, type Firestore } from "firebase/firestore";
 *   import { getDatabase, type Database } from "firebase/database";
 *
 *   export const app: FirebaseApp = initializeApp(firebaseConfig);
 *   export const auth: Auth = getAuth(app);
 *   export const db: Firestore = getFirestore(app);
 *   export const rtdb: Database = getDatabase(app);
 */

// كائن وهمي مؤقت — يمنع الأعطال قبل تركيب مكتبة Firebase
export const firebaseApp: unknown = null;
export const firebaseAuth: unknown = null;
export const firebaseDb: unknown = null;
export const firebaseRtdb: unknown = null;

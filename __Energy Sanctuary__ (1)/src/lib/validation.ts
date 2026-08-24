/**
 * ========================================================================
 *  مكتبة التحقق من المدخلات والحماية من الثغرات
 *  ------------------------------------------------------------------------
 *  - تستخدم Zod للتحقق من الشكل والحدود.
 *  - تنقّي النصوص (sanitize) لمنع هجمات XSS.
 *  - مركزية لتسهيل المراجعة الأمنية.
 * ========================================================================
 */

import { z } from "zod";

/**
 * تنقية النص من أي محارف خطرة قد تسبب ثغرة XSS.
 * - تزيل علامات HTML والأقواس الزاوية.
 * - تزيل المسافات الزائدة والمحارف غير المرئية.
 */
export function sanitizeText(input: string): string {
  return input
    .replace(/[<>]/g, "")              // إزالة < و > لمنع وسوم HTML
    .replace(/\u0000/g, "")            // إزالة null byte
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u001F\u007F]/g, "") // إزالة محارف التحكم
    .trim();
}

/**
 * تنقية رقم الهاتف — أرقام فقط.
 */
export function sanitizePhone(input: string): string {
  return input.replace(/\D/g, "").slice(0, 15);
}

// ----------------------- مخططات Zod -----------------------

// مخطط البريد الإلكتروني
export const emailSchema = z
  .string()
  .trim()
  .email({ message: "البريد الإلكتروني غير صالح" })
  .max(255, { message: "البريد الإلكتروني طويل جداً" });

// مخطط كلمة المرور — حد أدنى 8 خانات
export const passwordSchema = z
  .string()
  .min(8, { message: "كلمة المرور يجب ألا تقل عن 8 خانات" })
  .max(128, { message: "كلمة المرور طويلة جداً" });

// مخطط رقم الهاتف الليبي (9 أرقام بعد +218)
export const phoneSchema = z
  .string()
  .regex(/^\d{9,10}$/, { message: "رقم الهاتف غير صالح" });

// مخطط رمز التحقق OTP — 6 أرقام
export const otpSchema = z
  .string()
  .regex(/^\d{6}$/, { message: "رمز التحقق يجب أن يكون 6 أرقام" });

// مخطط الاسم
export const nameSchema = z
  .string()
  .trim()
  .min(2, { message: "الاسم قصير جداً" })
  .max(60, { message: "الاسم طويل جداً" });

// مخطط رسالة التواصل
export const messageSchema = z
  .string()
  .trim()
  .min(5, { message: "الرسالة قصيرة جداً" })
  .max(1000, { message: "الرسالة طويلة جداً" });

// نموذج تسجيل الدخول بالبريد
export const loginEmailSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

// نموذج إنشاء حساب
export const signupSchema = z.object({
  name: nameSchema,
  email: emailSchema,
  password: passwordSchema,
});

// نموذج التواصل
export const contactSchema = z.object({
  name: nameSchema,
  email: emailSchema,
  message: messageSchema,
});

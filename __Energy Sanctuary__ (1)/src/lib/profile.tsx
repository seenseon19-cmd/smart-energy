// إدارة بيانات الملف الشخصي مع التخزين المحلي للمتصفح لمنع فقدان البيانات
// تشمل: الاسم، الهاتف، المدينة، العنوان، الرقم الضريبي، نوع الحساب، رقم الحساب الموحّد
import { useEffect, useState, useCallback } from "react";

// مفتاح التخزين في localStorage
const STORAGE_KEY = "se_profile_v2";
// اسم حدث المزامنة بين المكوّنات
const SYNC_EVENT = "se:profile-updated";

// نوع الحساب: شخصي أو تجاري
export type AccountKind = "personal" | "commercial";

// شكل بيانات الملف الشخصي الموسّع
export type ProfileData = {
  firstName: string;
  lastName: string;
  phone: string;
  city: string;
  address: string;
  taxId: string;          // الرقم الضريبي - للتجاري فقط
  accountKind: AccountKind;
  accountNumber: string;  // رقم الحساب الموحّد المُولّد تلقائياً
};

// القيم الافتراضية حسب اللغة
export const defaultProfile = (isAr: boolean): ProfileData => ({
  firstName: isAr ? "أحمد" : "Ahmed",
  lastName: isAr ? "العلي" : "Ali",
  phone: "+218 91 234 5678",
  city: isAr ? "طرابلس" : "Tripoli",
  address: isAr ? "شارع الجمهورية، طرابلس" : "Jamahiriya St, Tripoli",
  taxId: "",
  accountKind: "personal",
  accountNumber: "",
});

// منطق توليد رقم الحساب الموحّد:
// إذا كان لدى المستخدم رقم ضريبي (تجاري) يُربط رقم الحساب به ليبقى موحّداً
// عبر جميع المساحات (شخصية + تجارية) لنفس المالك.
// إن لم يوجد، نولّد رقم حساب قياسي مكوّن من 10 خانات بناءً على بصمة الهاتف.
export function generateAccountNumber(p: Pick<ProfileData, "phone" | "taxId">): string {
  const tax = (p.taxId || "").replace(/\D/g, "");
  if (tax.length >= 6) {
    // SE-T-<TAXID> : رقم حساب موحّد مرتبط بالرقم الضريبي
    return `SE-T-${tax.slice(0, 12)}`;
  }
  const phoneDigits = (p.phone || "").replace(/\D/g, "");
  // بصمة بسيطة من الهاتف لإنتاج رقم ثابت بطول 10 خانات
  const seed = phoneDigits.padStart(10, "7").slice(-10);
  return `SE-P-${seed}`;
}

// قراءة البيانات المحفوظة من التخزين المحلي
export function readProfile(): ProfileData | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as Partial<ProfileData>;
    if (!parsed || typeof parsed !== "object") return null;
    const merged: ProfileData = {
      firstName: String(parsed.firstName ?? ""),
      lastName: String(parsed.lastName ?? ""),
      phone: String(parsed.phone ?? ""),
      city: String(parsed.city ?? ""),
      address: String(parsed.address ?? ""),
      taxId: String(parsed.taxId ?? ""),
      accountKind: (parsed.accountKind === "commercial" ? "commercial" : "personal"),
      accountNumber: String(parsed.accountNumber ?? ""),
    };
    if (!merged.accountNumber) merged.accountNumber = generateAccountNumber(merged);
    return merged;
  } catch {
    return null;
  }
}

// حفظ بيانات المستخدم في التخزين المحلي للمتصفح ومزامنتها فوراً مع باقي المكوّنات
export function writeProfile(data: ProfileData) {
  if (typeof window === "undefined") return;
  // ضمان وجود رقم حساب موحّد عند كل عملية حفظ
  const final: ProfileData = {
    ...data,
    accountNumber: data.accountNumber || generateAccountNumber(data),
  };
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(final));
  window.dispatchEvent(new CustomEvent(SYNC_EVENT, { detail: final }));
}

// خطّاف للقراءة فقط مع مزامنة فورية بين المكوّنات (للهيدر مثلاً)
export function useProfile(isAr = true): ProfileData {
  const [data, setData] = useState<ProfileData>(() => defaultProfile(isAr));

  useEffect(() => {
    const saved = readProfile();
    if (saved) setData(saved);
  }, []);

  useEffect(() => {
    const onUpdate = (e: Event) => {
      const ce = e as CustomEvent<ProfileData>;
      if (ce.detail) setData(ce.detail);
    };
    const onStorage = (e: StorageEvent) => {
      if (e.key === STORAGE_KEY) {
        const saved = readProfile();
        if (saved) setData(saved);
      }
    };
    window.addEventListener(SYNC_EVENT, onUpdate);
    window.addEventListener("storage", onStorage);
    return () => {
      window.removeEventListener(SYNC_EVENT, onUpdate);
      window.removeEventListener("storage", onStorage);
    };
  }, []);

  return data;
}

// خطّاف صفحة الإعدادات: قراءة + كتابة + توليد رقم الحساب تلقائياً
export function useEditableProfile(isAr = true) {
  const [profile, setProfile] = useState<ProfileData>(() => defaultProfile(isAr));
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    const saved = readProfile();
    if (saved) setProfile(saved);
    setHydrated(true);
  }, []);

  // حفظ بيانات المستخدم: يُولّد رقم الحساب آلياً قبل الحفظ
  const save = useCallback((next: ProfileData) => {
    const finalData: ProfileData = {
      ...next,
      accountNumber: generateAccountNumber(next),
    };
    setProfile(finalData);
    writeProfile(finalData);
  }, []);

  return { profile, setProfile, save, hydrated };
}

// صفحة الإعدادات والملف الشخصي — تصميم فاخر مع دعم الرقم الضريبي ورقم الحساب الموحّد
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useRef, useState } from "react";
import { AppShell } from "@/components/app-shell";
import { useEditableProfile, generateAccountNumber, type AccountKind } from "@/lib/profile";
import {
  Camera, User, Phone, MapPin, Briefcase, ChevronLeft, ChevronRight,
  HelpCircle, ShieldCheck, FileText, Mail, Star, Share2, LogOut,
  Sparkles, BadgeCheck, Hash, Building2, Home,
} from "lucide-react";
import { toast } from "sonner";
import { useSettings } from "@/lib/settings";

export const Route = createFileRoute("/profile")({
  component: ProfilePage,
});

// الصفحة الرئيسية للملف الشخصي والإعدادات
function ProfilePage() {
  const { t, lang } = useSettings();
  const navigate = useNavigate();
  const isAr = lang === "ar";
  const [avatar, setAvatar] = useState<string | null>(null);
  // استرجاع بيانات المستخدم المحفوظة محلياً تلقائياً عند فتح الصفحة
  const { profile, setProfile, save: persist } = useEditableProfile(isAr);
  const fileRef = useRef<HTMLInputElement>(null);
  const Chevron = isAr ? ChevronLeft : ChevronRight;

  // مساعد لتعديل أي حقل من الملف الشخصي
  const setField = <K extends keyof typeof profile>(k: K, v: (typeof profile)[K]) =>
    setProfile({ ...profile, [k]: v });

  // معاينة رقم الحساب الذي سيُولَّد بعد الحفظ (يتغيّر فوراً مع الرقم الضريبي/الهاتف)
  const previewAccountNumber = generateAccountNumber(profile);

  // رفع صورة الملف الشخصي
  const onFile = (f?: File | null) => {
    if (!f) return;
    setAvatar(URL.createObjectURL(f));
    toast.success(isAr ? "تم تحديث الصورة" : "Photo updated");
  };

  // حفظ بيانات الحساب في التخزين المحلي مع توليد رقم الحساب الموحّد آلياً
  const save = () => {
    if (!profile.firstName.trim() || !profile.lastName.trim()) {
      return toast.error(isAr ? "الاسم مطلوب" : "Name required");
    }
    if (profile.accountKind === "commercial" && profile.taxId.replace(/\D/g, "").length < 6) {
      return toast.error(isAr ? "أدخل رقماً ضريبياً صحيحاً" : "Enter a valid Tax ID");
    }
    persist(profile);
    toast.success(isAr ? "تم حفظ البيانات بنجاح" : "Data saved successfully");
  };

  const logout = () => {
    toast.success(isAr ? "تم تسجيل الخروج" : "Logged out");
    navigate({ to: "/auth" });
  };

  return (
    <AppShell>
      <div className="max-w-2xl mx-auto space-y-6 animate-fade-up pb-10">
        {/* بطاقة الترويسة — صورة الحساب ورقم الحساب */}
        <section className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_18px_40px_-22px_rgba(15,23,42,0.18)] dark:bg-slate-800/60 dark:border-slate-700 dark:shadow-none">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="h-20 w-20 rounded-full p-[2px] bg-gradient-to-br from-blue-500 to-orange-300">
                <div className="h-full w-full rounded-full bg-white grid place-items-center overflow-hidden dark:bg-slate-700">
                  {avatar ? (
                    <img src={avatar} alt="" className="h-full w-full object-cover" />
                  ) : (
                    <span className="text-2xl font-extrabold text-blue-600">
                      {profile.firstName.charAt(0) || "?"}
                    </span>
                  )}
                </div>
              </div>
              <button
                type="button"
                onClick={() => fileRef.current?.click()}
                className="absolute -bottom-1 -right-1 grid h-8 w-8 place-items-center rounded-full bg-blue-600 text-white shadow-lg border-2 border-white hover:scale-105 transition dark:border-slate-800"
              >
                <Camera className="h-4 w-4" strokeWidth={1.8} />
              </button>
              <input ref={fileRef} type="file" accept="image/*" hidden onChange={(e) => onFile(e.target.files?.[0])} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1.5">
                <h1 className="text-lg font-extrabold text-slate-900 truncate dark:text-slate-50">
                  {profile.firstName} {profile.lastName}
                </h1>
                <BadgeCheck className="h-4 w-4 text-blue-500" strokeWidth={2} />
              </div>
              <p className="text-xs text-slate-500 mt-0.5 dark:text-slate-400" dir="ltr">{profile.phone}</p>
              {/* رقم الحساب الموحّد — مرئي بوضوح أعلى الصفحة */}
              <div className="mt-2 inline-flex items-center gap-1.5 rounded-full bg-blue-50 text-blue-700 px-2.5 py-0.5 text-[11px] font-bold dark:bg-blue-950/50 dark:text-blue-300">
                <Hash className="h-3 w-3" strokeWidth={2} />
                <span dir="ltr">{previewAccountNumber}</span>
              </div>
            </div>
          </div>
        </section>

        {/* قسم إكمال بيانات الحساب */}
        <section className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_18px_40px_-22px_rgba(15,23,42,0.18)] space-y-4 dark:bg-slate-800/60 dark:border-slate-700 dark:shadow-none">
          <header className="flex items-center gap-2">
            <Sparkles className="h-4 w-4 text-orange-400" strokeWidth={1.8} />
            <h2 className="font-extrabold text-slate-900 dark:text-slate-50">
              {isAr ? "إكمال بيانات الحساب" : "Complete your account"}
            </h2>
          </header>

          {/* مبدّل نوع الحساب: شخصي / تجاري */}
          <div className="grid grid-cols-2 gap-2 p-1 rounded-2xl bg-slate-100 dark:bg-slate-900/60">
            {(["personal", "commercial"] as AccountKind[]).map((k) => {
              const active = profile.accountKind === k;
              const Icon = k === "personal" ? Home : Building2;
              return (
                <button
                  key={k}
                  type="button"
                  onClick={() => setField("accountKind", k)}
                  className={`flex items-center justify-center gap-2 py-2 rounded-xl text-xs font-bold transition ${
                    active
                      ? "bg-white text-blue-600 shadow-sm dark:bg-slate-700 dark:text-blue-300"
                      : "text-slate-500 dark:text-slate-400"
                  }`}
                >
                  <Icon className="h-3.5 w-3.5" />
                  {k === "personal"
                    ? isAr ? "حساب شخصي" : "Personal"
                    : isAr ? "حساب تجاري" : "Commercial"}
                </button>
              );
            })}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Field icon={<User className="h-4 w-4" />} label={isAr ? "الاسم الأول" : "First name"}>
              <input value={profile.firstName} onChange={(e) => setField("firstName", e.target.value)}
                className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
            </Field>
            <Field icon={<User className="h-4 w-4" />} label={isAr ? "اسم العائلة" : "Last name"}>
              <input value={profile.lastName} onChange={(e) => setField("lastName", e.target.value)}
                className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
            </Field>
          </div>

          <Field icon={<Phone className="h-4 w-4" />} label={isAr ? "رقم الهاتف" : "Phone"}>
            <input dir="ltr" value={profile.phone} onChange={(e) => setField("phone", e.target.value)}
              className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
          </Field>

          <div className="grid grid-cols-2 gap-3">
            <Field icon={<MapPin className="h-4 w-4" />} label={isAr ? "المدينة" : "City"}>
              <input value={profile.city} onChange={(e) => setField("city", e.target.value)}
                className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
            </Field>
            <Field icon={<MapPin className="h-4 w-4" />} label={isAr ? "العنوان" : "Address"}>
              <input value={profile.address} onChange={(e) => setField("address", e.target.value)}
                className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
            </Field>
          </div>

          {/* الرقم الضريبي — يظهر فقط للحسابات التجارية ويُربط برقم الحساب الموحّد */}
          {profile.accountKind === "commercial" && (
            <Field icon={<Hash className="h-4 w-4" />} label={isAr ? "الرقم الضريبي" : "Tax ID"}>
              <input dir="ltr" value={profile.taxId}
                onChange={(e) => setField("taxId", e.target.value.replace(/[^\d]/g, "").slice(0, 14))}
                placeholder="123456789012"
                className="w-full bg-transparent outline-none text-sm text-slate-900 placeholder:text-slate-400 dark:text-white dark:placeholder:text-slate-500" />
            </Field>
          )}

          {/* عرض رقم الحساب الموحّد (مولّد آلياً، غير قابل للتعديل) */}
          <div className="rounded-2xl border border-dashed border-blue-300 bg-blue-50/50 p-3 dark:bg-blue-950/30 dark:border-blue-800">
            <div className="text-[11px] font-semibold text-blue-700 dark:text-blue-300 mb-1">
              {isAr ? "رقم الحساب الموحّد (تلقائي)" : "Unified Account Number (auto)"}
            </div>
            <div dir="ltr" className="text-base font-extrabold text-blue-900 dark:text-blue-200 tabular-nums">
              {previewAccountNumber}
            </div>
            <div className="text-[10px] text-blue-700/70 dark:text-blue-400/70 mt-1">
              {isAr
                ? profile.accountKind === "commercial"
                  ? "مرتبط بالرقم الضريبي ويُشارك بين جميع مساحاتك"
                  : "موحّد بين مساحاتك الشخصية والتجارية"
                : "Shared across all your spaces"}
            </div>
          </div>

          <button
            onClick={save}
            className="w-full mt-2 rounded-2xl py-3 font-bold text-white bg-gradient-to-r from-blue-600 to-orange-400 shadow-[0_12px_24px_-10px_rgba(37,99,235,0.5)] hover:opacity-95 transition"
          >
            {isAr ? "حفظ البيانات" : "Save"}
          </button>
        </section>

        {/* بانر تسجيل النشاط التجاري — برتقالي ناعم */}
        <section className="relative rounded-3xl p-6 overflow-hidden border border-orange-200/70"
          style={{ background: "linear-gradient(135deg, #FFF7ED 0%, #FFEDD5 50%, #FED7AA 100%)" }}>
          <div className="absolute -top-10 -right-10 h-40 w-40 rounded-full bg-white/40 blur-2xl" />
          <div className="relative flex items-start gap-4">
            <div className="grid h-12 w-12 place-items-center rounded-2xl bg-white/80 text-orange-500 shrink-0">
              <Briefcase className="h-6 w-6" strokeWidth={1.6} />
            </div>
            <div className="flex-1">
              <h3 className="font-extrabold text-orange-900 text-base">
                {isAr ? "سجّل نشاطك التجاري الآن" : "Register your business now"}
              </h3>
              <p className="text-xs text-orange-800/80 mt-1">
                {isAr ? "احصل على ميزات حصرية للأعمال وفوترة احترافية" : "Unlock business-grade features and billing"}
              </p>
              <button
                onClick={() => navigate({ to: "/pricing" })}
                className="mt-3 inline-flex items-center gap-1.5 rounded-full bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold px-4 py-2 transition"
              >
                {isAr ? "ابدأ الآن" : "Get started"}
                <Chevron className="h-3.5 w-3.5" strokeWidth={2} />
              </button>
            </div>
          </div>
        </section>

        {/* قائمة المزيد */}
        <section className="bg-white rounded-3xl border border-slate-100 shadow-[0_18px_40px_-22px_rgba(15,23,42,0.18)] overflow-hidden divide-y divide-slate-100 dark:bg-slate-800/60 dark:border-slate-700 dark:divide-slate-700/70 dark:shadow-none">
          <MoreItem icon={HelpCircle} color="#2563EB" bg="#EFF6FF" label={isAr ? "الأسئلة الشائعة" : "FAQ"} chevron={Chevron} />
          <MoreItem icon={ShieldCheck} color="#059669" bg="#ECFDF5" label={isAr ? "سياسة الخصوصية" : "Privacy Policy"} chevron={Chevron} />
          <MoreItem icon={FileText} color="#F97316" bg="#FFF7ED" label={isAr ? "الشروط والأحكام" : "Terms & Conditions"} chevron={Chevron} />
          <MoreItem icon={Mail} color="#0891B2" bg="#ECFEFF" label={isAr ? "تواصل معنا" : "Contact Us"} chevron={Chevron}
            onClick={() => (window.location.href = "mailto:SOUHAYLSAAID@GMAIL.COM")} />
          <MoreItem icon={Star} color="#EA580C" bg="#FFEDD5" label={isAr ? "قيّمنا" : "Rate Us"} chevron={Chevron} />
          <MoreItem icon={Share2} color="#4F46E5" bg="#EEF2FF" label={isAr ? "شارك التطبيق" : "Share App"} chevron={Chevron}
            onClick={async () => {
              try {
                if (navigator.share) await navigator.share({ title: "SmartEnergy", url: window.location.origin });
                else await navigator.clipboard.writeText(window.location.origin);
                toast.success(isAr ? "تمت المشاركة" : "Shared");
              } catch {}
            }} />
        </section>

        <button
          onClick={logout}
          className="w-full inline-flex items-center justify-center gap-2 rounded-2xl py-4 font-bold text-white bg-gradient-to-r from-red-500 to-red-600 shadow-[0_14px_30px_-12px_rgba(220,38,38,0.55)] hover:opacity-95 transition"
        >
          <LogOut className="h-4 w-4" strokeWidth={2} />
          {isAr ? "تسجيل الخروج" : "Log out"}
        </button>

        <p className="text-center text-[10px] text-slate-400 tracking-wider pt-2">
          © 2026 SmartEnergy · v2.1.0
        </p>
        <span className="hidden">{t("pf.unnamed")}</span>
      </div>
    </AppShell>
  );
}

// حقل إدخال موحّد بأيقونة وعنوان
function Field({ icon, label, children }: { icon: React.ReactNode; label: string; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="text-[11px] font-semibold text-slate-500 mb-1.5 block dark:text-slate-400">{label}</span>
      <div className="group flex items-center gap-2.5 rounded-2xl bg-slate-50 border border-slate-200 px-3.5 py-3 transition focus-within:border-blue-400 focus-within:bg-white dark:bg-slate-900/50 dark:border-slate-700 dark:focus-within:bg-slate-800 dark:focus-within:border-blue-400">
        <span className="text-slate-400 group-focus-within:text-blue-500 transition-colors dark:text-slate-500 dark:group-focus-within:text-blue-300">{icon}</span>
        {children}
      </div>
    </label>
  );
}

// عنصر قائمة "المزيد" بأيقونة ملوّنة
function MoreItem({
  icon: Icon, color, bg, label, chevron: Chevron, onClick,
}: {
  icon: React.ComponentType<{ className?: string; strokeWidth?: number }>;
  color: string; bg: string; label: string;
  chevron: React.ComponentType<{ className?: string; strokeWidth?: number }>;
  onClick?: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="w-full flex items-center gap-3 px-5 py-4 hover:bg-slate-50 transition text-start dark:hover:bg-slate-700/50"
    >
      <span className="grid h-9 w-9 place-items-center rounded-xl shrink-0" style={{ background: bg, color }}>
        <Icon className="h-4 w-4" strokeWidth={1.8} />
      </span>
      <span className="flex-1 text-sm font-semibold text-slate-800 dark:text-slate-100">{label}</span>
      <Chevron className="h-4 w-4 text-slate-400 dark:text-slate-500" strokeWidth={1.8} />
    </button>
  );
}

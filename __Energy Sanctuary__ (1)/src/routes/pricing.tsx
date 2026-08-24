import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Check, X, Building2, Home } from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useSettings } from "@/lib/settings";
import { PLANS, useStore, type PlanId } from "@/lib/store";

export const Route = createFileRoute("/pricing")({
  component: () => <AppShell><PricingPage /></AppShell>,
});

type Cycle = "monthly" | "quarterly" | "yearly";

// تعريف الباقات الأربع بألوان متطابقة مع التصميم المرجعي
type Feature = { label: string; included: boolean };
type Tier = {
  id: PlanId;
  name: string;
  tagline: string;
  // تدرج رأس البطاقة
  headerGradient: string;
  // توهج الظل المطابق للون البطاقة
  glow: string;
  // لون زر الاشتراك
  buttonClass: string;
  price: Record<Cycle, number>;
  // الميزات تُولَّد ديناميكياً حسب دورة الفوترة لإبراز قيمة الاشتراك السنوي
  features: (cycle: Cycle) => Feature[];
};

// نص سجل الاستهلاك يتغيّر تلقائياً عند اختيار الاشتراك السنوي
const historyLabel = (cycle: Cycle, baseDays: string) =>
  cycle === "yearly" ? "سجل استهلاك كامل" : baseDays;

const HOME_TIERS: Tier[] = [
  {
    id: "free",
    name: "الباقة المجانية",
    tagline: "ابدأ التحكم في طاقتك مجاناً",
    headerGradient: "from-slate-500 via-slate-600 to-slate-700",
    glow: "shadow-[0_24px_60px_-20px_rgba(100,116,139,0.55)]",
    buttonClass: "border-slate-400 text-slate-200 hover:bg-slate-400/10",
    price: { monthly: 0, quarterly: 0, yearly: 0 },
    features: () => [
      { label: "حتى جهازين", included: true },
      { label: "لوحة تحكم أساسية", included: true },
      { label: "متابعة فورية للاستهلاك", included: true },
      { label: "تنبيهات الحمل الزائد", included: false },
      { label: "تقارير PDF", included: false },
      { label: "دعم فني على مدار الساعة", included: false },
    ],
  },
  {
    id: "basic",
    name: "الباقة البرونزية",
    tagline: "للمنازل الصغيرة والاستخدام اليومي",
    headerGradient: "from-fuchsia-500 via-pink-500 to-rose-500",
    glow: "shadow-[0_30px_80px_-20px_rgba(236,72,153,0.55)]",
    buttonClass: "border-pink-400 text-pink-300 hover:bg-pink-500/15",
    price: { monthly: 15, quarterly: 40, yearly: 150 },
    features: (cycle) => [
      { label: "حتى 6 أجهزة", included: true },
      { label: "تنبيهات الحمل الزائد", included: true },
      { label: historyLabel(cycle, "سجل استهلاك 30 يوماً"), included: true },
      { label: "تقارير أسبوعية", included: true },
      { label: "تقارير PDF", included: false },
      { label: "أتمتة متقدمة", included: false },
    ],
  },
  {
    id: "pro",
    name: "الباقة الاحترافية",
    tagline: "الأكثر شعبية للعائلات والمستخدمين النشطين",
    headerGradient: "from-emerald-400 via-teal-500 to-cyan-600",
    glow: "shadow-[0_34px_90px_-20px_rgba(16,185,129,0.6)]",
    buttonClass: "border-emerald-400 text-emerald-300 hover:bg-emerald-500/15",
    price: { monthly: 35, quarterly: 95, yearly: 350 },
    features: (cycle) => [
      { label: "حتى 20 جهازاً", included: true },
      { label: "تقارير PDF كاملة", included: true },
      { label: "فصل تلقائي عند الحمل الزائد", included: true },
      { label: historyLabel(cycle, "سجل استهلاك 90 يوماً"), included: true },
      { label: "أتمتة متقدمة", included: true },
      { label: "دعم فني على مدار الساعة", included: false },
    ],
  },
  {
    id: "ultimate",
    name: "الباقة الذهبية",
    tagline: "تجربة فاخرة بلا حدود لكل البيت الذكي",
    headerGradient: "from-amber-400 via-yellow-500 to-orange-500",
    glow: "shadow-[0_36px_100px_-20px_rgba(245,158,11,0.65)]",
    buttonClass: "border-amber-400 text-amber-300 hover:bg-amber-500/15",
    price: { monthly: 50, quarterly: 140, yearly: 400 },
    features: (cycle) => [
      { label: "أجهزة غير محدودة", included: true },
      { label: "مدير حساب مخصص", included: true },
      { label: "دعم فني 24/7", included: true },
      { label: "وصول مبكر للميزات الجديدة", included: true },
      { label: historyLabel(cycle, "سجل استهلاك سنة كاملة"), included: true },
      { label: "كل ميزات الاحترافية", included: true },
    ],
  },
];

const COMMERCIAL_TIERS: Tier[] = [
  { ...HOME_TIERS[0], tagline: "تجربة الباقة التجارية مجاناً", price: { monthly: 0, quarterly: 0, yearly: 0 } },
  { ...HOME_TIERS[1], tagline: "للمحلات الصغيرة والمكاتب", price: { monthly: 30, quarterly: 85, yearly: 300 } },
  { ...HOME_TIERS[2], tagline: "للمنشآت التجارية النشطة", price: { monthly: 75, quarterly: 210, yearly: 750 } },
  { ...HOME_TIERS[3], tagline: "للمؤسسات والفروع المتعددة", price: { monthly: 120, quarterly: 340, yearly: 1200 } },
];

function PricingPage() {
  const { spaces, activeSpace, setActiveSpaceId, updateSpace } = useStore();
  const { lang } = useSettings();
  const [cycle, setCycle] = useState<Cycle>("monthly");
  const isAr = lang === "ar";

  const tiers = activeSpace.type === "commercial" ? COMMERCIAL_TIERS : HOME_TIERS;
  // تسميات دورة الفوترة بالعربية المختصرة المعتمدة
  const perLabel =
    cycle === "monthly" ? (isAr ? "/ شهر" : "/ mo")
    : cycle === "quarterly" ? (isAr ? "/ 3 أشهر" : "/ qtr")
    : (isAr ? "/ سنة" : "/ yr");

  const choose = (id: PlanId, name: string) => {
    updateSpace(activeSpace.id, { plan: id });
    toast.success(`${isAr ? "تم تفعيل" : "Activated"} ${name}`);
  };

  return (
    <div className="space-y-8 pb-10">
      {/* رأس الصفحة مع تبديل النوع ودورة الفوترة */}
      <section className="relative overflow-hidden rounded-3xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900 lg:p-8">
        <div className="grid gap-6 lg:grid-cols-[1fr_auto] lg:items-center">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full bg-gradient-to-r from-fuchsia-500/10 via-emerald-500/10 to-amber-500/10 px-3 py-1 text-[11px] font-extrabold uppercase tracking-[0.22em] text-slate-700 dark:text-slate-200">
              {isAr ? "باقات الاشتراك" : "Subscription Plans"}
            </div>
            <h1 className="mt-4 text-3xl font-black leading-tight text-slate-950 dark:text-white lg:text-5xl">
              {isAr ? "اختر الباقة التي تناسبك" : "Pick the plan that fits you"}
            </h1>
            <p className="mt-3 max-w-2xl text-sm leading-7 text-slate-600 dark:text-slate-300">
              {isAr ? "أربع باقات مدروسة بعناية لكل مستوى استخدام، مع إمكانية الترقية في أي وقت." : "Four tiers crafted for every usage level, upgrade anytime."}
            </p>
          </div>
          <div className="space-y-3 rounded-2xl border border-slate-200 bg-slate-50 p-3 dark:border-slate-800 dark:bg-slate-950">
            {/* تبديل نوع الحساب: شخصي = أزرق مؤسسي، تجاري = ذهبي فاخر مع توهج مطابق */}
            <div className="grid grid-cols-2 gap-1 rounded-xl bg-white p-1 dark:bg-slate-900">
              {([
                {
                  type: "home" as const,
                  label: isAr ? "شخصي" : "Personal",
                  Icon: Home,
                  activeClass: "bg-blue-600 text-white shadow-[0_10px_30px_-8px_rgba(37,99,235,0.7)]",
                },
                {
                  type: "commercial" as const,
                  label: isAr ? "تجاري" : "Commercial",
                  Icon: Building2,
                  activeClass: "bg-amber-500 text-white shadow-[0_10px_30px_-8px_rgba(245,158,11,0.75)]",
                },
              ]).map((o) => {
                const selected = activeSpace.type === o.type;
                return (
                  <button
                    key={o.type}
                    type="button"
                    onClick={() => {
                      const t = spaces.find((s) => s.type === o.type);
                      if (t) setActiveSpaceId(t.id);
                    }}
                    className={`inline-flex items-center justify-center gap-2 rounded-lg py-2 text-xs font-extrabold transition-all duration-300 ${
                      selected ? o.activeClass : "text-slate-500 hover:text-slate-700 dark:hover:text-slate-200"
                    }`}
                  >
                    <o.Icon className="h-3.5 w-3.5" strokeWidth={1.5} />
                    {o.label}
                  </button>
                );
              })}
            </div>
            <Tabs value={cycle} onValueChange={(v) => setCycle(v as Cycle)}>
              <TabsList className="grid h-auto w-full grid-cols-3 rounded-xl bg-white p-1 dark:bg-slate-900">
                <TabsTrigger value="monthly" className="rounded-lg py-2 text-xs">{isAr ? "شهر" : "Monthly"}</TabsTrigger>
                <TabsTrigger value="quarterly" className="rounded-lg py-2 text-xs">{isAr ? "3 أشهر" : "Quarterly"}</TabsTrigger>
                <TabsTrigger value="yearly" className="rounded-lg py-2 text-xs">{isAr ? "سنة" : "Yearly"}</TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
        </div>
      </section>

      {/* شبكة البطاقات الأربع: رأس ملوّن وجسم داكن أنيق */}
      <section className="grid gap-6 sm:grid-cols-2 xl:grid-cols-4">
        {tiers.map((tier) => {
          const isCurrent = activeSpace.plan === tier.id;
          // توليد الميزات ديناميكياً حسب دورة الفوترة (سنوي = سجل استهلاك كامل)
          const features = tier.features(cycle);
          return (
            <article
              key={tier.id}
              className={`group relative flex flex-col overflow-hidden rounded-3xl bg-slate-950 transition duration-300 hover:-translate-y-1.5 ${tier.glow}`}
            >
              {/* رأس البطاقة الملوّن */}
              <div className={`relative bg-gradient-to-br ${tier.headerGradient} px-6 pb-10 pt-8 text-center`}>
                <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,_rgba(255,255,255,0.35),_transparent_60%)]" />
                <h2 className="relative text-2xl font-black tracking-tight text-white drop-shadow-sm lg:text-[1.7rem]">
                  {tier.name}
                </h2>
                <p className="relative mt-2 text-xs font-semibold text-white/85">{tier.tagline}</p>
              </div>

              {/* قسم السعر يطفو فوق الجسم الداكن */}
              <div className="-mt-6 px-6">
                <div className="rounded-2xl border border-white/10 bg-slate-900/90 px-4 py-4 text-center backdrop-blur">
                  <div className="flex items-baseline justify-center gap-1.5">
                    <span className="text-4xl font-black tabular-nums text-white">{tier.price[cycle]}</span>
                    <span className="text-xs font-bold text-slate-400">{isAr ? "ر.س" : "SAR"}</span>
                  </div>
                  <div className="mt-1 text-[11px] font-semibold text-slate-500">{perLabel}</div>
                </div>
              </div>

              {/* الجسم الداكن مع قائمة الميزات */}
              <div className="flex flex-1 flex-col px-6 pb-6 pt-5">
                <ul className="flex-1 space-y-3">
                  {features.map((f, i) => (
                    <li key={i} className="flex items-center gap-3 text-sm font-medium text-slate-200">
                      <span
                        className={`grid h-6 w-6 shrink-0 place-items-center rounded-full ${
                          f.included
                            ? "bg-emerald-500/20 text-emerald-400"
                            : "bg-rose-500/15 text-rose-400"
                        }`}
                      >
                        {f.included ? <Check className="h-3.5 w-3.5" strokeWidth={3} /> : <X className="h-3.5 w-3.5" strokeWidth={3} />}
                      </span>
                      <span className={f.included ? "text-slate-100" : "text-slate-500 line-through"}>{f.label}</span>
                    </li>
                  ))}
                </ul>

                {/* زر الاشتراك الأنيق ذو الإطار المضيء */}
                <button
                  type="button"
                  onClick={() => choose(tier.id, tier.name)}
                  disabled={isCurrent}
                  className={`mt-6 w-full rounded-2xl border-2 bg-transparent py-3 text-sm font-black tracking-wide transition disabled:cursor-not-allowed disabled:border-emerald-500 disabled:bg-emerald-500/15 disabled:text-emerald-300 ${tier.buttonClass}`}
                >
                  {isCurrent ? (isAr ? "الباقة الحالية" : "Current Plan") : (isAr ? "اشترك الآن" : "Subscribe Now")}
                </button>
              </div>
            </article>
          );
        })}
      </section>

      {/* ملاحظة أسفل الشبكة */}
      <p className="text-center text-xs text-slate-500 dark:text-slate-400">
        {isAr
          ? `جميع الباقات تشمل تحديثات مستمرة وحماية بياناتك. الخطة الحالية: ${PLANS[activeSpace.plan].name}`
          : `All plans include continuous updates and data protection. Current: ${PLANS[activeSpace.plan].name}`}
      </p>
    </div>
  );
}

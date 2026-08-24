// لافتة ترويجية تظهر مرة واحدة كنافذة فوق الشاشة بعد تسجيل الدخول
// تختفي تلقائياً بعد الإغلاق ولا تعود حتى تسجيل دخول جديد
import { useEffect, useState } from "react";
import { useRouterState } from "@tanstack/react-router";
import { X } from "lucide-react";
import brandLogo from "@/assets/smart-energy-logo.webp";
import phoneShot from "@/assets/promo-phone.png";

export function PromoBanner() {
  const [open, setOpen] = useState(false);
  // مراقبة تغيّر المسار لإعادة فحص علم العرض بعد الانتقال من صفحة التسجيل
  const path = useRouterState({ select: (s) => s.location.pathname });

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (sessionStorage.getItem("show_promo") === "1") {
      setOpen(true);
      sessionStorage.removeItem("show_promo");
    }
  }, [path]);

  if (!open) return null;

  const close = () => setOpen(false);

  return (
    <div
      className="fixed inset-0 z-[100] grid place-items-center p-4 bg-black/70 backdrop-blur-md animate-fade-in"
      onClick={close}
      dir="rtl"
    >
      <section
        onClick={(e) => e.stopPropagation()}
        className="relative w-full max-w-3xl overflow-hidden rounded-3xl border border-white/10
                   bg-[radial-gradient(120%_120%_at_85%_15%,rgba(245,158,11,0.18),transparent_55%),radial-gradient(120%_120%_at_10%_90%,rgba(37,99,235,0.22),transparent_55%),linear-gradient(135deg,#0b1220_0%,#111827_60%,#0b1220_100%)]
                   shadow-[0_40px_120px_-30px_rgba(37,99,235,0.6)] animate-fade-up"
      >
        {/* زخارف خلفية */}
        <div className="pointer-events-none absolute -top-24 -left-24 h-72 w-72 rounded-full bg-amber-500/15 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-24 -right-24 h-72 w-72 rounded-full bg-blue-500/20 blur-3xl" />

        {/* زر الإغلاق */}
        <button
          onClick={close}
          aria-label="إغلاق الإعلان"
          className="absolute top-4 left-4 z-20 grid h-10 w-10 place-items-center rounded-full bg-white/10 text-white hover:bg-white/20 transition"
        >
          <X className="h-5 w-5" />
        </button>

        <div className="grid md:grid-cols-2 gap-4 p-6 md:p-10 items-center">
          {/* النص الترويجي */}
          <div className="space-y-5 text-right">
            {/* الشعار + الاسم الرسمي */}
            <div className="flex items-center gap-3">
              <img
                src={brandLogo}
                alt="SmartEnergy"
                className="h-12 w-12 object-contain rounded-xl bg-white p-1 shadow-[0_8px_24px_-8px_rgba(37,99,235,0.55)]"
              />
              <div className="leading-tight">
                <div className="text-lg md:text-xl font-extrabold text-white">
                  Smart<span className="text-blue-400">Energy</span>
                </div>
                <div className="text-[10px] uppercase tracking-[0.28em] text-white/50">
                  Smarter · Better Future
                </div>
              </div>
            </div>

            <div>
              <h2 className="text-3xl md:text-5xl font-black text-white leading-[1.15]">
                تطبيق الكهرباء
                <span className="block text-amber-400 mt-1 tracking-[0.15em]">مَعَـــاك</span>
              </h2>
              <p className="mt-4 text-white/80 text-sm md:text-base">
                نقدّم الطاقة الكهربائية عبر منظومة ذكية بموثوقية عالية.
              </p>
            </div>

            <ul className="space-y-1.5 text-white/85 font-semibold text-sm md:text-base">
              <li>• بتجربة جديدة..</li>
              <li>• خدمات أكثر..</li>
              <li>• تواصل دائم..</li>
            </ul>

            <button
              onClick={close}
              className="mt-2 inline-flex items-center justify-center rounded-xl bg-blue-600 px-6 py-2.5 text-sm font-bold text-white shadow-[0_10px_30px_-10px_rgba(37,99,235,0.7)] hover:bg-blue-500 transition"
            >
              ابدأ الآن
            </button>
          </div>

          {/* صورة التطبيق */}
          <div className="relative grid place-items-center">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(37,99,235,0.25),transparent_60%)] blur-2xl" />
            <img
              src={phoneShot}
              alt="تطبيق SmartEnergy"
              loading="lazy"
              width={1024}
              height={1024}
              className="relative z-10 max-h-[300px] md:max-h-[380px] w-auto object-contain drop-shadow-[0_30px_40px_rgba(0,0,0,0.6)]"
            />
          </div>
        </div>
      </section>
    </div>
  );
}

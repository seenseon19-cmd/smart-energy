// شاشة البداية الفاخرة — تظهر مرة واحدة عند فتح التطبيق ثم تتلاشى بسلاسة
import { useEffect, useState } from "react";
import logo from "@/assets/smart-energy-logo.webp";

// مكوّن الشاشة الترحيبية الناعمة
export function SplashScreen() {
  const [visible, setVisible] = useState(true);
  const [fading, setFading] = useState(false);

  useEffect(() => {
    // بدء التلاشي بعد 1.6 ثانية ثم إزالة من DOM بعد 2.4 ثانية
    const fadeT = setTimeout(() => setFading(true), 1600);
    const hideT = setTimeout(() => setVisible(false), 2400);
    return () => { clearTimeout(fadeT); clearTimeout(hideT); };
  }, []);

  if (!visible) return null;

  return (
    <div
      className={`fixed inset-0 z-[200] grid place-items-center transition-opacity duration-700 ease-out ${
        fading ? "opacity-0 pointer-events-none" : "opacity-100"
      }`}
      style={{
        background:
          "radial-gradient(ellipse at top, #DBEAFE 0%, #FFF7ED 55%, #FFFFFF 100%)",
      }}
      aria-hidden={fading}
    >
      {/* وهج خلفي ناعم بلون البرتقالي والأزرق */}
      <div className="absolute -top-40 -right-32 h-[420px] w-[420px] rounded-full bg-orange-200/50 blur-[120px]" />
      <div className="absolute -bottom-40 -left-32 h-[460px] w-[460px] rounded-full bg-blue-200/50 blur-[140px]" />

      <div className="relative flex flex-col items-center gap-5 animate-fade-up">
        <img
          src={logo}
          alt="SmartEnergy"
          className="h-40 w-40 object-contain drop-shadow-[0_20px_40px_rgba(37,99,235,0.25)] animate-float"
        />
        <div
          className="h-px w-32 mt-2"
          style={{
            background:
              "linear-gradient(90deg, transparent, rgba(37,99,235,0.6), transparent)",
          }}
        />
        <p className="text-[11px] uppercase tracking-[0.4em] text-slate-500">
          Smarter Energy · Better Future
        </p>
      </div>
    </div>
  );
}

import { Link, useRouterState } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { LayoutDashboard, Cpu, BarChart3, Shield, Layers, Crown, Settings, UserCircle2 } from "lucide-react";
import { useStore, PLANS } from "@/lib/store";
import { useSettings } from "@/lib/settings";

import { SpaceSwitcher } from "./space-switcher";
// شعار الشركة الرسمي — يُستخدم في الترويسة
import brandLogo from "@/assets/smart-energy-logo.webp";
// قائمة جانبية فاخرة بالأبيض والأسود
import { MobileNavDrawer } from "./mobile-nav-drawer";

const NAV = [
  { to: "/", key: "nav.dashboard", icon: LayoutDashboard },
  { to: "/devices", key: "nav.devices", icon: Cpu },
  { to: "/analytics", key: "nav.analytics", icon: BarChart3 },
  { to: "/spaces", key: "nav.spaces", icon: Layers },
  { to: "/pricing", key: "nav.pricing", icon: Crown },
  { to: "/safety", key: "nav.safety", icon: Shield },
  { to: "/settings", key: "nav.settings", icon: Settings },
  { to: "/profile", key: "nav.profile", icon: UserCircle2 },
];

export function AppShell({ children }: { children: ReactNode }) {
  const path = useRouterState({ select: (s) => s.location.pathname });
  const { activeSpace, overload } = useStore();
  const { t } = useSettings();
  const plan = PLANS[activeSpace.plan];

  return (
    <div className="min-h-screen flex w-full">
      <aside className="hidden lg:flex w-64 shrink-0 flex-col gap-6 p-5 border-l border-white/5 glass">
        {/* شعار SmartEnergy الرسمي بصيغة WEBP — يحافظ على نسبه عبر object-contain */}
        <Link to="/" className="flex items-center gap-3 group">
          <img
            src={brandLogo}
            alt="SmartEnergy"
            className="h-12 w-12 object-contain rounded-xl bg-white/90 dark:bg-white/95 p-1 shadow-[0_8px_24px_-8px_rgba(37,99,235,0.35)]"
          />
          <div className="leading-tight">
            <div className="text-lg font-extrabold tracking-tight">
              Smart<span className="text-blue-600 dark:text-blue-400">Energy</span>
            </div>
            <div className="text-[10px] uppercase tracking-[0.22em] text-orange-500/90 font-semibold">Smarter · Better Future</div>
          </div>
        </Link>

        <SpaceSwitcher />

        <nav className="flex flex-col gap-1">
          {NAV.map((n) => {
            const active = path === n.to;
            return (
              <Link key={n.to} to={n.to}
                className={`group flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all ${
                  active
                    ? "bg-gradient-to-l from-[color:var(--cyan-glow)]/20 to-transparent text-[color:var(--cyan-glow)] shadow-[inset_0_0_0_1px_oklch(0.82_0.18_200/0.25)]"
                    : "text-muted-foreground hover:text-foreground hover:bg-white/5"
                }`}>
                <n.icon className={`h-4 w-4 ${active ? "text-glow-cyan" : ""}`} />
                {t(n.key)}
              </Link>
            );
          })}
        </nav>

        <div className="mt-auto glass rounded-2xl p-4 text-sm">
          <div className="text-xs text-muted-foreground">{t("header.subscription")}</div>
          <div className="mt-1 font-bold text-[color:var(--cyan-glow)]">{t(`plan.${activeSpace.plan}`)}</div>
          <div className="text-xs text-muted-foreground mt-1">
            {activeSpace.devices.length}/{plan.deviceLimit === Infinity ? "∞" : plan.deviceLimit} {t("header.deviceCount")}
          </div>
        </div>
      </aside>

      <div className="flex-1 flex flex-col min-w-0">
        {/* ترويسة نحيفة: زر القائمة على الجانب والشعار في المنتصف فقط */}
        <header className="relative flex items-center justify-between gap-3 px-4 lg:px-8 h-14 border-b border-white/5">
          <MobileNavDrawer />
          <Link
            to="/"
            className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2"
            aria-label="SmartEnergy"
          >
            <img
              src={brandLogo}
              alt="SmartEnergy"
              className="h-8 w-8 object-contain rounded-md bg-white/95 p-0.5"
            />
            <span className="font-extrabold tracking-tight text-sm">
              Smart<span className="text-blue-600 dark:text-blue-400">Energy</span>
            </span>
          </Link>
          {/* عنصر فارغ لموازنة المحاذاة */}
          <span className="h-10 w-10" aria-hidden />
        </header>

        {/* تنبيه الحمل الزائد — يبقى أسفل الترويسة فقط عند الحاجة */}
        {overload && (
          <div className="px-4 lg:px-8 py-2 border-b border-white/5">
            <span className="inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-semibold animate-flash-danger border bg-[color:var(--red-glow)]/10 text-[color:var(--red-glow)]">
              <Shield className="h-3.5 w-3.5" /> {t("header.warningOverload")}
            </span>
          </div>
        )}

        <main className="flex-1 px-4 lg:px-8 py-6">{children}</main>
      </div>
    </div>
  );
}

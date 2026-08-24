// قائمة جانبية فاخرة بالأبيض والأسود — تنزلق من جانب الشاشة بدعم RTL
import { useState } from "react";
import { Link, useRouterState } from "@tanstack/react-router";
import { Menu, X, LayoutDashboard, Cpu, BarChart3, Layers, Crown, Shield, Settings, UserCircle2 } from "lucide-react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { useSettings } from "@/lib/settings";
import brandLogo from "@/assets/smart-energy-logo.webp";

// عناصر القائمة بالترتيب المطلوب
const ITEMS = [
  { to: "/", label: "اللوحة", icon: LayoutDashboard },
  { to: "/devices", label: "الأجهزة", icon: Cpu },
  { to: "/analytics", label: "التحليلات", icon: BarChart3 },
  { to: "/spaces", label: "المساحات", icon: Layers },
  { to: "/pricing", label: "الاشتراكات", icon: Crown },
  { to: "/safety", label: "الأمان", icon: Shield },
  { to: "/settings", label: "الإعدادات", icon: Settings },
  { to: "/profile", label: "الملف", icon: UserCircle2 },
];

export function MobileNavDrawer() {
  const [open, setOpen] = useState(false);
  const path = useRouterState({ select: (s) => s.location.pathname });
  const { lang } = useSettings();
  // في وضع RTL نجعل القائمة تنزلق من اليمين (وهو بداية القراءة عربياً)
  const side = lang === "ar" ? "right" : "left";

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger
        aria-label="فتح القائمة"
        className="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-white/10 bg-white/5 text-foreground hover:bg-white/10 transition"
      >
        <Menu className="h-5 w-5" />
      </SheetTrigger>
      <SheetContent
        side={side}
        className="w-[80vw] sm:w-[340px] bg-black text-white border-0 p-0 [&>button]:hidden flex flex-col"
      >
        {/* رأس القائمة: الشعار + زر الإغلاق المُصغّر */}
        <div className="flex items-center justify-between px-5 pt-5 pb-5">
          <div className="flex items-center gap-2.5">
            <img src={brandLogo} alt="SmartEnergy" className="h-8 w-8 object-contain rounded-md bg-white p-0.5" />
            <div className="leading-tight">
              <div className="text-sm font-extrabold">SmartEnergy</div>
              <div className="text-[9px] uppercase tracking-[0.22em] text-white/50">Smarter Future</div>
            </div>
          </div>
          <button
            onClick={() => setOpen(false)}
            aria-label="إغلاق"
            className="grid h-9 w-9 place-items-center rounded-full text-white/80 hover:bg-white/10 transition"
          >
            <X className="h-5 w-5" strokeWidth={1.75} />
          </button>
        </div>

        {/* قائمة الروابط بحجم مدمج واحترافي */}
        <nav className="flex-1 px-2 overflow-y-auto">
          <ul className="flex flex-col gap-0.5">
            {ITEMS.map((it) => {
              // تحديد العنصر النشط حسب المسار الحالي
              const active = path === it.to;
              return (
                <li key={it.to}>
                  <Link
                    to={it.to}
                    onClick={() => setOpen(false)}
                    className={`group flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium tracking-tight transition-all
                      ${active
                        ? "bg-white/10 text-white"
                        : "text-white/70 hover:text-white hover:bg-white/5"
                      }`}
                  >
                    {/* مؤشر أبيض دقيق للحالة النشطة */}
                    <span
                      className={`block h-4 w-[3px] rounded-full transition-all ${
                        active ? "bg-white" : "bg-transparent group-hover:bg-white/30"
                      }`}
                    />
                    <it.icon className="h-5 w-5 opacity-90" strokeWidth={1.75} />
                    <span>{it.label}</span>
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* تذييل القائمة */}
        <div className="px-5 py-4 border-t border-white/10 text-[10px] text-white/40 tracking-wide">
          © {new Date().getFullYear()} SmartEnergy
        </div>
      </SheetContent>
    </Sheet>
  );
}

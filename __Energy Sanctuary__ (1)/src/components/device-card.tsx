// تصميم بطاقات الأجهزة الذكية — على طراز Apple HomeKit / SmartThings
import * as Icons from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Power } from "lucide-react";
import { useStore, type Device } from "@/lib/store";
import { useSettings } from "@/lib/settings";

// خريطة ألوان مميزة لكل نوع جهاز (خلفية ناعمة + لون أيقونة)
const ICON_PALETTE: Record<string, { bg: string; fg: string; ring: string }> = {
  Wind:         { bg: "#EFF6FF", fg: "#2563EB", ring: "#93C5FD" }, // مكيف / مروحة
  Fan:          { bg: "#ECFEFF", fg: "#0891B2", ring: "#67E8F9" },
  Refrigerator: { bg: "#F0FDFA", fg: "#0D9488", ring: "#5EEAD4" },
  Lightbulb:    { bg: "#FFFBEB", fg: "#D97706", ring: "#FCD34D" },
  Tv:           { bg: "#F5F3FF", fg: "#4F46E5", ring: "#C7D2FE" },
  WashingMachine:{ bg: "#EFF6FF", fg: "#1D4ED8", ring: "#93C5FD" },
  Microwave:    { bg: "#FEF2F2", fg: "#DC2626", ring: "#FCA5A5" },
  Flame:        { bg: "#FFF7ED", fg: "#EA580C", ring: "#FDBA74" },
  Server:       { bg: "#F1F5F9", fg: "#334155", ring: "#CBD5E1" },
  Plug:         { bg: "#F8FAFC", fg: "#475569", ring: "#E2E8F0" },
};

// إرجاع الأيقونة المناسبة من مكتبة lucide-react
function getIcon(name: string): LucideIcon {
  const lib = Icons as unknown as Record<string, LucideIcon>;
  return lib[name] ?? Icons.Plug;
}

// مكوّن البطاقة الفاخرة لجهاز واحد
export function DeviceCard({ device }: { device: Device }) {
  const { activeSpace, toggleDevice } = useStore();
  const { t } = useSettings();
  const Icon = getIcon(device.icon);
  const palette = ICON_PALETTE[device.icon] ?? ICON_PALETTE.Plug;

  return (
    <div
      className="relative rounded-3xl bg-white p-5 text-slate-900 transition-all duration-300 animate-fade-up border flex items-center gap-4 dark:bg-slate-900 dark:text-slate-50 dark:border-slate-700"
      style={{
        borderColor: device.on ? palette.ring : "var(--border)",
        boxShadow: device.on
          ? `0 18px 40px -18px ${palette.fg}55, 0 4px 10px -6px ${palette.fg}22`
          : "0 10px 24px -16px rgba(15,23,42,0.18)",
      }}
    >
      {/* الأيقونة الكبيرة بخلفية ملوّنة ناعمة */}
      <div
        className="relative grid h-16 w-16 shrink-0 place-items-center rounded-2xl transition-colors"
        style={{ background: palette.bg, color: palette.fg }}
      >
        <Icon className="h-8 w-8" strokeWidth={1.6} />
        {device.on && (
          <span
            className="absolute -top-1 -right-1 h-3 w-3 rounded-full ring-2 ring-white animate-pulse"
            style={{ background: "#10B981" }}
          />
        )}
      </div>

      {/* اسم الجهاز ومعلومات الريلاي والقدرة */}
      <div className="flex-1 min-w-0">
        <div className="font-bold text-slate-900 truncate dark:text-slate-50">{t(device.name)}</div>
        <div className="text-xs text-slate-500 mt-0.5 dark:text-slate-400">
          {t("common.relay")} {device.relay} · {device.ratedW}W
        </div>
        <div className={`text-[11px] mt-1 font-semibold ${device.on ? "text-emerald-600" : "text-slate-400"}`}>
          {device.on ? "● ON" : "○ OFF"}
        </div>
      </div>

      {/* زر الطاقة الدائري الفاخر — على طراز Apple Home */}
      <button
        type="button"
        onClick={() => toggleDevice(activeSpace.id, device.id)}
        aria-label="Power"
        className="grid h-12 w-12 shrink-0 place-items-center rounded-full transition-all duration-300 active:scale-95"
        style={{
          background: device.on
            ? `linear-gradient(135deg, ${palette.fg}, ${palette.fg}dd)`
            : "var(--secondary)",
          color: device.on ? "#FFFFFF" : "var(--muted-foreground)",
          boxShadow: device.on
            ? `0 10px 24px -8px ${palette.fg}80, inset 0 -2px 4px rgba(0,0,0,0.1)`
            : "inset 0 0 0 1px var(--border)",
        }}
      >
        <Power className="h-5 w-5" strokeWidth={2.2} />
      </button>
    </div>
  );
}

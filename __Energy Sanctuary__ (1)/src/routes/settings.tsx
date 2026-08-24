import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { AppShell } from "@/components/app-shell";
import {
  Sun, Moon, Languages, Bell, Mail, MessageSquare,
  Info, Cpu, Wifi, Palette, BellRing, ShieldCheck,
} from "lucide-react";
import { useSettings } from "@/lib/settings";
import { toast } from "sonner";

export const Route = createFileRoute("/settings")({
  head: () => ({ meta: [{ title: "الإعدادات — SmartEnergy" }] }),
  component: SettingsPage,
});

function SettingsPage() {
  const { theme, lang, setTheme, setLang, t } = useSettings();
  const dark = theme === "dark";
  const [push, setPush] = useState(true);
  const [emailAlerts, setEmailAlerts] = useState(true);
  const [sms, setSms] = useState(false);

  const onTheme = (v: boolean) => {
    setTheme(v ? "dark" : "light");
    toast.success(t("toast.theme"));
  };
  const onLang = (v: "ar" | "en") => {
    if (v === lang) return;
    setLang(v);
    toast.success(t("toast.lang"));
  };
  const onToggle = (set: (v: boolean) => void, v: boolean, label: string) => {
    set(v);
    toast.success(`${label} · ${v ? "ON" : "OFF"}`);
  };

  return (
    <AppShell>
      <div className="max-w-3xl mx-auto space-y-6 animate-fade-up">
        <header className="flex items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl sm:text-3xl font-extrabold gradient-text">{t("settings.title")}</h1>
            <p className="text-sm text-muted-foreground mt-1">{t("settings.subtitle")}</p>
          </div>
          <div className="hidden sm:grid h-12 w-12 place-items-center rounded-2xl glass">
            <ShieldCheck className="h-5 w-5 text-[color:var(--cyan-glow)]" />
          </div>
        </header>

        <Section icon={<Palette className="h-4 w-4" />} title={t("settings.appearance")} desc={t("settings.appearance.desc")}>
          <Row
            icon={dark ? <Moon className="h-4 w-4" /> : <Sun className="h-4 w-4" />}
            label={t("settings.dark")}
            hint={dark ? t("settings.dark.on") : t("settings.dark.off")}
          >
            <Toggle on={dark} onChange={onTheme} />
          </Row>
        </Section>

        <Section icon={<Languages className="h-4 w-4" />} title={t("settings.language")} desc={t("settings.language.desc")}>
          <div className="relative grid grid-cols-2 rounded-2xl bg-white/5 p-1">
            <span
              className="absolute top-1 bottom-1 w-[calc(50%-4px)] rounded-xl bg-gradient-to-br from-[color:var(--cyan-glow)] to-[color:var(--chart-5)] shadow-[0_0_24px_oklch(0.82_0.18_200/0.45)] transition-all duration-500 ease-out"
              style={lang === "ar" ? { right: 4 } : { left: 4 }}
            />
            {([
              { v: "ar", l: "العربية", s: "AR" },
              { v: "en", l: "English", s: "EN" },
            ] as const).map((o) => (
              <button
                key={o.v}
                onClick={() => onLang(o.v)}
                className={`relative z-10 py-2.5 text-sm font-bold rounded-xl transition-colors ${
                  lang === o.v ? "text-background" : "text-muted-foreground hover:text-foreground"
                }`}
              >
                {o.l} <span className="opacity-70 text-xs">· {o.s}</span>
              </button>
            ))}
          </div>
        </Section>

        <Section icon={<BellRing className="h-4 w-4" />} title={t("settings.notifications")} desc={t("settings.notifications.desc")}>
          <Row icon={<Bell className="h-4 w-4" />} label={t("settings.push")} hint={t("settings.push.hint")}>
            <Toggle on={push} onChange={(v) => onToggle(setPush, v, t("settings.push"))} />
          </Row>
          <Row icon={<Mail className="h-4 w-4" />} label={t("settings.email")} hint={t("settings.email.hint")}>
            <Toggle on={emailAlerts} onChange={(v) => onToggle(setEmailAlerts, v, t("settings.email"))} />
          </Row>
          <Row icon={<MessageSquare className="h-4 w-4" />} label={t("settings.sms")} hint={t("settings.sms.hint")}>
            <Toggle on={sms} onChange={(v) => onToggle(setSms, v, t("settings.sms"))} />
          </Row>
        </Section>

        <Section icon={<Info className="h-4 w-4" />} title={t("settings.about")} desc={t("settings.about.desc")}>
          <div className="grid sm:grid-cols-2 gap-3">
            <InfoTile icon={<Info className="h-4 w-4" />} label={t("settings.version")} value="v2.0.0" />
            <InfoTile icon={<Cpu className="h-4 w-4" />} label={t("settings.deviceId")} value="ESP32-LY01" mono />
            <div className="sm:col-span-2 glass rounded-2xl p-4 flex items-center justify-between gap-4 border border-[color:var(--green-glow)]/20">
              <div className="flex items-center gap-3">
                <div className="grid h-10 w-10 place-items-center rounded-xl bg-[color:var(--green-glow)]/10">
                  <Wifi className="h-4 w-4 text-[color:var(--green-glow)]" />
                </div>
                <div>
                  <div className="text-xs text-muted-foreground">{t("settings.firebase")}</div>
                  <div className="font-bold text-[color:var(--green-glow)] text-glow-green">{t("settings.connected")}</div>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <span className="relative flex h-3 w-3">
                  <span className="absolute inline-flex h-full w-full rounded-full bg-[color:var(--green-glow)] opacity-75 animate-ping" />
                  <span className="relative inline-flex h-3 w-3 rounded-full bg-[color:var(--green-glow)] glow-green" />
                </span>
                <span className="text-xs font-semibold text-[color:var(--green-glow)]">Connected</span>
              </div>
            </div>
          </div>
          <p className="text-[10px] text-center text-muted-foreground mt-2 tracking-wider">
            © 2026 SmartEnergy
          </p>
        </Section>
      </div>
    </AppShell>
  );
}

function Section({
  icon, title, desc, children,
}: { icon: React.ReactNode; title: string; desc?: string; children: React.ReactNode }) {
  return (
    <section className="glass rounded-3xl p-5 sm:p-6 animate-fade-up">
      <header className="flex items-center gap-3 mb-4">
        <div className="grid h-9 w-9 place-items-center rounded-xl bg-[color:var(--cyan-glow)]/10 text-[color:var(--cyan-glow)]">
          {icon}
        </div>
        <div>
          <h2 className="font-extrabold">{title}</h2>
          {desc && <p className="text-xs text-muted-foreground">{desc}</p>}
        </div>
      </header>
      <div className="space-y-3">{children}</div>
    </section>
  );
}

function Row({
  icon, label, hint, children,
}: { icon: React.ReactNode; label: string; hint?: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-4 rounded-2xl px-4 py-3 bg-white/[0.03] border border-white/5 hover:border-white/10 transition-colors">
      <div className="flex items-center gap-3 min-w-0">
        <div className="grid h-9 w-9 place-items-center rounded-xl bg-white/5 text-muted-foreground">{icon}</div>
        <div className="min-w-0">
          <div className="text-sm font-semibold truncate">{label}</div>
          {hint && <div className="text-[11px] text-muted-foreground truncate">{hint}</div>}
        </div>
      </div>
      {children}
    </div>
  );
}

function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      onClick={() => onChange(!on)}
      className={`relative h-7 w-12 shrink-0 rounded-full transition-all duration-300 border ${
        on
          ? "bg-gradient-to-r from-[color:var(--cyan-glow)] to-[color:var(--chart-5)] border-transparent shadow-[0_0_20px_oklch(0.82_0.18_200/0.5)]"
          : "bg-white/10 border-white/15"
      }`}
    >
      <span
        className={`absolute top-0.5 h-6 w-6 rounded-full bg-background shadow-md transition-all duration-300 ${
          on ? "right-0.5" : "right-[calc(100%-1.625rem)]"
        }`}
      />
    </button>
  );
}

function InfoTile({
  icon, label, value, mono,
}: { icon: React.ReactNode; label: string; value: string; mono?: boolean }) {
  return (
    <div className="glass rounded-2xl p-4 flex items-center gap-3">
      <div className="grid h-10 w-10 place-items-center rounded-xl bg-white/5 text-[color:var(--cyan-glow)]">{icon}</div>
      <div className="min-w-0">
        <div className="text-xs text-muted-foreground">{label}</div>
        <div className={`font-bold truncate ${mono ? "font-mono tracking-wider" : ""}`}>{value}</div>
      </div>
    </div>
  );
}

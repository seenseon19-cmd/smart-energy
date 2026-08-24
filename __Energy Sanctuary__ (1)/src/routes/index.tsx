import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { PowerGauge } from "@/components/power-gauge";
import { AnimatedNumber } from "@/components/animated-number";
import { DeviceCard } from "@/components/device-card";
import { useStore } from "@/lib/store";
import { useSettings } from "@/lib/settings";
import { Activity, Zap, Gauge, Receipt, TrendingUp } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Area, AreaChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

export const Route = createFileRoute("/")({ component: IndexPage });

function IndexPage() { return <AppShell><Dashboard /></AppShell>; }

function Dashboard() {
  const { activeSpace, live, overload } = useStore();
  const { t, lang } = useSettings();
  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-3 animate-fade-up">
        <div>
          <div className="text-xs uppercase tracking-[0.3em] text-muted-foreground">{t("dash.welcome")}</div>
          <h1 className="text-3xl lg:text-4xl font-extrabold mt-1">{t("dash.title")}</h1>
        </div>
        <div className="text-xs text-muted-foreground inline-flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[color:var(--green-glow)] animate-pulse glow-green" />
          {t("common.live")} · <span className="text-[color:var(--green-glow)]">{t("common.connected")}</span>
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-[auto_1fr] gap-6">
        <div className={`glass rounded-3xl p-8 grid place-items-center animate-pulse-glow ${overload ? "animate-flash-danger" : ""}`}>
          <PowerGauge power={live.power} limit={activeSpace.powerLimit} />
        </div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          <Metric icon={Zap} label={t("dash.voltage")} value={live.voltage} suffix=" V" decimals={1} accent="cyan" />
          <Metric icon={Activity} label={t("dash.current")} value={live.current} suffix=" A" decimals={2} accent="green" />
          <Metric icon={Gauge} label={t("dash.totalEnergy")} value={live.kwh} suffix=" kWh" decimals={2} accent="amber" />
          <Metric icon={Receipt} label={t("dash.bill")} value={live.bill} suffix=" LYD" decimals={2} accent="cyan" />

          <div className="col-span-2 lg:col-span-4 glass rounded-2xl p-5">
            <div className="flex items-center justify-between mb-3">
              <div>
                <div className="text-xs text-muted-foreground">{t("dash.liveConsumption")}</div>
                <div className="text-lg font-bold flex items-center gap-2 mt-1">
                  <TrendingUp className="h-4 w-4 text-[color:var(--cyan-glow)]" />
                  {t("dash.powerCurve")}
                </div>
              </div>
            </div>
            <div className="h-44">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={live.history.map((h) => ({ t: new Date(h.t).toLocaleTimeString(lang === "ar" ? "ar-LY" : "en-US"), w: Math.round(h.w) }))}>
                  <defs>
                    <linearGradient id="liveArea" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor="oklch(0.82 0.18 200)" stopOpacity={0.6} />
                      <stop offset="100%" stopColor="oklch(0.82 0.18 200)" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="t" hide />
                  <YAxis hide domain={[0, "dataMax + 200"]} />
                  <Tooltip contentStyle={{ background: "oklch(0.2 0.04 260 / 0.9)", border: "1px solid oklch(1 0 0 / 0.1)", borderRadius: 12, color: "white" }} />
                  <Area type="monotone" dataKey="w" stroke="oklch(0.82 0.18 200)" strokeWidth={2} fill="url(#liveArea)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>

      <section>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-xl font-bold">{t("dash.activeDevices")}</h2>
          <span className="text-xs text-muted-foreground">
            {activeSpace.devices.filter((d) => d.on).length} / {activeSpace.devices.length} {t("dash.running")}
          </span>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3">
          {activeSpace.devices.map((d) => <DeviceCard key={d.id} device={d} />)}
        </div>
      </section>
    </div>
  );
}

function Metric({
  icon: Icon, label, value, suffix, decimals, accent,
}: { icon: LucideIcon; label: string; value: number; suffix: string; decimals: number; accent: "cyan" | "green" | "amber" }) {
  const color =
    accent === "cyan" ? "var(--cyan-glow)" : accent === "green" ? "var(--green-glow)" : "var(--amber-glow)";
  return (
    <div className="glass rounded-2xl p-5 relative overflow-hidden animate-fade-up">
      <div className="absolute -top-6 -left-6 h-24 w-24 rounded-full opacity-20 blur-2xl" style={{ background: color }} />
      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        <Icon className="h-4 w-4" style={{ color }} />
        {label}
      </div>
      <div className="mt-2 text-2xl font-extrabold tabular-nums" style={{ color }}>
        <AnimatedNumber value={value} decimals={decimals} suffix={suffix} />
      </div>
    </div>
  );
}

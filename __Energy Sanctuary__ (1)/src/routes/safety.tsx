import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useStore } from "@/lib/store";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";
import { Shield, Zap, AlertTriangle, Siren, RotateCcw } from "lucide-react";
import { useEffect, useState } from "react";
import { useSettings } from "@/lib/settings";

export const Route = createFileRoute("/safety")({
  component: () => <AppShell><SafetyPage /></AppShell>,
});

function SafetyPage() {
  const { activeSpace, updateSpace, live, overload, surgeActive, triggerOverload, resetCutoff } = useStore();
  const { t, num, lang } = useSettings();
  const pct = Math.min(150, (live.power / activeSpace.powerLimit) * 100);
  const [shake, setShake] = useState(false);

  useEffect(() => {
    if (surgeActive) {
      setShake(true);
      const t = setTimeout(() => setShake(false), 600);
      return () => clearTimeout(t);
    }
  }, [surgeActive]);

  const danger = overload || surgeActive;

  return (
    <>
      {/* Global red overlay flashing */}
      {danger && (
        <div className="pointer-events-none fixed inset-0 z-40 animate-flash-overlay" />
      )}

      <div className={`space-y-6 max-w-3xl ${shake ? "animate-shake" : ""}`}>
        <div>
          <h1 className="text-3xl font-extrabold">{t("sf.title")}</h1>
          <p className="text-sm text-muted-foreground mt-1">{t("sf.subtitle")}</p>
        </div>

        <div className={`glass rounded-3xl p-8 border ${danger ? "border-[color:var(--red-glow)] animate-flash-danger" : "border-transparent"}`}>
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <div className="grid h-12 w-12 place-items-center rounded-xl bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)]">
                <Zap className="h-6 w-6" />
              </div>
              <div>
                <div className="font-bold">{t("sf.globalLimit")}</div>
                <div className="text-xs text-muted-foreground">{t("sf.maxAllowed")}</div>
              </div>
            </div>
            <div className={`text-3xl font-extrabold tabular-nums ${danger ? "text-[color:var(--red-glow)]" : "text-[color:var(--cyan-glow)]"}`}>
              {num(activeSpace.powerLimit)} <span className="text-sm">W</span>
            </div>
          </div>

          <Slider
            value={[activeSpace.powerLimit]}
            min={1000} max={15000} step={500}
            onValueChange={(v) => updateSpace(activeSpace.id, { powerLimit: v[0] })}
          />

          <div className="mt-6">
            <div className="flex items-center justify-between text-xs text-muted-foreground mb-2">
              <span>{t("sf.currentUse")}: {live.power.toFixed(0)} W</span>
              <span>{pct.toFixed(0)}%</span>
            </div>
            <div className="h-2.5 rounded-full bg-white/5 overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{
                  width: `${Math.min(100, pct)}%`,
                  background: pct > 90 ? "var(--red-glow)" : pct > 70 ? "var(--amber-glow)" : "var(--cyan-glow)",
                  boxShadow: `0 0 20px ${pct > 90 ? "var(--red-glow)" : pct > 70 ? "var(--amber-glow)" : "var(--cyan-glow)"}`,
                }}
              />
            </div>
          </div>
        </div>

        <div className="glass rounded-3xl p-6 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="grid h-12 w-12 place-items-center rounded-xl bg-[color:var(--green-glow)]/15 text-[color:var(--green-glow)]">
              <Shield className="h-6 w-6" />
            </div>
            <div>
              <div className="font-bold">{t("sf.autoCutoff")}</div>
              <div className="text-xs text-muted-foreground">{t("sf.autoCutoffDesc")}</div>
            </div>
          </div>
          <Switch
            checked={activeSpace.autoDisconnect}
            onCheckedChange={(v) => updateSpace(activeSpace.id, { autoDisconnect: v })}
          />
        </div>

        {/* Simulation panel */}
        <div className={`glass rounded-3xl p-6 border ${danger ? "border-[color:var(--red-glow)]/60 animate-flash-danger" : "border-white/5"}`}>
          <div className="flex items-center gap-3 mb-2">
            <div className="grid h-12 w-12 place-items-center rounded-xl bg-[color:var(--red-glow)]/15 text-[color:var(--red-glow)]">
              <Siren className="h-6 w-6" />
            </div>
            <div>
              <div className="font-bold">{t("sf.simTitle")}</div>
              <div className="text-xs text-muted-foreground">{t("sf.simDesc")}</div>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-3 mt-4">
            <Button
              onClick={triggerOverload}
              disabled={surgeActive}
              className="relative overflow-hidden bg-gradient-to-r from-[color:var(--red-glow)] to-amber-500 text-black font-bold hover:opacity-90 disabled:opacity-50"
            >
              <Siren className={`h-4 w-4 ${lang === "ar" ? "ml-2" : "mr-2"}`} />
              {t("sf.trigger")}
              {!surgeActive && (
                <span className="absolute inset-0 -z-10 blur-xl bg-[color:var(--red-glow)]/60 animate-pulse-glow" />
              )}
            </Button>

            <Button
              variant="outline"
              onClick={resetCutoff}
              className="border-white/10 hover:bg-white/5"
            >
              <RotateCcw className={`h-4 w-4 ${lang === "ar" ? "ml-2" : "mr-2"}`} />
              {t("sf.reset")}
            </Button>
          </div>
        </div>

        {danger && (
          <div className="glass rounded-2xl p-5 flex items-start gap-3 border-2 border-[color:var(--red-glow)] animate-flash-danger">
            <AlertTriangle className="h-6 w-6 text-[color:var(--red-glow)] mt-0.5 animate-pulse" />
            <div>
              <div className="font-extrabold text-[color:var(--red-glow)] text-lg">{t("sf.alertTitle")}</div>
              <div className="text-sm text-muted-foreground mt-1">
                ({live.power.toFixed(0)}W) {t("sf.exceeds")} ({activeSpace.powerLimit}W).
                {activeSpace.autoDisconnect ? t("sf.alertCutting") : t("sf.alertHint")}
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
}

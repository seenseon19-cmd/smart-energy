import { AnimatedNumber } from "./animated-number";
import { useSettings } from "@/lib/settings";

export function PowerGauge({ power, limit }: { power: number; limit: number }) {
  const { t, num } = useSettings();
  const pct = Math.max(0, Math.min(1, power / limit));
  const size = 280;
  const stroke = 18;
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const dash = c * 0.75;
  const offset = dash * (1 - pct);

  const danger = pct > 0.9;
  const warn = pct > 0.7;
  const color = danger ? "var(--red-glow)" : warn ? "var(--amber-glow)" : "var(--cyan-glow)";

  return (
    <div className="relative flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-[225deg]">
        <defs>
          <linearGradient id="gaugeGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="oklch(0.82 0.18 200)" />
            <stop offset="50%" stopColor="oklch(0.7 0.2 250)" />
            <stop offset="100%" stopColor={danger ? "oklch(0.7 0.25 25)" : "oklch(0.78 0.2 150)"} />
          </linearGradient>
          <filter id="glow">
            <feGaussianBlur stdDeviation="4" result="b" />
            <feMerge><feMergeNode in="b" /><feMergeNode in="SourceGraphic" /></feMerge>
          </filter>
        </defs>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="oklch(1 0 0 / 0.08)" strokeWidth={stroke} strokeDasharray={`${dash} ${c}`} strokeLinecap="round" />
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="url(#gaugeGrad)" strokeWidth={stroke} strokeDasharray={`${dash} ${c}`} strokeDashoffset={offset} strokeLinecap="round" filter="url(#glow)" style={{ transition: "stroke-dashoffset 0.8s cubic-bezier(.2,.8,.2,1)" }} />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-xs uppercase tracking-[0.3em] text-muted-foreground">{t("dash.powerNow")}</span>
        <div className="mt-2 flex items-baseline gap-2">
          <AnimatedNumber value={power} decimals={0} className="text-6xl font-extrabold tabular-nums text-glow-cyan" />
          <span className="text-xl font-semibold" style={{ color }}>W</span>
        </div>
        <span className="mt-2 text-xs text-muted-foreground">
          {t("dash.limit")}: <span className="text-foreground/80">{num(limit)} W</span>
        </span>
        <span className="mt-3 inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium"
          style={{ background: `color-mix(in oklab, ${color} 18%, transparent)`, color, boxShadow: `0 0 20px color-mix(in oklab, ${color} 30%, transparent)` }}>
          <span className="h-1.5 w-1.5 rounded-full animate-pulse" style={{ background: color }} />
          {danger ? t("common.overload") : warn ? t("common.warning") : t("common.safe")}
        </span>
      </div>
    </div>
  );
}

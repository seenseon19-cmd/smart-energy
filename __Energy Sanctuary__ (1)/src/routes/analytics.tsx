import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useStore } from "@/lib/store";
import { useEffect, useMemo, useState, type CSSProperties } from "react";
import { createPortal } from "react-dom";
import {
  Area, AreaChart, Bar, BarChart, Cell, Pie, PieChart,
  ResponsiveContainer, Tooltip, XAxis, YAxis, CartesianGrid, Legend,
} from "recharts";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Download, TrendingUp, TrendingDown, Zap, Receipt,
  Activity, FileText, Sparkles,
  type LucideIcon,
} from "lucide-react";
import { toast } from "sonner";
import { AnimatedNumber } from "@/components/animated-number";
import { useSettings } from "@/lib/settings";
// شعار الشركة لإدراجه أعلى الفاتورة
import brandLogo from "@/assets/smart-energy-logo.webp";
// قراءة بيانات المشترك (الاسم، العنوان، رقم الحساب، الرقم الضريبي) لطباعتها على الفاتورة
import { useProfile } from "@/lib/profile";

export const Route = createFileRoute("/analytics")({
  component: () => <AppShell><AnalyticsPage /></AppShell>,
});

const COLORS = [
  "oklch(0.82 0.18 200)",
  "oklch(0.78 0.2 150)",
  "oklch(0.82 0.18 75)",
  "oklch(0.7 0.25 25)",
  "oklch(0.7 0.2 300)",
  "oklch(0.75 0.15 250)",
];

type Range = "daily" | "weekly" | "monthly";

const TOOLTIP_STYLE = {
  background: "oklch(0.2 0.04 260 / 0.95)",
  border: "1px solid oklch(0.82 0.18 200 / 0.3)",
  borderRadius: 12,
  color: "white",
  boxShadow: "0 8px 32px oklch(0 0 0 / 0.4)",
  fontFamily: "Cairo, sans-serif",
};

function AnalyticsPage() {
  const { activeSpace, live } = useStore();
  const { t, lang } = useSettings();
  const isAr = lang === "ar";
  // بيانات المشترك المحفوظة محلياً — لطباعتها على الفاتورة
  const profile = useProfile(isAr);
  const [range, setRange] = useState<Range>("weekly");
  const [generating, setGenerating] = useState(false);
  const [pdfDateStr, setPdfDateStr] = useState("");
  const [printReady, setPrintReady] = useState(false);

  // تجهيز حاوية الطباعة كعنصر مباشر داخل body حتى لا تُخفيها قواعد إخفاء التطبيق أثناء الطباعة
  useEffect(() => {
    setPrintReady(true);
  }, []);

  // Pie distribution: realistic shares per device
  const pie = useMemo(() => {
    return activeSpace.devices
      .map((d, i) => ({
        name: t(d.name),
        value: Math.round(d.ratedW * (d.on ? 1 : 0.08) * (1 + (i % 3) * 0.15)),
        color: COLORS[i % COLORS.length],
      }))
      .filter((x) => x.value > 0)
      .sort((a, b) => b.value - a.value);
  }, [activeSpace.devices, t]);

  const totalW = pie.reduce((s, p) => s + p.value, 0) || 1;

  // مولّد قيم حتمي (بدون عشوائية) لتفادي خطأ Hydration بين SSR والعميل
  const seeded = (i: number) => ((Math.sin(i * 9301 + 49297) + 1) / 2);

  // سلسلة بيانات الاستهلاك حسب النطاق المختار
  const series = useMemo(() => {
    if (range === "daily") {
      return Array.from({ length: 24 }, (_, i) => ({
        label: `${i}:00`,
        kwh: +(0.4 + seeded(i + 1) * 1.8 + (i > 17 || i < 6 ? 0.6 : 0)).toFixed(2),
        bill: 0,
      })).map((d) => ({ ...d, bill: +(d.kwh * 0.045).toFixed(2) }));
    }
    if (range === "weekly") {
      return (["day.sun","day.mon","day.tue","day.wed","day.thu","day.fri","day.sat"]).map((k, i) => {
        const kwh = +(8 + seeded(i + 11) * 14).toFixed(1);
        return { label: t(k), kwh, bill: +(kwh * 0.045).toFixed(2) };
      });
    }
    return Array.from({ length: 12 }, (_, i) => {
      const kwh = +(180 + seeded(i + 21) * 220).toFixed(0);
      return {
        label: t(`mon.${i + 1}`),
        kwh,
        bill: +(kwh * 0.045).toFixed(1),
      };
    });
  }, [range, t]);

  const totalKwh = series.reduce((s, x) => s + x.kwh, 0);
  const totalBill = series.reduce((s, x) => s + x.bill, 0);
  const avgKwh = totalKwh / series.length;
  const peak = series.reduce((m, x) => (x.kwh > m.kwh ? x : m), series[0]);
  const trend = series.length > 1
    ? ((series[series.length - 1].kwh - series[0].kwh) / Math.max(series[0].kwh, 0.01)) * 100
    : 0;

  // تسميات الفاتورة المبسّطة (فاتورة كهرباء رسمية)
  const pdfTitleStr = isAr ? "فاتورة استهلاك الكهرباء" : "Electricity Utility Bill";
  const inv = isAr
    ? { subscriber: "اسم المشترك", address: "عنوان المشترك", account: "رقم الحساب",
        taxId: "الرقم الضريبي", invDate: "تاريخ الفاتورة", invAmount: "قيمة الفاتورة",
        total: "إجمالي الطاقة", avg: "المتوسط", peak: "الذروة",
        unitKwh: "ك.و.س", unitLyd: "د.ل", title: pdfTitleStr,
        billNo: "رقم الفاتورة", thanks: "شكراً لاستخدامكم سمارت إنرجي" }
    : { subscriber: "Subscriber Name", address: "Subscriber Address", account: "Account Number",
        taxId: "Tax ID", invDate: "Invoice Date", invAmount: "Invoice Amount",
        total: "Total Energy", avg: "Average", peak: "Peak",
        unitKwh: "kWh", unitLyd: "LYD", title: pdfTitleStr,
        billNo: "Invoice No.", thanks: "Thank you for using SmartEnergy" };

  // دالة استخراج الـ PDF المحسنة: تطبع حاوية HTML بسيطة عالية التباين فقط لتفادي تعارضات CSS والـ Dark Mode
  const generatePdf = () => {
    if (generating) return;
    try {
      if (!activeSpace || !Array.isArray(activeSpace.devices) || !Array.isArray(series) || series.length === 0) {
        toast.error(t("an.pdfFail"));
        return;
      }

      const generatedAt = new Date().toLocaleString(isAr ? "ar-LY" : "en-GB");
      setGenerating(true);
      setPdfDateStr(generatedAt);

      requestAnimationFrame(() => {
        window.print();
        setGenerating(false);
        toast.success(t("an.pdfDone"));
      });
    } catch (e) {
      console.error("Print trigger failed:", e);
      setGenerating(false);
      toast.error(t("an.pdfFail"));
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 animate-fade-up">
        <div>
          <div className="text-xs uppercase tracking-[0.3em] text-[color:var(--cyan-glow)]">{t("an.kicker")}</div>
          <h1 className="text-3xl lg:text-4xl font-extrabold mt-2">{t("an.title")}</h1>
          <p className="text-sm text-muted-foreground mt-1">
            {t("an.subtitle")} "{t(activeSpace.name)}"
          </p>
        </div>

        <button
          onClick={generatePdf}
          disabled={generating}
          className="group relative inline-flex items-center justify-center gap-3 rounded-2xl px-6 py-4 font-bold text-background overflow-hidden disabled:opacity-60 disabled:cursor-not-allowed"
        >
          <span className="absolute inset-0 bg-gradient-to-r from-[color:var(--amber-glow)] via-[color:var(--cyan-glow)] to-[color:var(--chart-5)] opacity-100 group-hover:opacity-90 transition" />
          <span className="absolute inset-0 blur-xl bg-gradient-to-r from-[color:var(--amber-glow)] to-[color:var(--cyan-glow)] opacity-50 group-hover:opacity-80 transition" />
          <span className="relative flex items-center gap-2">
            {generating ? (
              <><Sparkles className="h-5 w-5 animate-spin" /> {t("an.generating")}</>
            ) : (
              <><FileText className="h-5 w-5" /> {t("an.genPdf")} <Download className="h-4 w-4" /></>
            )}
          </span>
        </button>
      </div>

      {/* KPI strip */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Kpi icon={Zap} accent="cyan" label={t("an.totalEnergy")} value={totalKwh} suffix=" kWh" decimals={1} />
        <Kpi icon={Receipt} accent="green" label={t("an.estBill")} value={totalBill} suffix=" LYD" decimals={2} />
        <Kpi icon={Activity} accent="amber" label={t("an.average")} value={avgKwh} suffix=" kWh" decimals={2} />
        <Kpi
          icon={trend >= 0 ? TrendingUp : TrendingDown}
          accent={trend >= 0 ? "red" : "green"}
          label={t("an.trend")}
          value={Math.abs(trend)}
          suffix="%"
          decimals={1}
          prefix={trend >= 0 ? "+" : "−"}
        />
      </div>

      {/* Range tabs */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <h2 className="text-xl font-bold">{t("an.curve")}</h2>
        <Tabs value={range} onValueChange={(v) => setRange(v as Range)}>
          <TabsList className="glass">
            <TabsTrigger value="daily">{t("an.daily")}</TabsTrigger>
            <TabsTrigger value="weekly">{t("an.weekly")}</TabsTrigger>
            <TabsTrigger value="monthly">{t("an.monthly")}</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* Area chart */}
      <div className="glass rounded-3xl p-5 lg:p-6 animate-fade-up" key={range}>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={series} margin={{ top: 10, right: 16, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id="kwhArea" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="oklch(0.82 0.18 200)" stopOpacity={0.7} />
                  <stop offset="100%" stopColor="oklch(0.82 0.18 200)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="oklch(1 0 0 / 0.05)" />
              <XAxis dataKey="label" stroke="oklch(0.72 0.03 250)" tick={{ fontSize: 11 }} />
              <YAxis stroke="oklch(0.72 0.03 250)" tick={{ fontSize: 11 }} />
              <Tooltip contentStyle={TOOLTIP_STYLE} />
              <Area
                type="monotone"
                dataKey="kwh"
                name="kWh"
                stroke="oklch(0.82 0.18 200)"
                strokeWidth={2.5}
                fill="url(#kwhArea)"
                animationDuration={1100}
                animationEasing="ease-out"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Pie + Bar */}
      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        <div className="glass rounded-3xl p-6 lg:col-span-2 animate-fade-up">
          <h3 className="font-bold mb-1">{t("an.distribution")}</h3>
          <p className="text-xs text-muted-foreground mb-4">{t("an.byDevice")}</p>
          <div className="h-64 relative">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={pie}
                  dataKey="value"
                  nameKey="name"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={3}
                  animationDuration={1100}
                  animationEasing="ease-out"
                >
                  {pie.map((p, i) => <Cell key={i} fill={p.color} stroke="oklch(0.16 0.04 260)" strokeWidth={2} />)}
                </Pie>
                <Tooltip contentStyle={TOOLTIP_STYLE} formatter={(v: number) => `${v} W`} />
              </PieChart>
            </ResponsiveContainer>
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <div className="text-2xl font-extrabold text-glow-cyan">{totalW}</div>
              <div className="text-[10px] uppercase tracking-widest text-muted-foreground">{t("an.totalW")}</div>
            </div>
          </div>

          <div className="mt-4 space-y-1.5 max-h-40 overflow-auto pr-1">
            {pie.map((p) => (
              <div key={p.name} className="flex items-center gap-2 text-xs">
                <span className="h-2.5 w-2.5 rounded-full" style={{ background: p.color }} />
                <span className="flex-1 truncate">{p.name}</span>
                <span className="tabular-nums text-muted-foreground">{((p.value / totalW) * 100).toFixed(1)}%</span>
                <span className="tabular-nums w-14 text-left text-foreground/90">{p.value}W</span>
              </div>
            ))}
          </div>
        </div>

        <div className="glass rounded-3xl p-6 lg:col-span-3 animate-fade-up">
          <div className="flex items-baseline justify-between">
            <div>
              <h3 className="font-bold">{t("an.consBill")}</h3>
              <p className="text-xs text-muted-foreground">{t("an.kwhVsLyd")}</p>
            </div>
            <div className="text-xs text-muted-foreground">{t("an.peak")}: <b className="text-[color:var(--amber-glow)]">{peak.label}</b></div>
          </div>
          <div className="h-64 mt-3">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={series} margin={{ top: 10, right: 8, left: 0, bottom: 0 }}>
                <defs>
                  <linearGradient id="barKwh" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="oklch(0.82 0.18 200)" />
                    <stop offset="100%" stopColor="oklch(0.7 0.2 250)" />
                  </linearGradient>
                  <linearGradient id="barBill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="oklch(0.82 0.18 75)" />
                    <stop offset="100%" stopColor="oklch(0.7 0.25 25)" />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="oklch(1 0 0 / 0.05)" />
                <XAxis dataKey="label" stroke="oklch(0.72 0.03 250)" tick={{ fontSize: 11 }} />
                <YAxis stroke="oklch(0.72 0.03 250)" tick={{ fontSize: 11 }} />
                <Tooltip contentStyle={TOOLTIP_STYLE} />
                <Legend wrapperStyle={{ fontSize: 12 }} />
                <Bar dataKey="kwh" name="kWh" fill="url(#barKwh)" radius={[8, 8, 0, 0]} animationDuration={1100} />
                <Bar dataKey="bill" name="LYD" fill="url(#barBill)" radius={[8, 8, 0, 0]} animationDuration={1300} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Top consumers leaderboard */}
      <div className="glass rounded-3xl p-6 animate-fade-up">
        <h3 className="font-bold mb-4">{t("an.topConsumers")}</h3>
        <div className="space-y-3">
          {pie.slice(0, 5).map((p, i) => {
            const pct = (p.value / pie[0].value) * 100;
            return (
              <div key={p.name} className="flex items-center gap-3">
                <div className="grid h-8 w-8 place-items-center rounded-lg bg-white/5 text-xs font-bold tabular-nums" style={{ color: p.color }}>
                  #{i + 1}
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between text-sm">
                    <span className="font-medium">{p.name}</span>
                    <span className="tabular-nums text-muted-foreground">{p.value} W · {((p.value / totalW) * 100).toFixed(1)}%</span>
                  </div>
                  <div className="mt-1.5 h-1.5 rounded-full bg-white/5 overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-1000"
                      style={{
                        width: `${pct}%`,
                        background: p.color,
                        boxShadow: `0 0 14px ${p.color}`,
                      }}
                    />
                  </div>
                </div>
              </div>
            );
          })}
          {pie.length === 0 && (
            <div className="text-center text-muted-foreground py-6">{t("an.noActive")}</div>
          )}
        </div>
      </div>

      {/* Live note */}
      <div className="text-xs text-muted-foreground text-center">
        {t("an.liveNow")}: {live.power.toFixed(0)} W · {live.voltage.toFixed(1)} V
      </div>

      {/* منطقة الفاتورة - تصميم احترافي على صفحة A4 واحدة (أفقي + شبكة) */}
      {printReady && createPortal(
        <div
          id="printable-report-content"
          dir={isAr ? "rtl" : "ltr"}
          style={{
            display: "none",
            width: "210mm",
            minHeight: "297mm",
            margin: "0 auto",
            background: "#ffffff",
            color: "#0F172A",
            fontFamily: "Cairo, Tajawal, Helvetica Neue, Arial, sans-serif",
            padding: "10mm 12mm",
            boxSizing: "border-box",
            fontSize: 11,
            lineHeight: 1.4,
          }}
        >
          {/* ==== الرأس: شعار يمين | عنوان وسط | رقم الفاتورة وتاريخها يسار ==== */}
          <div className="print-avoid-break" style={{ display: "flex", alignItems: "center", justifyContent: "space-between", paddingBottom: 10, borderBottom: "2px solid #2563EB" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, minWidth: 180 }}>
              <img src={brandLogo} alt="SmartEnergy" style={{ width: 64, height: 64, objectFit: "contain" }} />
              <div>
                <div style={{ fontSize: 16, fontWeight: 900, color: "#2563EB", letterSpacing: 0.3 }}>SmartEnergy</div>
                <div style={{ fontSize: 8, color: "#F97316", letterSpacing: 2, fontWeight: 700, textTransform: "uppercase" }}>Smarter Energy</div>
              </div>
            </div>
            <div style={{ flex: 1, textAlign: "center" }}>
              <h1 style={{ fontSize: 20, fontWeight: 900, color: "#0F172A", margin: 0 }}>{inv.title}</h1>
              <div style={{ fontSize: 9, color: "#64748B", marginTop: 2, letterSpacing: 1 }}>OFFICIAL ELECTRICITY UTILITY BILL</div>
            </div>
            <div style={{ minWidth: 180, textAlign: isAr ? "left" : "right", fontSize: 10, color: "#475569", lineHeight: 1.7 }}>
              <div><b style={{ color: "#0F172A" }}>{inv.billNo}:</b> <span dir="ltr" style={{ color: "#2563EB", fontWeight: 700 }}>{`SE-${Date.now().toString().slice(-8)}`}</span></div>
              <div><b style={{ color: "#0F172A" }}>{inv.invDate}:</b> {pdfDateStr || "—"}</div>
            </div>
          </div>

          {/* ==== القسم 1: بيانات المشترك (شبكة أفقية: تسمية : قيمة) ==== */}
          <div className="print-avoid-break" style={{ marginTop: 14 }}>
            <div style={{ background: "#EBF2FF", color: "#1E40AF", padding: "6px 12px", fontSize: 11, fontWeight: 800, letterSpacing: 2, textTransform: "uppercase", borderRadius: "6px 6px 0 0", border: "1px solid #BFDBFE", borderBottom: "none" }}>
              {isAr ? "بيانات المشترك" : "Subscriber Information"}
            </div>
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 11, border: "1px solid #BFDBFE", borderRadius: "0 0 6px 6px", overflow: "hidden" }}>
              <tbody>
                <tr>
                  <td style={lblCell}>{inv.subscriber}</td>
                  <td style={valCell}>{profile.firstName} {profile.lastName}</td>
                  <td style={lblCell}>{inv.account}</td>
                  <td style={{ ...valCell, color: "#2563EB", fontWeight: 800 }} dir="ltr">{profile.accountNumber}</td>
                </tr>
                <tr>
                  <td style={lblCell}>{inv.address}</td>
                  <td style={valCell}>{profile.address || profile.city || "—"}</td>
                  <td style={lblCell}>{inv.taxId}</td>
                  <td style={valCell} dir="ltr">{(profile.accountKind === "commercial" && profile.taxId) ? profile.taxId : "—"}</td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* ==== القسم 2: بيانات الفاتورة (شبكة أفقية) ==== */}
          <div className="print-avoid-break" style={{ marginTop: 12 }}>
            <div style={{ background: "#FFF7ED", color: "#C2410C", padding: "6px 12px", fontSize: 11, fontWeight: 800, letterSpacing: 2, textTransform: "uppercase", borderRadius: "6px 6px 0 0", border: "1px solid #FED7AA", borderBottom: "none" }}>
              {isAr ? "بيانات الاستهلاك والفاتورة" : "Billing & Consumption"}
            </div>
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 11, border: "1px solid #FED7AA", borderRadius: "0 0 6px 6px", overflow: "hidden" }}>
              <tbody>
                <tr>
                  <td style={lblCell}>{inv.invDate}</td>
                  <td style={valCell}>{pdfDateStr || "—"}</td>
                  <td style={lblCell}>{inv.total}</td>
                  <td style={valCell}><b>{totalKwh.toFixed(1)}</b> {inv.unitKwh}</td>
                </tr>
                <tr>
                  <td style={lblCell}>{inv.avg}</td>
                  <td style={valCell}><b>{avgKwh.toFixed(2)}</b> {inv.unitKwh}</td>
                  <td style={lblCell}>{inv.peak}</td>
                  <td style={valCell}><b>{peak.kwh.toFixed(1)}</b> {inv.unitKwh} <span style={{ color: "#94A3B8" }}>({peak.label})</span></td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* ==== صندوق المبلغ الإجمالي - بارز ومميز ==== */}
          <div className="print-avoid-break" style={{ marginTop: 16, background: "linear-gradient(135deg, #2563EB 0%, #1D4ED8 100%)", borderRadius: 12, padding: "18px 24px", color: "#FFFFFF", display: "flex", alignItems: "center", justifyContent: "space-between", boxShadow: "0 4px 12px rgba(37,99,235,0.25)" }}>
            <div>
              <div style={{ fontSize: 11, color: "#DBEAFE", letterSpacing: 3, textTransform: "uppercase", fontWeight: 700 }}>{inv.invAmount}</div>
              <div style={{ fontSize: 36, fontWeight: 900, marginTop: 2, lineHeight: 1 }}>
                {totalBill.toFixed(2)} <span style={{ fontSize: 16, color: "#FED7AA" }}>{inv.unitLyd}</span>
              </div>
            </div>
            <div style={{ textAlign: isAr ? "left" : "right", fontSize: 10, color: "#DBEAFE", lineHeight: 1.8 }}>
              <div>{isAr ? "السعر للوحدة" : "Unit Price"}: <b style={{ color: "#FFFFFF" }}>0.045 {inv.unitLyd}/{inv.unitKwh}</b></div>
              <div>{isAr ? "حالة الدفع" : "Status"}: <b style={{ color: "#FED7AA" }}>{isAr ? "غير مدفوعة" : "UNPAID"}</b></div>
            </div>
          </div>

          {/* ==== التذييل ==== */}
          <div style={{ marginTop: 18, paddingTop: 10, borderTop: "1px solid #E2E8F0", textAlign: "center", fontSize: 9.5, color: "#64748B", lineHeight: 1.7 }}>
            <div style={{ color: "#F97316", fontWeight: 700, fontSize: 11 }}>{inv.thanks}</div>
            <div style={{ marginTop: 4 }}>
              <span style={{ color: "#0F172A", fontWeight: 700 }}>Email:</span> SOUHAYLSAAID@GMAIL.COM
              <span style={{ margin: "0 10px", color: "#CBD5E1" }}>|</span>
              <span style={{ color: "#0F172A", fontWeight: 700 }}>Tel:</span> +218 91 577 5774
            </div>
            <div style={{ marginTop: 2, color: "#94A3B8", fontSize: 9 }}>SmartEnergy IoT © 2026 — All Rights Reserved</div>
          </div>
        </div>,
        document.body,
      )}
    </div>
  );
}

// أنماط خلايا الجدول - تسمية رمادية فاتحة + قيمة بارزة
const lblCell: CSSProperties = {
  background: "#F8FAFC",
  color: "#475569",
  fontWeight: 700,
  fontSize: 10,
  padding: "8px 10px",
  width: "18%",
  borderBottom: "1px solid #E2E8F0",
  borderInlineEnd: "1px solid #E2E8F0",
  whiteSpace: "nowrap",
};
const valCell: CSSProperties = {
  color: "#0F172A",
  fontWeight: 600,
  fontSize: 11,
  padding: "8px 12px",
  width: "32%",
  borderBottom: "1px solid #E2E8F0",
  borderInlineEnd: "1px solid #E2E8F0",
};

function Kpi({
  icon: Icon, accent, label, value, suffix, decimals, prefix,
}: {
  icon: LucideIcon; accent: "cyan" | "green" | "amber" | "red";
  label: string; value: number; suffix: string; decimals: number; prefix?: string;
}) {
  const color = {
    cyan: "var(--cyan-glow)", green: "var(--green-glow)",
    amber: "var(--amber-glow)", red: "var(--red-glow)",
  }[accent];
  return (
    <div className="relative glass rounded-2xl p-5 overflow-hidden animate-fade-up">
      <div className="absolute -top-8 -left-8 h-24 w-24 rounded-full opacity-25 blur-2xl" style={{ background: color }} />
      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        <Icon className="h-4 w-4" style={{ color }} />
        {label}
      </div>
      <div className="mt-2 text-2xl font-extrabold tabular-nums" style={{ color }}>
        {prefix}<AnimatedNumber value={value} decimals={decimals} suffix={suffix} />
      </div>
    </div>
  );
}

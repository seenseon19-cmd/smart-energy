// =====================================================================
//  صفحة المصادقة (تسجيل الدخول / إنشاء الحساب)
//  - تدعم الدخول بالبريد أو الهاتف مع رمز تحقق OTP.
//  - تتحقق من صحة المدخلات عبر Zod وتنقّيها لمنع XSS.
//  - جاهزة للربط مع Firebase Authentication عبر مغلِّفات firebaseAuth.
// =====================================================================
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useState, useRef, useEffect } from "react";
import { Zap, Phone, Mail, Lock, User, ArrowLeft, Shield, Eye, EyeOff, Loader2, CheckCircle2 } from "lucide-react";
import { toast } from "sonner";
import { useSettings } from "@/lib/settings";
// مغلِّفات Firebase الجاهزة للربط لاحقاً
import { signInWithEmail, signUpWithEmail, sendOtp, verifyOtp } from "@/lib/firebaseAuth";
// مخططات التحقق ودوال التنقية
// شعار الشركة الرسمي
import brandLogo from "@/assets/smart-energy-logo.webp";
import {
  emailSchema,
  passwordSchema,
  phoneSchema,
  otpSchema,
  nameSchema,
  sanitizeText,
  sanitizePhone,
} from "@/lib/validation";

export const Route = createFileRoute("/auth")({
  component: AuthPage,
});

// أوضاع الشاشة: تسجيل دخول أو إنشاء حساب
type Mode = "login" | "signup";
// طريقة المصادقة: عبر الهاتف أو البريد
type Method = "phone" | "email";

// المكوّن الرئيسي لصفحة المصادقة
function AuthPage() {
  const navigate = useNavigate();
  const { t } = useSettings();
  const [mode, setMode] = useState<Mode>("login");
  const [method, setMethod] = useState<Method>("phone");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [showPwd, setShowPwd] = useState(false);
  const [loading, setLoading] = useState(false);
  const [otpStage, setOtpStage] = useState(false);
  const [otp, setOtp] = useState(["", "", "", "", "", ""]);
  const otpRefs = useRef<(HTMLInputElement | null)[]>([]);

  const reset = () => {
    setOtpStage(false);
    setOtp(["", "", "", "", "", ""]);
    setLoading(false);
  };

  useEffect(() => { reset(); }, [mode, method]);

  // معالج إرسال النموذج — يتحقق من المدخلات ثم يستدعي Firebase
  const submit = async (e: React.FormEvent) => {
    e.preventDefault();

    // مسار تسجيل الدخول بالهاتف — إرسال OTP
    if (method === "phone" && mode === "login") {
      const cleanPhone = sanitizePhone(phone);
      const parsed = phoneSchema.safeParse(cleanPhone);
      if (!parsed.success) return toast.error(parsed.error.issues[0]?.message ?? t("au.errPhone"));
      setLoading(true);
      // استدعاء مغلِّف Firebase لإرسال رمز التحقق
      const res = await sendOtp(`+218${cleanPhone}`);
      setLoading(false);
      if (!res.success) return toast.error(res.message ?? "Failed");
      setOtpStage(true);
      toast.success(t("au.otpSent"), { description: t("au.otpDemo") });
      return;
    }

    // التحقق من اسم المستخدم في حالة إنشاء حساب
    if (mode === "signup") {
      const cleanName = sanitizeText(name);
      const parsed = nameSchema.safeParse(cleanName);
      if (!parsed.success) return toast.error(parsed.error.issues[0]?.message ?? t("au.errName"));
    }

    // التحقق من البريد وكلمة المرور
    if (method === "email") {
      const cleanEmail = sanitizeText(email);
      const eParsed = emailSchema.safeParse(cleanEmail);
      if (!eParsed.success) return toast.error(eParsed.error.issues[0]?.message ?? t("au.errFields"));
      const pParsed = passwordSchema.safeParse(password);
      if (!pParsed.success) return toast.error(pParsed.error.issues[0]?.message ?? t("au.errFields"));
    }

    setLoading(true);
    // استدعاء مغلِّف Firebase المناسب
    const res = mode === "login"
      ? await signInWithEmail(sanitizeText(email), password)
      : await signUpWithEmail(sanitizeText(email), password, sanitizeText(name));
    setLoading(false);

    if (!res.success) return toast.error(res.message ?? "Auth failed");
    toast.success(mode === "login" ? t("au.welcomeBackToast") : t("au.accountCreated"));
    // عرض اللافتة الترويجية مرة واحدة بعد تسجيل الدخول
    sessionStorage.setItem("show_promo", "1");
    navigate({ to: "/" });
  };

  // معالج إدخال خانات رمز OTP — يتحقق ويستدعي Firebase عند اكتماله
  const onOtpChange = (i: number, v: string) => {
    const d = v.replace(/\D/g, "").slice(-1); // رقم واحد فقط لكل خانة
    const next = [...otp];
    next[i] = d;
    setOtp(next);
    if (d && i < 5) otpRefs.current[i + 1]?.focus();
    if (next.every((c) => c)) {
      const code = next.join("");
      const parsed = otpSchema.safeParse(code);
      if (!parsed.success) return toast.error(parsed.error.issues[0]?.message ?? "OTP");
      setLoading(true);
      // استدعاء مغلِّف Firebase للتحقق من رمز OTP
      verifyOtp(code).then((res) => {
        setLoading(false);
        if (!res.success) return toast.error(res.message ?? "Invalid OTP");
        toast.success(t("au.otpVerified"));
        sessionStorage.setItem("show_promo", "1");
        navigate({ to: "/" });
      });
    }
  };

  return (
    <div className="relative min-h-screen w-full overflow-hidden flex items-center justify-center px-4 py-10">
      {/* Animated background orbs */}
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-32 h-[420px] w-[420px] rounded-full bg-[color:var(--cyan-glow)]/25 blur-[120px] animate-float" />
        <div className="absolute -bottom-40 -left-32 h-[460px] w-[460px] rounded-full bg-[color:var(--chart-5)]/25 blur-[140px] animate-float" style={{ animationDelay: "1.5s" }} />
        <div className="absolute top-1/2 left-1/3 h-[300px] w-[300px] rounded-full bg-[color:var(--chart-2)]/15 blur-[120px] animate-float" style={{ animationDelay: "0.8s" }} />
        <div
          className="absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage:
              "linear-gradient(oklch(1 0 0 / 1) 1px, transparent 1px), linear-gradient(90deg, oklch(1 0 0 / 1) 1px, transparent 1px)",
            backgroundSize: "44px 44px",
            maskImage: "radial-gradient(ellipse at center, black 40%, transparent 75%)",
          }}
        />
      </div>

      <div className="relative w-full max-w-md animate-fade-up">
        {/* Brand */}
        <div className="flex flex-col items-center gap-3 mb-6">
          {/* الشعار الرسمي للشركة */}
          <div className="relative grid h-20 w-20 place-items-center rounded-2xl bg-white shadow-[0_10px_40px_-10px_rgba(37,99,235,0.55)] animate-pulse-glow p-2">
            <img src={brandLogo} alt="SmartEnergy" className="h-full w-full object-contain" />
            <div className="absolute -bottom-1 -left-1 grid h-6 w-6 place-items-center rounded-full bg-background border border-[color:var(--cyan-glow)]/40">
              <Shield className="h-3 w-3 text-[color:var(--cyan-glow)]" />
            </div>
          </div>
          <div className="text-center">
            <h1 className="text-2xl font-extrabold gradient-text">SmartEnergy</h1>
            <p className="text-xs text-muted-foreground tracking-[0.2em] uppercase mt-0.5">Secure Gateway</p>
          </div>
        </div>

        {/* Card */}
        <div className="glass-strong rounded-3xl p-6 sm:p-7 relative overflow-hidden">
          <div className="absolute inset-x-0 -top-px h-px bg-gradient-to-r from-transparent via-[color:var(--cyan-glow)] to-transparent" />

          {/* مبدّل الوضع — حبة فاخرة مع توهج خاص لزر "إنشاء حساب" (مستخدم جديد) */}
          <div className="relative grid grid-cols-2 rounded-full bg-white/5 p-1 mb-6 border border-white/10">
            <span
              className={`absolute top-1 bottom-1 w-[calc(50%-4px)] rounded-full transition-all duration-500 ease-out ${
                mode === "signup"
                  ? "bg-gradient-to-r from-orange-400 via-amber-300 to-orange-400 shadow-[0_0_28px_rgba(251,146,60,0.65)]"
                  : "bg-gradient-to-br from-[color:var(--cyan-glow)] to-[color:var(--chart-5)] shadow-[0_0_24px_oklch(0.82_0.18_200/0.45)]"
              }`}
              style={{ transform: mode === "login" ? "translateX(0)" : "translateX(-100%)", right: 4 }}
            />
            {(["login", "signup"] as Mode[]).map((m) => (
              <button
                key={m}
                type="button"
                onClick={() => setMode(m)}
                className={`relative z-10 py-2.5 text-sm font-bold rounded-full transition-colors duration-300 inline-flex items-center justify-center gap-1.5 ${
                  mode === m ? "text-background" : "text-muted-foreground hover:text-foreground"
                }`}
              >
                {m === "signup" && mode === "signup" && <span className="h-1.5 w-1.5 rounded-full bg-white animate-pulse" />}
                {m === "login" ? t("au.login") : t("au.signup")}
              </button>
            ))}
          </div>

          <div className="relative">
            <div
              key={mode}
              className="animate-fade-up"
              style={{ animationDuration: "0.35s" }}
            >
              <div className="mb-5">
                <h2 className="text-xl font-extrabold">
                  {mode === "login" ? t("au.welcomeBack") : t("au.startJourney")}
                </h2>
                <p className="text-xs text-muted-foreground mt-1">
                  {mode === "login" ? t("au.loginHint") : t("au.signupHint")}
                </p>
              </div>

              {/* Method selector */}
              <div className="flex gap-2 mb-5 p-1 rounded-2xl bg-white/[0.03] border border-white/5">
                {(["phone", "email"] as Method[]).map((mt) => (
                  <button
                    key={mt}
                    type="button"
                    onClick={() => setMethod(mt)}
                    className={`flex-1 flex items-center justify-center gap-2 py-2 text-xs font-semibold rounded-xl transition-all duration-300 ${
                      method === mt
                        ? "bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)] shadow-[inset_0_0_0_1px_oklch(0.82_0.18_200/0.3)]"
                        : "text-muted-foreground hover:text-foreground"
                    }`}
                  >
                    {mt === "phone" ? <Phone className="h-3.5 w-3.5" /> : <Mail className="h-3.5 w-3.5" />}
                    {mt === "phone" ? t("au.byPhone") : t("au.byEmail")}
                  </button>
                ))}
              </div>

              <form onSubmit={submit} className="space-y-4">
                {mode === "signup" && (
                  <Field icon={<User className="h-4 w-4" />} label={t("pf.fullName")}>
                    <input
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      placeholder={t("pf.namePh")}
                      className="w-full bg-transparent outline-none text-sm placeholder:text-muted-foreground/60"
                    />
                  </Field>
                )}

                {method === "phone" ? (
                  !otpStage ? (
                    <Field icon={<Phone className="h-4 w-4" />} label={t("au.byPhone")}>
                      <div className="flex items-center gap-2 w-full">
                        <span className="flex items-center gap-1 text-sm font-bold text-[color:var(--cyan-glow)] border-l border-white/10 pl-2 ml-1">
                          🇱🇾 +218
                        </span>
                        <input
                          dir="ltr"
                          value={phone}
                          onChange={(e) => setPhone(e.target.value.replace(/\D/g, "").slice(0, 10))}
                          placeholder="91 234 5678"
                          className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground/60"
                        />
                      </div>
                    </Field>
                  ) : (
                    <div className="space-y-3 animate-fade-up">
                      <div className="text-xs text-muted-foreground text-center">
                        {t("au.otpTo")} <span className="text-foreground font-semibold" dir="ltr">+218 {phone}</span>
                      </div>
                      <div dir="ltr" className="flex justify-center gap-2">
                        {otp.map((c, i) => (
                          <input
                            key={i}
                            ref={(el) => { otpRefs.current[i] = el; }}
                            value={c}
                            onChange={(e) => onOtpChange(i, e.target.value)}
                            onKeyDown={(e) => {
                              if (e.key === "Backspace" && !otp[i] && i > 0) otpRefs.current[i - 1]?.focus();
                            }}
                            inputMode="numeric"
                            maxLength={1}
                            className="h-12 w-10 text-center text-lg font-extrabold rounded-xl glass border border-white/10 focus:border-[color:var(--cyan-glow)] focus:shadow-[0_0_20px_oklch(0.82_0.18_200/0.4)] outline-none transition-all"
                          />
                        ))}
                      </div>
                      <button
                        type="button"
                        onClick={() => setOtpStage(false)}
                        className="flex items-center gap-1 text-xs text-muted-foreground hover:text-[color:var(--cyan-glow)] mx-auto"
                      >
                        <ArrowLeft className="h-3 w-3" /> {t("au.changeNum")}
                      </button>
                    </div>
                  )
                ) : (
                  <>
                    <Field icon={<Mail className="h-4 w-4" />} label={t("pf.email")}>
                      <input
                        dir="ltr"
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="you@smart.energy"
                        className="w-full bg-transparent outline-none text-sm placeholder:text-muted-foreground/60"
                      />
                    </Field>
                    <Field icon={<Lock className="h-4 w-4" />} label={t("au.password")}>
                      <div className="flex items-center gap-2 w-full">
                        <input
                          dir="ltr"
                          type={showPwd ? "text" : "password"}
                          value={password}
                          onChange={(e) => setPassword(e.target.value)}
                          placeholder="••••••••"
                          className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground/60"
                        />
                        <button type="button" onClick={() => setShowPwd((s) => !s)} className="text-muted-foreground hover:text-foreground">
                          {showPwd ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </button>
                      </div>
                    </Field>
                    {mode === "login" && (
                      <button type="button" className="text-xs text-[color:var(--cyan-glow)] hover:underline">
                        {t("au.forgot")}
                      </button>
                    )}
                  </>
                )}

                {!otpStage && (
                  <button
                    type="submit"
                    disabled={loading}
                    className="group relative w-full overflow-hidden rounded-2xl py-3 font-bold text-background bg-gradient-to-l from-[color:var(--cyan-glow)] via-[color:var(--chart-5)] to-[color:var(--cyan-glow)] bg-[length:200%_100%] hover:bg-[position:100%_0] transition-[background-position] duration-700 glow-cyan disabled:opacity-60 disabled:cursor-not-allowed"
                  >
                    <span className="relative z-10 flex items-center justify-center gap-2">
                      {loading ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        <>
                          {mode === "login"
                            ? method === "phone"
                              ? t("au.sendOtp")
                              : t("au.login")
                            : t("au.createAcc")}
                          <CheckCircle2 className="h-4 w-4 opacity-0 group-hover:opacity-100 transition-opacity" />
                        </>
                      )}
                    </span>
                  </button>
                )}

                <div className="flex items-center gap-3 my-1">
                  <div className="h-px flex-1 bg-white/10" />
                  <span className="text-[10px] uppercase tracking-widest text-muted-foreground">{t("common.or")}</span>
                  <div className="h-px flex-1 bg-white/10" />
                </div>

                <button
                  type="button"
                  onClick={() => { toast.success(t("au.guestOk")); sessionStorage.setItem("show_promo", "1"); navigate({ to: "/" }); }}
                  className="w-full rounded-2xl py-2.5 text-sm font-semibold border border-white/10 hover:border-[color:var(--cyan-glow)]/40 hover:bg-white/5 transition-all"
                >
                  {t("au.guest")}
                </button>
              </form>
            </div>
          </div>
        </div>

        <p className="text-center text-[10px] text-muted-foreground mt-5 tracking-wider">
          {t("au.encrypted")}
        </p>
      </div>
    </div>
  );
}

function Field({ icon, label, children }: { icon: React.ReactNode; label: string; children: React.ReactNode }) {
  return (
    <label className="block animate-fade-up">
      <span className="text-[11px] font-semibold text-muted-foreground mb-1.5 block">{label}</span>
      <div className="group flex items-center gap-2.5 rounded-2xl glass border border-white/10 px-3.5 py-3 transition-all focus-within:border-[color:var(--cyan-glow)]/60 focus-within:shadow-[0_0_24px_oklch(0.82_0.18_200/0.25)]">
        <span className="text-muted-foreground group-focus-within:text-[color:var(--cyan-glow)] transition-colors">{icon}</span>
        {children}
      </div>
    </label>
  );
}

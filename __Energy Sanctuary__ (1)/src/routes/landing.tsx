import { createFileRoute, Link } from "@tanstack/react-router";
import { AnimatePresence, motion, useScroll, useTransform } from "framer-motion";
import { useEffect, useRef, useState } from "react";
import {
  ArrowUpRight, CircuitBoard, Gauge, Workflow, ShieldCheck,
  AtSign, UserRound, PenLine, Leaf, Sparkle, MoveRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

export const Route = createFileRoute("/landing")({
  head: () => ({
    meta: [
      { title: "SmartEnergy — Smart Energy Without Limits" },
      { name: "description", content: "Revolutionizing power consumption with real-time IoT tracking and intelligent overload protection." },
    ],
  }),
  component: LandingPage,
});

const EASE = [0.22, 1, 0.36, 1] as const;
const fadeUp = {
  hidden: { opacity: 0, y: 40 },
  show: { opacity: 1, y: 0, transition: { duration: 0.9, ease: EASE } },
} as const;

/* Premium palette — sophisticated monochrome + champagne gold accent */
const GOLD = "#D4AF7A";
const GOLD_SOFT = "#E6C897";
const INK = "#0A0A0B";

function LandingPage() {
  return (
    <div dir="ltr" className="min-h-screen bg-[#0A0A0B] text-white overflow-x-hidden font-sans antialiased selection:bg-[#D4AF7A] selection:text-black">
      <Splash />
      <Nav />
      <Hero />
      <ConservationBanner />
      <VisionBanner />
      <Features />
      <Contact />
      <Footer />
    </div>
  );
}

/* ---------------- SPLASH ---------------- */
function Splash() {
  const [show, setShow] = useState(true);
  useEffect(() => {
    const t = setTimeout(() => setShow(false), 2800);
    return () => clearTimeout(t);
  }, []);

  return (
    <AnimatePresence>
      {show && (
        <motion.div
          key="splash"
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, transition: { duration: 1.0, ease: EASE } }}
          className="fixed inset-0 z-[100] grid place-items-center bg-[#08080A]"
        >
          {/* radial gold glow */}
          <motion.div
            initial={{ opacity: 0, scale: 0.6 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1.6, ease: EASE }}
            className="absolute inset-0 -z-10"
            style={{ background: `radial-gradient(circle at 50% 50%, ${GOLD}22 0%, transparent 60%)` }}
          />

          <div className="text-center px-6">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.9, ease: EASE }}
              className="flex flex-col items-center gap-6"
            >
              <motion.div
                initial={{ scale: 0.8, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ delay: 0.3, duration: 0.9, ease: EASE }}
                className="relative h-20 w-20 rounded-2xl grid place-items-center"
                style={{
                  background: `linear-gradient(135deg, ${GOLD} 0%, #8B6F3F 100%)`,
                  boxShadow: `0 20px 60px -10px ${GOLD}66`,
                }}
              >
                <Sparkle className="h-9 w-9 text-black" strokeWidth={1.5} />
                <motion.span
                  className="absolute inset-0 rounded-2xl border"
                  style={{ borderColor: `${GOLD}55` }}
                  animate={{ scale: [1, 1.4, 1], opacity: [0.8, 0, 0.8] }}
                  transition={{ duration: 2.2, repeat: Infinity }}
                />
              </motion.div>

              <motion.h1
                initial={{ opacity: 0, letterSpacing: "0.5em" }}
                animate={{ opacity: 1, letterSpacing: "0.25em" }}
                transition={{ delay: 0.5, duration: 1.1, ease: EASE }}
                className="text-2xl sm:text-3xl font-light tracking-[0.25em] uppercase"
                style={{ color: GOLD_SOFT }}
              >
                Smart<span className="font-semibold text-white"> Energy</span>
              </motion.h1>

              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1.0, duration: 0.8 }}
                className="text-xs uppercase tracking-[0.4em] text-white/40 max-w-md"
              >
                Save power · Save the planet
              </motion.p>

              <motion.div
                initial={{ width: 0 }}
                animate={{ width: 140 }}
                transition={{ delay: 1.2, duration: 1.4, ease: EASE }}
                className="h-px"
                style={{ background: `linear-gradient(90deg, transparent, ${GOLD}, transparent)` }}
              />
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

/* ---------------- NAV ---------------- */
function Nav() {
  return (
    <motion.header
      initial={{ y: -30, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.8, ease: EASE, delay: 2.6 }}
      className="fixed top-0 inset-x-0 z-50 px-6 lg:px-12 py-5 flex items-center justify-between backdrop-blur-xl bg-black/40 border-b border-white/[0.06]"
    >
      <Link to="/landing" className="flex items-center gap-3 group">
        <div
          className="h-8 w-8 rounded-lg grid place-items-center"
          style={{ background: `linear-gradient(135deg, ${GOLD}, #8B6F3F)` }}
        >
          <Sparkle className="h-3.5 w-3.5 text-black" strokeWidth={1.5} />
        </div>
        <span className="font-light tracking-[0.2em] text-sm uppercase">
          Smart<span className="font-semibold" style={{ color: GOLD_SOFT }}>Energy</span>
        </span>
      </Link>
      <nav className="hidden md:flex items-center gap-10 text-xs uppercase tracking-[0.2em] text-white/50">
        <a href="#conservation" className="hover:text-white transition-colors">Conservation</a>
        <a href="#vision" className="hover:text-white transition-colors">Vision</a>
        <a href="#features" className="hover:text-white transition-colors">Features</a>
        <a href="#contact" className="hover:text-white transition-colors">Contact</a>
      </nav>
      <Link to="/" className="text-[11px] uppercase tracking-[0.25em] text-white/70 hover:text-black border border-white/15 hover:border-transparent rounded-full px-4 py-2 transition-all hover:bg-[color:var(--brand,#D4AF7A)]" style={{ ["--brand" as any]: GOLD }}>
        Dashboard
      </Link>
    </motion.header>
  );
}

/* ---------------- HERO ---------------- */
function Hero() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start start", "end start"] });
  const y = useTransform(scrollYProgress, [0, 1], [0, 200]);
  const opacity = useTransform(scrollYProgress, [0, 1], [1, 0]);

  return (
    <section ref={ref} className="relative min-h-screen flex items-center justify-center overflow-hidden pt-24 pb-20">
      <div className="absolute inset-0 -z-10">
        <motion.div
          className="absolute top-1/4 -left-40 w-[700px] h-[700px] rounded-full blur-[140px]"
          style={{ background: `radial-gradient(circle, ${GOLD}55 0%, transparent 70%)` }}
          animate={{ x: [0, 80, 0], y: [0, 40, 0], scale: [1, 1.15, 1] }}
          transition={{ duration: 16, repeat: Infinity, ease: "easeInOut" }}
        />
        <motion.div
          className="absolute bottom-1/4 -right-40 w-[600px] h-[600px] rounded-full blur-[140px] opacity-40"
          style={{ background: "radial-gradient(circle, #1a1a1f 0%, transparent 70%)" }}
          animate={{ x: [0, -80, 0], y: [0, -40, 0], scale: [1, 1.2, 1] }}
          transition={{ duration: 18, repeat: Infinity, ease: "easeInOut" }}
        />
        <div className="absolute inset-0 opacity-[0.04] mix-blend-overlay" style={{
          backgroundImage: "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='3'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E\")",
        }} />
      </div>

      <motion.div style={{ y, opacity }} className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 2.9, duration: 0.8 }}
          className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.03] backdrop-blur px-4 py-1.5 text-[10px] uppercase tracking-[0.3em] text-white/60 mb-10"
        >
          <span className="h-1 w-1 rounded-full" style={{ background: GOLD }} />
          IoT · Real-time · Award-winning
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 60 }} animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.2, ease: EASE, delay: 3.0 }}
          className="font-black leading-[0.9] tracking-tighter text-5xl sm:text-7xl lg:text-[9.5rem]"
        >
          SMART ENERGY
          <br />
          <span
            className="italic font-light"
            style={{
              background: `linear-gradient(90deg, ${GOLD_SOFT}, ${GOLD}, ${GOLD_SOFT})`,
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            without limits
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 3.4, duration: 0.8 }}
          className="mt-10 text-base sm:text-lg text-white/55 max-w-2xl mx-auto leading-relaxed font-light"
        >
          Revolutionizing power consumption with real-time IoT tracking and intelligent overload protection.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 3.6, duration: 0.7 }}
          className="mt-12 flex flex-col sm:flex-row gap-4 justify-center items-center"
        >
          <MagneticButton primary>
            <Link to="/auth" className="inline-flex items-center gap-2">
              Get Started <ArrowUpRight className="h-4 w-4" strokeWidth={1.5} />
            </Link>
          </MagneticButton>
          <MagneticButton>
            <a href="#features" className="inline-flex items-center gap-2">Learn More</a>
          </MagneticButton>
        </motion.div>
      </motion.div>
    </section>
  );
}

function MagneticButton({ children, primary }: { children: React.ReactNode; primary?: boolean }) {
  return (
    <motion.div whileHover={{ scale: 1.04 }} whileTap={{ scale: 0.97 }} transition={{ type: "spring", stiffness: 400, damping: 18 }}>
      <Button
        asChild
        size="lg"
        className={
          primary
            ? "h-14 px-8 rounded-full text-black font-semibold text-sm uppercase tracking-[0.2em] border-0"
            : "h-14 px-8 rounded-full bg-transparent hover:bg-white/[0.06] text-white font-light text-sm uppercase tracking-[0.2em] backdrop-blur-md border border-white/15 hover:border-white/35"
        }
        style={primary ? {
          background: `linear-gradient(135deg, ${GOLD_SOFT}, ${GOLD})`,
          boxShadow: `0 12px 40px -10px ${GOLD}88`,
        } : {}}
      >
        {children as any}
      </Button>
    </motion.div>
  );
}

/* ---------------- CONSERVATION BANNER (NEW, MAIN) ---------------- */
function ConservationBanner() {
  return (
    <section id="conservation" className="relative py-32 lg:py-40 overflow-hidden">
      {/* editorial dark surface */}
      <div className="absolute inset-0 -z-10" style={{
        background: "linear-gradient(180deg, #0A0A0B 0%, #100E0A 50%, #0A0A0B 100%)",
      }} />
      <div className="absolute inset-0 -z-10 opacity-30" style={{
        background: `radial-gradient(ellipse at 50% 50%, ${GOLD}22 0%, transparent 60%)`,
      }} />

      <div className="max-w-7xl mx-auto px-6 lg:px-12">
        <motion.div
          initial="hidden" whileInView="show" viewport={{ once: true, amount: 0.3 }}
          variants={{ show: { transition: { staggerChildren: 0.12 } } }}
          className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center"
        >
          {/* Left — eyebrow + Arabic editorial */}
          <motion.div variants={fadeUp} className="lg:col-span-5">
            <div className="flex items-center gap-3 text-[10px] uppercase tracking-[0.4em] mb-8" style={{ color: GOLD_SOFT }}>
              <Leaf className="h-4 w-4" strokeWidth={1.5} />
              Energy Conservation
            </div>
            <h3 dir="rtl" className="text-4xl sm:text-5xl font-bold leading-[1.15] mb-6" style={{ color: "#F5E9D3" }}>
              ترشيد استهلاك
              <br />
              <span className="italic font-light" style={{ color: GOLD_SOFT }}>الكهرباء</span>
            </h3>
            <p dir="rtl" className="text-base leading-loose text-white/55 max-w-md font-light">
              كل واط نوفّره اليوم هو خطوة نحو غدٍ أنظف. سمارت إنرجي تحوّل وعيك بالاستهلاك إلى عادة ذكية مستدامة.
            </p>
          </motion.div>

          {/* Right — large editorial English */}
          <motion.div variants={fadeUp} className="lg:col-span-7">
            <div className="border-l border-white/10 pl-8 lg:pl-14">
              <h2
                className="text-5xl sm:text-7xl lg:text-8xl font-black tracking-tighter leading-[0.9]"
                style={{ color: "#F5E9D3" }}
              >
                Save power.
                <br />
                <span className="italic font-light" style={{ color: GOLD }}>Save the planet.</span>
              </h2>

              <div className="mt-12 grid grid-cols-3 gap-8 max-w-xl">
                {[
                  { k: "27%", v: "Avg. monthly savings" },
                  { k: "1.4t", v: "CO₂ offset / household" },
                  { k: "24/7", v: "Live monitoring" },
                ].map((s) => (
                  <motion.div key={s.k} variants={fadeUp}>
                    <div className="text-3xl sm:text-4xl font-light" style={{ color: GOLD_SOFT }}>{s.k}</div>
                    <div className="mt-2 text-[10px] uppercase tracking-[0.2em] text-white/40">{s.v}</div>
                  </motion.div>
                ))}
              </div>

              <motion.a
                variants={fadeUp}
                href="#features"
                whileHover={{ x: 6 }}
                className="mt-12 inline-flex items-center gap-3 text-sm uppercase tracking-[0.25em] text-white/80 hover:text-white"
              >
                Discover how
                <span className="h-px w-16 transition-all" style={{ background: GOLD }} />
                <MoveRight className="h-4 w-4" strokeWidth={1.5} style={{ color: GOLD }} />
              </motion.a>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}

/* ---------------- VISION ---------------- */
function VisionBanner() {
  return (
    <section id="vision" className="relative py-32 lg:py-44 overflow-hidden bg-[#0A0A0B]">
      <motion.div
        initial="hidden" whileInView="show" viewport={{ once: true, amount: 0.3 }}
        variants={{ show: { transition: { staggerChildren: 0.15 } } }}
        className="max-w-6xl mx-auto px-6 lg:px-12 text-center"
      >
        <motion.div variants={fadeUp} className="inline-flex items-center gap-2 text-[10px] uppercase tracking-[0.4em] mb-10" style={{ color: GOLD_SOFT }}>
          <span className="h-px w-8" style={{ background: GOLD }} />
          Our philosophy
          <span className="h-px w-8" style={{ background: GOLD }} />
        </motion.div>

        <motion.h2
          variants={fadeUp}
          className="font-black tracking-tighter leading-[0.95] text-4xl sm:text-6xl lg:text-7xl"
          style={{ color: "#F5E9D3" }}
        >
          Developed with{" "}
          <span className="italic font-light" style={{ color: GOLD_SOFT }}>precision</span>,
          <br />
          delivered with{" "}
          <span className="italic font-light" style={{ color: GOLD_SOFT }}>passion</span>.
        </motion.h2>

        <motion.p variants={fadeUp} className="mt-10 text-base text-white/45 max-w-xl mx-auto font-light">
          Every watt counts. Every second matters. SmartEnergy turns awareness into action.
        </motion.p>
      </motion.div>
    </section>
  );
}

/* ---------------- FEATURES ---------------- */
const FEATURES = [
  { icon: CircuitBoard, title: "ESP32 Integration", desc: "Industrial-grade microcontroller with WiFi & dual-core power for instant signal response." },
  { icon: Gauge, title: "Live Wattage Tracking", desc: "Sub-second power telemetry streamed straight from your panels to your pocket." },
  { icon: Workflow, title: "Smart Relays", desc: "Programmable smart relays that switch loads with precision and predictive logic." },
  { icon: ShieldCheck, title: "Auto-Disconnect", desc: "Intelligent overload protection cuts power before damage — automatically, every time." },
];

function Features() {
  return (
    <section id="features" className="relative py-32 lg:py-44 bg-[#0A0A0B]">
      <div className="max-w-7xl mx-auto px-6 lg:px-12">
        <motion.div
          initial="hidden" whileInView="show" viewport={{ once: true, amount: 0.3 }}
          variants={{ show: { transition: { staggerChildren: 0.1 } } }}
          className="max-w-3xl"
        >
          <motion.div variants={fadeUp} className="text-[10px] uppercase tracking-[0.4em] mb-6" style={{ color: GOLD_SOFT }}>— Capabilities</motion.div>
          <motion.h2 variants={fadeUp} className="text-5xl lg:text-7xl font-black leading-[0.95] tracking-tighter">
            Built for the<br />
            <span className="italic font-light text-white/40">future of power.</span>
          </motion.h2>
        </motion.div>

        <div className="mt-20 grid grid-cols-1 md:grid-cols-2 gap-px bg-white/[0.06] rounded-3xl overflow-hidden border border-white/[0.06]">
          {FEATURES.map((f, i) => (
            <FeatureCard key={f.title} {...f} index={i} />
          ))}
        </div>
      </div>
    </section>
  );
}

function FeatureCard({ icon: Icon, title, desc, index }: { icon: any; title: string; desc: string; index: number }) {
  const [hover, setHover] = useState(false);
  return (
    <motion.div
      initial={{ opacity: 0, y: 40 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.7, delay: index * 0.08, ease: EASE }}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      className="relative group bg-[#0A0A0B] p-10 lg:p-14 cursor-pointer overflow-hidden"
    >
      <motion.div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `radial-gradient(600px circle at 50% 50%, ${GOLD}10, transparent 40%)` }}
      />
      <div className="relative z-10">
        <div className="flex items-start justify-between mb-12">
          <div className="text-[10px] text-white/25 tabular-nums tracking-[0.3em]">0{index + 1} / 04</div>
          <motion.div
            animate={{ rotate: hover ? 6 : 0, scale: hover ? 1.06 : 1 }}
            transition={{ type: "spring", stiffness: 280 }}
            className="h-14 w-14 rounded-2xl bg-white/[0.03] border grid place-items-center transition-colors"
            style={{ borderColor: hover ? GOLD : "rgba(255,255,255,0.08)" }}
          >
            <Icon className="h-5 w-5" strokeWidth={1.25} style={{ color: hover ? GOLD : "#9CA3AF" }} />
          </motion.div>
        </div>
        <h3 className="text-3xl lg:text-4xl font-light tracking-tight mb-4" style={{ color: "#F5E9D3" }}>{title}</h3>
        <p className="text-white/45 text-sm leading-relaxed max-w-md font-light">{desc}</p>
      </div>
    </motion.div>
  );
}

/* ---------------- CONTACT ---------------- */
// قسم نموذج التواصل — يتحقق من المدخلات وينقّيها قبل الإرسال
function Contact() {
  // حالة بيانات النموذج (الاسم/البريد/الرسالة)
  const [form, setForm] = useState({ name: "", email: "", message: "" });
  return (
    <section id="contact" className="relative py-32 lg:py-44 bg-gradient-to-b from-[#0A0A0B] via-[#0c0b09] to-[#0A0A0B]">
      <div className="max-w-5xl mx-auto px-6 lg:px-12">
        <motion.div
          initial="hidden" whileInView="show" viewport={{ once: true, amount: 0.2 }}
          variants={{ show: { transition: { staggerChildren: 0.1 } } }}
        >
          <motion.div variants={fadeUp} className="text-[10px] uppercase tracking-[0.4em] mb-6 text-center" style={{ color: GOLD_SOFT }}>— Get in touch</motion.div>
          <motion.h2 variants={fadeUp} className="text-center text-5xl sm:text-7xl lg:text-8xl font-black tracking-tighter leading-[0.9] mb-10">
            Let's build<br />
            <span className="italic font-light" style={{ color: GOLD_SOFT }}>something powerful.</span>
          </motion.h2>

          {/* بطاقات التواصل المباشر — البريد والهاتف */}
          <motion.div variants={fadeUp} className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-2xl mx-auto mb-12">
            <a href="mailto:SOUHAYLSAAID@GMAIL.COM" className="group flex items-center gap-4 rounded-2xl border border-white/[0.08] bg-white/[0.03] hover:bg-white/[0.06] transition-all p-5">
              <div className="grid h-11 w-11 place-items-center rounded-xl shrink-0" style={{ background: `linear-gradient(135deg, ${GOLD}, #8B6F3F)` }}>
                <AtSign className="h-5 w-5 text-black" strokeWidth={1.5} />
              </div>
              <div className="min-w-0">
                <div className="text-[10px] uppercase tracking-[0.3em] text-white/40 mb-1">Email</div>
                <div className="text-sm font-medium text-white truncate" style={{ color: GOLD_SOFT }}>SOUHAYLSAAID@GMAIL.COM</div>
              </div>
            </a>
            <a href="tel:00218915775774" dir="ltr" className="group flex items-center gap-4 rounded-2xl border border-white/[0.08] bg-white/[0.03] hover:bg-white/[0.06] transition-all p-5">
              <div className="grid h-11 w-11 place-items-center rounded-xl shrink-0" style={{ background: `linear-gradient(135deg, ${GOLD}, #8B6F3F)` }}>
                <ShieldCheck className="h-5 w-5 text-black" strokeWidth={1.5} />
              </div>
              <div className="min-w-0">
                <div className="text-[10px] uppercase tracking-[0.3em] text-white/40 mb-1">Phone</div>
                <div className="text-sm font-medium" style={{ color: GOLD_SOFT }}>00218 91 577 5774</div>
              </div>
            </a>
          </motion.div>

          <motion.form
            variants={fadeUp}
            onSubmit={async (e) => {
              e.preventDefault();
              // تنقية المدخلات والتحقق منها قبل الإرسال
              const { contactSchema, sanitizeText } = await import("@/lib/validation");
              const clean = {
                name: sanitizeText(form.name),
                email: sanitizeText(form.email),
                message: sanitizeText(form.message),
              };
              const parsed = contactSchema.safeParse(clean);
              if (!parsed.success) {
                toast.error(parsed.error.issues[0]?.message ?? "Invalid input");
                return;
              }
              // ضع هنا استدعاء Firebase أو API لإرسال الرسالة
              toast.success("Message sent — we'll be in touch");
              setForm({ name: "", email: "", message: "" });
            }}
            className="space-y-5 max-w-2xl mx-auto"
          >
            <FieldInput icon={UserRound} placeholder="Your name" value={form.name} onChange={(v: string) => setForm({ ...form, name: v })} />
            <FieldInput icon={AtSign} type="email" placeholder="Your email" value={form.email} onChange={(v: string) => setForm({ ...form, email: v })} />
            <FieldTextarea icon={PenLine} placeholder="Tell us about your project..." value={form.message} onChange={(v: string) => setForm({ ...form, message: v })} />

            <motion.button
              whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}
              type="submit"
              className="w-full h-16 rounded-2xl text-black font-semibold text-sm tracking-[0.25em] uppercase transition-shadow"
              style={{
                background: `linear-gradient(135deg, ${GOLD_SOFT}, ${GOLD})`,
                boxShadow: `0 12px 40px -10px ${GOLD}88`,
              }}
            >
              Send Message
            </motion.button>
          </motion.form>
        </motion.div>
      </div>
    </section>
  );
}

function FieldInput({ icon: Icon, type = "text", placeholder, value, onChange }: any) {
  return (
    <div className="relative group">
      <Icon className="absolute left-5 top-1/2 -translate-y-1/2 h-4 w-4 text-white/30 group-focus-within:text-[color:var(--g)] transition-colors" style={{ ["--g" as any]: GOLD }} strokeWidth={1.5} />
      <input
        type={type} placeholder={placeholder} value={value} onChange={(e) => onChange(e.target.value)} required
        className="w-full h-16 rounded-2xl bg-white/[0.03] border border-white/[0.08] pl-14 pr-5 text-white placeholder:text-white/25 outline-none focus:border-[color:var(--g)]/60 focus:bg-white/[0.05] transition-all font-light"
        style={{ ["--g" as any]: GOLD }}
      />
    </div>
  );
}

function FieldTextarea({ icon: Icon, placeholder, value, onChange }: any) {
  return (
    <div className="relative group">
      <Icon className="absolute left-5 top-5 h-4 w-4 text-white/30 group-focus-within:text-[color:var(--g)] transition-colors" style={{ ["--g" as any]: GOLD }} strokeWidth={1.5} />
      <textarea
        placeholder={placeholder} value={value} onChange={(e) => onChange(e.target.value)} required rows={5}
        className="w-full rounded-2xl bg-white/[0.03] border border-white/[0.08] pl-14 pr-5 py-5 text-white placeholder:text-white/25 outline-none focus:border-[color:var(--g)]/60 focus:bg-white/[0.05] transition-all resize-none font-light"
        style={{ ["--g" as any]: GOLD }}
      />
    </div>
  );
}

/* ---------------- FOOTER ---------------- */
function Footer() {
  return (
    <footer className="border-t border-white/[0.06] bg-[#08080A] py-12 px-6 lg:px-12">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
        <div className="flex items-center gap-3">
          <div className="h-7 w-7 rounded-md grid place-items-center" style={{ background: `linear-gradient(135deg, ${GOLD}, #8B6F3F)` }}>
            <Sparkle className="h-3 w-3 text-black" strokeWidth={1.5} />
          </div>
          <span className="font-light tracking-[0.2em] text-xs uppercase">
            Smart<span className="font-semibold" style={{ color: GOLD_SOFT }}>Energy</span>
          </span>
          <span className="text-[10px] uppercase tracking-[0.2em] text-white/25 ml-3">© {new Date().getFullYear()}</span>
        </div>
        <div className="flex items-center gap-6 text-[10px] uppercase tracking-[0.3em] text-white/40">
          {["Twitter", "LinkedIn", "GitHub", "Instagram"].map((label) => (
            <motion.a
              key={label} href="#" whileHover={{ y: -2, color: GOLD }}
              className="hover:text-white transition-colors"
            >
              {label}
            </motion.a>
          ))}
        </div>
      </div>
    </footer>
  );
}

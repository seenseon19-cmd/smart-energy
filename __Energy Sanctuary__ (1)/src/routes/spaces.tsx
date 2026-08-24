import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useStore, PLANS } from "@/lib/store";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Home, Building2, Plus, BadgeCheck } from "lucide-react";
import { toast } from "sonner";
import { useSettings } from "@/lib/settings";

export const Route = createFileRoute("/spaces")({
  component: () => <AppShell><SpacesPage /></AppShell>,
});

function SpacesPage() {
  const { spaces, activeSpace, activeSpaceId, setActiveSpaceId, addSpace } = useStore();
  const { t, lang } = useSettings();
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [type, setType] = useState<"home" | "commercial">("home");
  const [bizName, setBizName] = useState("");
  const [taxId, setTaxId] = useState("");

  const submit = () => {
    if (!name) return toast.error(t("sp.errName"));
    if (type === "commercial" && (!bizName || !taxId)) return toast.error(t("sp.errBiz"));
    addSpace({
      name, type,
      business: type === "commercial" ? { name: bizName, taxId, verified: false } : undefined,
    });
    toast.success(t("sp.created"));
    setOpen(false); setName(""); setBizName(""); setTaxId(""); setType("home");
  };

  const align = lang === "ar" ? "text-right" : "text-left";

  return (
    <div className="space-y-6">
      {/* ترويسة فاخرة للمساحة النشطة — أيقونة كبيرة + اسم بارز */}
      <div className="glass rounded-3xl p-6 lg:p-8 flex flex-col md:flex-row md:items-center md:justify-between gap-6 animate-fade-up">
        <div className="flex items-center gap-5">
          <div className={`grid h-16 w-16 lg:h-20 lg:w-20 place-items-center rounded-2xl shrink-0 ${
            activeSpace.type === "home"
              ? "bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)]"
              : "bg-amber-100 text-amber-700"
          }`}>
            {activeSpace.type === "home"
              ? <Home className="h-9 w-9 lg:h-10 lg:w-10" strokeWidth={1.5} />
              : <Building2 className="h-9 w-9 lg:h-10 lg:w-10" strokeWidth={1.5} />}
          </div>
          <div>
            <div className="text-[10px] uppercase tracking-[0.3em] text-muted-foreground">{t("sp.title")}</div>
            <h1 className="text-2xl lg:text-4xl font-extrabold mt-1 leading-tight">{t(activeSpace.name)}</h1>
            <div className="mt-2">
              {activeSpace.type === "commercial" ? (
                <span className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold uppercase tracking-wider bg-amber-100 text-amber-700">
                  <Building2 className="h-3.5 w-3.5" strokeWidth={1.5} /> {t("common.commercial")}
                </span>
              ) : (
                <span className="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold uppercase tracking-wider bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)]">
                  <Home className="h-3.5 w-3.5" strokeWidth={1.5} /> {t("common.home")}
                </span>
              )}
            </div>
          </div>
        </div>
        <Button onClick={() => setOpen(true)} className="bg-[color:var(--cyan-glow)] text-background glow-cyan rounded-xl">
          <Plus className={`h-4 w-4 ${lang === "ar" ? "ml-1" : "mr-1"}`} /> {t("sp.new")}
        </Button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {spaces.map((s) => {
          const active = s.id === activeSpaceId;
          return (
            <button
              key={s.id}
              onClick={() => setActiveSpaceId(s.id)}
              className={`${align} glass rounded-2xl p-5 border transition hover:bg-white/5 ${
                active ? "border-[color:var(--cyan-glow)] glow-cyan" : "border-white/10"
              }`}
            >
              <div className="flex items-center gap-3">
                <div className={`grid h-12 w-12 place-items-center rounded-xl ${
                  s.type === "home"
                    ? "bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)]"
                    : "bg-amber-100 text-amber-700"
                }`}>
                  {s.type === "home" ? <Home className="h-6 w-6" strokeWidth={1.5} /> : <Building2 className="h-6 w-6" strokeWidth={1.5} />}
                </div>
                <div className="flex-1">
                  <div className="font-bold text-lg flex items-center gap-2">
                    {t(s.name)}
                    {s.business?.verified && <BadgeCheck className="h-4 w-4 text-[color:var(--green-glow)]" strokeWidth={1.5} />}
                  </div>
                  {/* شارة النوع — ذهبي فاخر للتجاري (amber-100/amber-700) */}
                  {s.type === "commercial" ? (
                    <span className="inline-flex items-center gap-1 mt-1 rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider bg-amber-100 text-amber-700">
                      <Building2 className="h-3 w-3" strokeWidth={1.5} /> {t("common.commercial")}
                    </span>
                  ) : (
                    <div className="text-xs text-muted-foreground">{t("common.home")}</div>
                  )}
                </div>
              </div>
              <div className="mt-4 grid grid-cols-2 gap-2 text-xs">
                <div className="rounded-lg bg-white/5 p-2">
                  <div className="text-muted-foreground">{t("sp.plan")}</div>
                  <div className="font-semibold text-[color:var(--cyan-glow)]">{t(PLANS[s.plan].name)}</div>
                </div>
                <div className="rounded-lg bg-white/5 p-2">
                  <div className="text-muted-foreground">{t("common.devices")}</div>
                  <div className="font-semibold">
                    {s.devices.length}/{PLANS[s.plan].deviceLimit === Infinity ? "∞" : PLANS[s.plan].deviceLimit}
                  </div>
                </div>
              </div>
            </button>
          );
        })}
      </div>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="glass-strong border-white/10">
          <DialogHeader><DialogTitle>{t("sp.createTitle")}</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div>
              <Label>{t("sp.name")}</Label>
              <Input value={name} onChange={(e) => setName(e.target.value)} placeholder={t("sp.namePh")} />
            </div>
            <div>
              <Label className="mb-2 block">{t("sp.type")}</Label>
              <RadioGroup value={type} onValueChange={(v) => setType(v as "home" | "commercial")} className="grid grid-cols-2 gap-3">
                <label className={`glass rounded-xl p-3 flex items-center gap-2 cursor-pointer ${type === "home" ? "border-[color:var(--cyan-glow)] border" : ""}`}>
                  <RadioGroupItem value="home" /> <Home className="h-4 w-4" /> {t("common.home")}
                </label>
                <label className={`glass rounded-xl p-3 flex items-center gap-2 cursor-pointer ${type === "commercial" ? "border-[color:var(--cyan-glow)] border" : ""}`}>
                  <RadioGroupItem value="commercial" /> <Building2 className="h-4 w-4" /> {t("common.commercial")}
                </label>
              </RadioGroup>
            </div>
            {type === "commercial" && (
              <div className="space-y-3 glass rounded-xl p-4 animate-fade-up">
                <div className="text-xs text-[color:var(--amber-glow)]">{t("sp.bizVerify")}</div>
                <div>
                  <Label>{t("sp.bizName")}</Label>
                  <Input value={bizName} onChange={(e) => setBizName(e.target.value)} />
                </div>
                <div>
                  <Label>{t("sp.taxId")}</Label>
                  <Input value={taxId} onChange={(e) => setTaxId(e.target.value)} />
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button onClick={submit} className="bg-[color:var(--cyan-glow)] text-background">{t("common.create")}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

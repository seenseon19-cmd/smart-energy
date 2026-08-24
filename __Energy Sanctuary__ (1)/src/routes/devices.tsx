import { createFileRoute } from "@tanstack/react-router";
import { AppShell } from "@/components/app-shell";
import { useStore, ALL_RELAYS, ICON_CHOICES, PLANS, type Device } from "@/lib/store";
import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { DeviceCard } from "@/components/device-card";
import { Plus, Sparkles, Trash2, Crown, Pencil, Cpu, Lock, Check } from "lucide-react";
import { toast } from "sonner";
import * as Icons from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { useSettings } from "@/lib/settings";

export const Route = createFileRoute("/devices")({
  component: () => <AppShell><DevicesPage /></AppShell>,
});

function DevicesPage() {
  const { activeSpace, removeDevice } = useStore();
  const { t, lang } = useSettings();
  const [editing, setEditing] = useState<Device | null>(null);
  const [open, setOpen] = useState(false);
  const [upgrade, setUpgrade] = useState(false);

  const plan = PLANS[activeSpace.plan];
  const atLimit = activeSpace.devices.length >= plan.deviceLimit;

  const openAdd = () => {
    if (atLimit) return setUpgrade(true);
    setEditing(null);
    setOpen(true);
  };
  const openEdit = (d: Device) => { setEditing(d); setOpen(true); };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="text-3xl font-extrabold">{t("dev.title")}</h1>
          <p className="text-sm text-muted-foreground mt-1">
            {activeSpace.devices.length} / {plan.deviceLimit === Infinity ? "∞" : plan.deviceLimit} · {t(plan.name)}
          </p>
        </div>
        <Button
          onClick={openAdd}
          className="bg-[color:var(--cyan-glow)] text-background hover:bg-[color:var(--cyan-glow)]/90 glow-cyan rounded-xl"
        >
          <Plus className={`h-4 w-4 ${lang === "ar" ? "ml-1" : "mr-1"}`} /> {t("dev.add")}
        </Button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
        {activeSpace.devices.map((d) => (
          <div key={d.id} className="relative group">
            <DeviceCard device={d} />
            <div className="absolute top-2 left-2 flex gap-1 opacity-0 group-hover:opacity-100 transition">
              <button
                onClick={() => openEdit(d)}
                className="p-1.5 rounded-lg bg-white/10 text-[color:var(--cyan-glow)] hover:bg-white/20"
              >
                <Pencil className="h-3.5 w-3.5" />
              </button>
              <button
                onClick={() => { removeDevice(activeSpace.id, d.id); toast.success(t("dev.deleted")); }}
                className="p-1.5 rounded-lg bg-red-500/10 text-[color:var(--red-glow)] hover:bg-red-500/20"
              >
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        ))}
        {activeSpace.devices.length === 0 && (
          <div className="glass rounded-2xl p-10 text-center text-muted-foreground col-span-full">
            {t("dev.empty")}
          </div>
        )}
      </div>

      <DeviceModal
        key={(editing?.id ?? "new") + String(open)}
        open={open}
        onOpenChange={setOpen}
        editing={editing}
      />
      <UpgradeModal open={upgrade} onOpenChange={setUpgrade} />
    </div>
  );
}

function DeviceModal({
  open, onOpenChange, editing,
}: { open: boolean; onOpenChange: (v: boolean) => void; editing: Device | null }) {
  const { activeSpace, addDevice, updateDevice } = useStore();
  const { t } = useSettings();
  const [name, setName] = useState("");
  const [icon, setIcon] = useState("Plug");
  const [relay, setRelay] = useState<number>(0);
  const [ratedW, setRatedW] = useState(100);

  useEffect(() => {
    if (editing) {
      setName(editing.name); setIcon(editing.icon);
      setRelay(editing.relay); setRatedW(editing.ratedW);
    } else {
      setName(""); setIcon("Plug"); setRelay(0); setRatedW(100);
    }
  }, [editing, open]);

  // Map relay -> device occupying it (excluding the one being edited)
  const occupied = new Map<number, Device>();
  activeSpace.devices.forEach((d) => {
    if (!editing || d.id !== editing.id) occupied.set(d.relay, d);
  });

  const submit = () => {
    if (!name.trim()) return toast.error(t("dev.errName"));
    if (!relay) return toast.error(t("dev.errRelay"));
    const r = editing
      ? updateDevice(activeSpace.id, editing.id, { name, icon, relay, ratedW })
      : addDevice(activeSpace.id, { name, icon, relay, ratedW });
    if (!r.ok) {
      if (r.reason === "relay") return toast.error(t("dev.errRelayUsed"));
      return toast.error(t("dev.errSave"));
    }
    toast.success(editing ? t("dev.updated") : t("dev.added"));
    onOpenChange(false);
  };

  const SelectedIcon = (Icons as unknown as Record<string, LucideIcon>)[icon] ?? Icons.Plug;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="glass-strong border-white/10 max-w-xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <SelectedIcon className="h-5 w-5 text-[color:var(--cyan-glow)]" />
            {editing ? t("dev.editTitle") : t("dev.addTitle")}
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-5">
          <div>
            <Label>{t("dev.name")}</Label>
            <Input value={name} onChange={(e) => setName(e.target.value)} placeholder={t("dev.namePh")} className="mt-1.5" />
          </div>

          <div>
            <Label>{t("dev.icon")}</Label>
            <div className="grid grid-cols-6 gap-1.5 mt-1.5">
              {ICON_CHOICES.map((n) => {
                const I = (Icons as unknown as Record<string, LucideIcon>)[n] ?? Icons.Plug;
                return (
                  <button
                    key={n}
                    type="button"
                    onClick={() => setIcon(n)}
                    className={`grid place-items-center h-10 rounded-lg border transition ${
                      icon === n
                        ? "bg-[color:var(--cyan-glow)]/20 border-[color:var(--cyan-glow)] text-[color:var(--cyan-glow)] glow-cyan"
                        : "border-white/10 text-muted-foreground hover:bg-white/5"
                    }`}
                  ><I className="h-4 w-4" /></button>
                );
              })}
            </div>
          </div>

          {/* Hardware pin selector */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <Label className="flex items-center gap-1.5"><Cpu className="h-4 w-4 text-[color:var(--cyan-glow)]" /> {t("dev.selectRelay")}</Label>
              <span className="text-[10px] text-muted-foreground">ESP32 Pins 1–8</span>
            </div>

            <div className="grid grid-cols-4 gap-2">
              {ALL_RELAYS.map((r) => {
                const used = occupied.get(r);
                const selected = relay === r;
                return (
                  <button
                    key={r}
                    type="button"
                    disabled={!!used}
                    onClick={() => setRelay(r)}
                    className={`relative group rounded-xl p-3 text-right border transition overflow-hidden ${
                      selected
                        ? "bg-[color:var(--cyan-glow)]/15 border-[color:var(--cyan-glow)] glow-cyan"
                        : used
                        ? "bg-red-500/5 border-[color:var(--red-glow)]/30 cursor-not-allowed opacity-70"
                        : "border-white/10 hover:bg-white/5 hover:border-[color:var(--cyan-glow)]/40"
                    }`}
                  >
                    <div className="flex items-center justify-between mb-1">
                      <span className={`h-2 w-2 rounded-full ${
                        selected ? "bg-[color:var(--cyan-glow)] animate-pulse" :
                        used ? "bg-[color:var(--red-glow)]" : "bg-white/20"
                      }`} />
                      {selected && <Check className="h-3.5 w-3.5 text-[color:var(--cyan-glow)]" />}
                      {used && !selected && <Lock className="h-3 w-3 text-[color:var(--red-glow)]" />}
                    </div>
                    <div className={`font-bold text-sm ${
                      selected ? "text-[color:var(--cyan-glow)]" :
                      used ? "text-[color:var(--red-glow)]" : ""
                    }`}>{t("common.relay")} {r}</div>
                    <div className="text-[10px] text-muted-foreground truncate mt-0.5">
                      {used ? t(used.name) : t("common.available")}
                    </div>
                  </button>
                );
              })}
            </div>
            {relay > 0 && (
              <p className="text-xs text-[color:var(--cyan-glow)] mt-2 animate-fade-up">
                ✓ {t("dev.relayAssigned")} {relay}
              </p>
            )}
          </div>

          <div>
            <Label>{t("dev.ratedW")}</Label>
            <Input
              type="number"
              value={ratedW}
              onChange={(e) => setRatedW(+e.target.value)}
              className="mt-1.5"
            />
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)} className="border-white/10">
            {t("common.cancel")}
          </Button>
          <Button
            onClick={submit}
            className="bg-[color:var(--cyan-glow)] text-background hover:bg-[color:var(--cyan-glow)]/90 glow-cyan"
          >
            {editing ? t("dev.saveEdit") : t("dev.add")}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function UpgradeModal({ open, onOpenChange }: { open: boolean; onOpenChange: (v: boolean) => void }) {
  const { activeSpace, updateSpace } = useStore();
  const { t, lang } = useSettings();
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="glass-strong border-white/10 max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-[color:var(--amber-glow)]" />
            {t("dev.upgradeTitle")}
          </DialogTitle>
        </DialogHeader>
        <p className="text-sm text-muted-foreground">
          {t("dev.upgradeMsg")}
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-2">
          {(["free", "basic", "pro", "ultimate"] as const).map((p) => (
            <button
              key={p}
              onClick={() => { updateSpace(activeSpace.id, { plan: p }); onOpenChange(false); toast.success(`${t("dev.planChanged")} ${t(PLANS[p].name)}`); }}
              className={`${lang === "ar" ? "text-right" : "text-left"} glass rounded-2xl p-4 hover:bg-white/5 border transition ${
                activeSpace.plan === p ? "border-[color:var(--cyan-glow)] glow-cyan" : "border-white/10"
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="font-bold text-lg">{t(PLANS[p].name)}</div>
                {p === "ultimate" && <Crown className="h-4 w-4 text-[color:var(--amber-glow)]" />}
              </div>
              <div className="text-[color:var(--cyan-glow)] font-semibold mt-1">{PLANS[p].price}</div>
              <div className="text-xs text-muted-foreground mt-2">
                {t("dev.upTo")} {PLANS[p].deviceLimit === Infinity ? t("common.unlimited") : PLANS[p].deviceLimit} {t("common.devices")}
              </div>
            </button>
          ))}
        </div>
      </DialogContent>
    </Dialog>
  );
}

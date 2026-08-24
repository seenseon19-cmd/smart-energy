import { createContext, useContext, useEffect, useMemo, useRef, useState, type ReactNode } from "react";

export type PlanId = "free" | "basic" | "pro" | "ultimate";

export const PLANS: Record<PlanId, { name: string; deviceLimit: number; price: string }> = {
  free: { name: "plan.free", deviceLimit: 2, price: "0 LYD" },
  basic: { name: "plan.basic", deviceLimit: 6, price: "15 LYD" },
  pro: { name: "plan.pro", deviceLimit: 20, price: "35 LYD" },
  ultimate: { name: "plan.ultimate", deviceLimit: Infinity, price: "400 LYD" },
};

export type Device = {
  id: string;
  name: string;
  icon: string; // lucide icon name
  relay: number; // 1..8
  on: boolean;
  ratedW: number; // typical watts when on
};

export type Space = {
  id: string;
  name: string;
  type: "home" | "commercial";
  plan: PlanId;
  powerLimit: number; // W
  autoDisconnect: boolean;
  devices: Device[];
  business?: { name: string; taxId: string; verified: boolean };
};

export type LiveSnapshot = {
  power: number; // W
  voltage: number; // V
  current: number; // A
  kwh: number; // total
  bill: number; // LYD
  history: { t: number; w: number }[];
};

type Ctx = {
  spaces: Space[];
  activeSpaceId: string;
  activeSpace: Space;
  setActiveSpaceId: (id: string) => void;
  addSpace: (s: Omit<Space, "id" | "devices" | "powerLimit" | "autoDisconnect" | "plan"> & Partial<Pick<Space, "plan">>) => void;
  updateSpace: (id: string, patch: Partial<Space>) => void;
  addDevice: (spaceId: string, d: Omit<Device, "id" | "on">) => { ok: boolean; reason?: string };
  updateDevice: (spaceId: string, deviceId: string, patch: Partial<Omit<Device, "id">>) => { ok: boolean; reason?: string };
  removeDevice: (spaceId: string, deviceId: string) => void;
  toggleDevice: (spaceId: string, deviceId: string) => void;
  live: LiveSnapshot;
  overload: boolean;
  surgeActive: boolean;
  triggerOverload: () => void;
  resetCutoff: () => void;
};

const StoreCtx = createContext<Ctx | null>(null);

const RATE_LYD_PER_KWH = 0.045;

function uid() {
  return Math.random().toString(36).slice(2, 10);
}

const initialSpaces: Space[] = [
  {
    id: "home", name: "init.home", type: "home", plan: "pro",
    powerLimit: 5000, autoDisconnect: true,
    devices: [
      { id: uid(), name: "dev.ac", icon: "Wind", relay: 1, on: true, ratedW: 1500 },
      { id: uid(), name: "dev.fridge", icon: "Refrigerator", relay: 2, on: true, ratedW: 250 },
      { id: uid(), name: "dev.kLight", icon: "Lightbulb", relay: 3, on: false, ratedW: 80 },
      { id: uid(), name: "dev.heater", icon: "Flame", relay: 4, on: false, ratedW: 1800 },
    ],
  },
  {
    id: "work", name: "init.office", type: "commercial", plan: "ultimate",
    powerLimit: 8000, autoDisconnect: false,
    devices: [
      { id: uid(), name: "dev.servers", icon: "Server", relay: 1, on: true, ratedW: 600 },
      { id: uid(), name: "dev.oLight", icon: "Lightbulb", relay: 2, on: true, ratedW: 220 },
      { id: uid(), name: "dev.acMain", icon: "Wind", relay: 3, on: true, ratedW: 2200 },
    ],
    business: { name: "SmartEnergy Co.", taxId: "LY-2025-0001", verified: true },
  },
];

export function StoreProvider({ children }: { children: ReactNode }) {
  const [spaces, setSpaces] = useState<Space[]>(initialSpaces);
  const [activeSpaceId, setActiveSpaceId] = useState<string>(initialSpaces[0].id);
  const activeSpace = spaces.find((s) => s.id === activeSpaceId) ?? spaces[0];

  const [live, setLive] = useState<LiveSnapshot>({
    power: 0, voltage: 230, current: 0, kwh: 124.6, bill: 0, history: [],
  });
  const [surgeUntil, setSurgeUntil] = useState<number>(0);
  const surgeActive = surgeUntil > Date.now();

  // Mock real-time stream
  const lastTick = useRef(Date.now());
  useEffect(() => {
    const id = setInterval(() => {
      const now = Date.now();
      const dtH = (now - lastTick.current) / 3_600_000;
      lastTick.current = now;

      const baseW = activeSpace.devices
        .filter((d) => d.on)
        .reduce((sum, d) => sum + d.ratedW * (0.85 + Math.random() * 0.3), 0);
      let power = Math.max(0, baseW + (Math.random() - 0.5) * 60);
      if (now < surgeUntil) {
        power = activeSpace.powerLimit * (1.4 + Math.random() * 0.3);
      }
      const voltage = 225 + Math.random() * 10;
      const current = power / voltage;

      setLive((prev) => {
        const kwh = prev.kwh + (power / 1000) * dtH;
        const history = [...prev.history, { t: now, w: power }].slice(-60);
        return {
          power,
          voltage,
          current,
          kwh,
          bill: kwh * RATE_LYD_PER_KWH,
          history,
        };
      });
    }, 1000);
    return () => clearInterval(id);
  }, [activeSpace, surgeUntil]);

  const overload = live.power > activeSpace.powerLimit;

  // Auto-disconnect simulation
  useEffect(() => {
    if (overload && activeSpace.autoDisconnect) {
      // turn off the highest-draw device after 3s
      const t = setTimeout(() => {
        setSpaces((prev) =>
          prev.map((s) => {
            if (s.id !== activeSpace.id) return s;
            const onDevs = s.devices.filter((d) => d.on).sort((a, b) => b.ratedW - a.ratedW);
            if (!onDevs.length) return s;
            const target = onDevs[0].id;
            return { ...s, devices: s.devices.map((d) => (d.id === target ? { ...d, on: false } : d)) };
          }),
        );
      }, 3000);
      return () => clearTimeout(t);
    }
  }, [overload, activeSpace]);

  const ctx: Ctx = useMemo(
    () => ({
      spaces,
      activeSpaceId: activeSpace.id,
      activeSpace,
      setActiveSpaceId,
      addSpace: (s) =>
        setSpaces((prev) => [
          ...prev,
          {
            id: uid(),
            name: s.name,
            type: s.type,
            plan: s.plan ?? "free",
            powerLimit: 5000,
            autoDisconnect: true,
            devices: [],
            business: s.business,
          },
        ]),
      updateSpace: (id, patch) =>
        setSpaces((prev) => prev.map((s) => (s.id === id ? { ...s, ...patch } : s))),
      addDevice: (spaceId, d) => {
        const sp = spaces.find((x) => x.id === spaceId);
        if (!sp) return { ok: false, reason: "space" };
        if (sp.devices.length >= PLANS[sp.plan].deviceLimit) return { ok: false, reason: "limit" };
        if (sp.devices.some((x) => x.relay === d.relay)) return { ok: false, reason: "relay" };
        setSpaces((prev) =>
          prev.map((s) =>
            s.id === spaceId ? { ...s, devices: [...s.devices, { ...d, id: uid(), on: false }] } : s,
          ),
        );
        return { ok: true };
      },
      updateDevice: (spaceId, deviceId, patch) => {
        const sp = spaces.find((x) => x.id === spaceId);
        if (!sp) return { ok: false, reason: "space" };
        if (patch.relay && sp.devices.some((x) => x.id !== deviceId && x.relay === patch.relay)) {
          return { ok: false, reason: "relay" };
        }
        setSpaces((prev) =>
          prev.map((s) =>
            s.id === spaceId
              ? { ...s, devices: s.devices.map((d) => (d.id === deviceId ? { ...d, ...patch } : d)) }
              : s,
          ),
        );
        return { ok: true };
      },
      removeDevice: (spaceId, deviceId) =>
        setSpaces((prev) =>
          prev.map((s) =>
            s.id === spaceId ? { ...s, devices: s.devices.filter((d) => d.id !== deviceId) } : s,
          ),
        ),
      toggleDevice: (spaceId, deviceId) =>
        setSpaces((prev) =>
          prev.map((s) =>
            s.id === spaceId
              ? { ...s, devices: s.devices.map((d) => (d.id === deviceId ? { ...d, on: !d.on } : d)) }
              : s,
          ),
        ),
      live,
      overload,
      surgeActive,
      triggerOverload: () => setSurgeUntil(Date.now() + 6000),
      resetCutoff: () => {
        setSurgeUntil(0);
        setSpaces((prev) =>
          prev.map((s) =>
            s.id === activeSpace.id
              ? { ...s, devices: s.devices.map((d) => ({ ...d, on: true })) }
              : s,
          ),
        );
      },
    }),
    [spaces, activeSpace, live, overload, surgeActive],
  );

  return <StoreCtx.Provider value={ctx}>{children}</StoreCtx.Provider>;
}

export function useStore() {
  const c = useContext(StoreCtx);
  if (!c) throw new Error("useStore must be used inside StoreProvider");
  return c;
}

export const ALL_RELAYS = [1, 2, 3, 4, 5, 6, 7, 8];

export const ICON_CHOICES = [
  "Wind", "Refrigerator", "Lightbulb", "Flame", "Tv", "WashingMachine",
  "Microwave", "Server", "Plug", "Fan", "Thermometer", "Coffee",
];

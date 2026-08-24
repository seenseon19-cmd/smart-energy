import { useStore } from "@/lib/store";
import { useSettings } from "@/lib/settings";
import { Check, ChevronDown, Home, Building2 } from "lucide-react";
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function SpaceSwitcher() {
  const { spaces, activeSpace, setActiveSpaceId } = useStore();
  const { t } = useSettings();
  return (
    <DropdownMenu>
      <DropdownMenuTrigger className="glass rounded-xl px-3 py-3 flex items-center gap-3 w-full hover:bg-white/5 transition">
        <div className="grid h-9 w-9 place-items-center rounded-lg bg-[color:var(--cyan-glow)]/15 text-[color:var(--cyan-glow)]">
          {activeSpace.type === "home" ? <Home className="h-4 w-4" /> : <Building2 className="h-4 w-4" />}
        </div>
        <div className="flex-1 text-right">
          <div className="text-xs text-muted-foreground">{t("header.activeSpace")}</div>
          <div className="font-semibold leading-tight">{t(activeSpace.name)}</div>
        </div>
        <ChevronDown className="h-4 w-4 text-muted-foreground" />
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        {spaces.map((s) => (
          <DropdownMenuItem key={s.id} onClick={() => setActiveSpaceId(s.id)} className="gap-2">
            {s.type === "home" ? <Home className="h-4 w-4" /> : <Building2 className="h-4 w-4" />}
            <span className="flex-1">{t(s.name)}</span>
            {s.id === activeSpace.id && <Check className="h-4 w-4 text-[color:var(--cyan-glow)]" />}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

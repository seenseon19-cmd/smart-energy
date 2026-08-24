import { useEffect, useRef } from "react";

export function AnimatedNumber({
  value,
  decimals = 0,
  className,
  suffix,
}: {
  value: number;
  decimals?: number;
  className?: string;
  suffix?: string;
}) {
  const ref = useRef<HTMLSpanElement>(null);
  const prev = useRef(value);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const start = prev.current;
    const end = value;
    const duration = 600;
    const t0 = performance.now();
    let raf = 0;
    const step = (now: number) => {
      const p = Math.min(1, (now - t0) / duration);
      const eased = 1 - Math.pow(1 - p, 3);
      const v = start + (end - start) * eased;
      el.textContent = v.toFixed(decimals) + (suffix ?? "");
      if (p < 1) raf = requestAnimationFrame(step);
      else prev.current = end;
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [value, decimals, suffix]);

  return <span ref={ref} className={className}>{value.toFixed(decimals)}{suffix}</span>;
}

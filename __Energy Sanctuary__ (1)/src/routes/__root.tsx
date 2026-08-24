import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet, Link, createRootRouteWithContext, useRouter, HeadContent, Scripts,
} from "@tanstack/react-router";
import appCss from "../styles.css?url";
import { StoreProvider } from "@/lib/store";
import { SettingsProvider } from "@/lib/settings";
import { Toaster } from "@/components/ui/sonner";
// شاشة البداية الفاخرة بشعار الشركة
import { SplashScreen } from "@/components/splash-screen";
// لافتة ترويجية تظهر مرة واحدة بعد تسجيل الدخول
import { PromoBanner } from "@/components/promo-banner";

function NotFoundComponent() {
  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <div className="glass max-w-md text-center rounded-3xl p-10">
        <h1 className="text-7xl font-extrabold gradient-text">404</h1>
        <h2 className="mt-4 text-xl font-semibold">الصفحة غير موجودة</h2>
        <p className="mt-2 text-sm text-muted-foreground">الصفحة التي تبحث عنها غير متاحة.</p>
        <Link to="/" className="mt-6 inline-flex rounded-xl bg-[color:var(--cyan-glow)] px-4 py-2 text-sm font-bold text-background glow-cyan">
          العودة للوحة
        </Link>
      </div>
    </div>
  );
}

function ErrorComponent({ error, reset }: { error: Error; reset: () => void }) {
  const router = useRouter();
  console.error(error);
  return (
    <div className="flex min-h-screen items-center justify-center px-4">
      <div className="glass max-w-md text-center rounded-3xl p-10">
        <h1 className="text-xl font-semibold">حدث خطأ</h1>
        <p className="mt-2 text-sm text-muted-foreground">{error.message}</p>
        <button
          onClick={() => { router.invalidate(); reset(); }}
          className="mt-6 rounded-xl bg-[color:var(--cyan-glow)] px-4 py-2 text-sm font-bold text-background"
        >
          إعادة المحاولة
        </button>
      </div>
    </div>
  );
}

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "SmartEnergy — لوحة التحكم بالطاقة الذكية" },
      { name: "description", content: "نظام تحكم وتتبع استهلاك الطاقة الذكي بتقنية إنترنت الأشياء" },
    ],
    links: [{ rel: "stylesheet", href: appCss }],
  }),
  shellComponent: RootShell,
  component: RootComponent,
  notFoundComponent: NotFoundComponent,
  errorComponent: ErrorComponent,
});

function RootShell({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl" className="dark">
      <head><HeadContent /></head>
      <body>{children}<Scripts /></body>
    </html>
  );
}

function RootComponent() {
  const { queryClient } = Route.useRouteContext();
  return (
    <QueryClientProvider client={queryClient}>
      <SettingsProvider>
        <StoreProvider>
          {/* شاشة البداية تظهر مرة واحدة عند تحميل التطبيق */}
          <SplashScreen />
          <PromoBanner />
          <Outlet />
          <Toaster />
        </StoreProvider>
      </SettingsProvider>
    </QueryClientProvider>
  );
}

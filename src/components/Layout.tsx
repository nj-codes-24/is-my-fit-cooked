import { NavLink, Outlet } from "react-router-dom";
import { Camera, Layers, Compass } from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const TABS = [
  { path: "/", icon: Camera, label: "Fit Check" },
  { path: "/closet", icon: Layers, label: "Closet" },
  { path: "/explore", icon: Compass, label: "Explore" },
];

export function Layout() {
  return (
    <div className="flex flex-col h-[100dvh] w-full max-w-md mx-auto relative overflow-hidden bg-zinc-950">
      {/* Dynamic Content Area */}
      <main className="flex-1 overflow-y-auto overflow-x-hidden pb-20">
        <Outlet />
      </main>

      {/* Bottom Navigation */}
      <nav className="absolute bottom-0 left-0 right-0 bg-[#1C1C1E]/60 backdrop-blur-2xl border-t border-white/10 pb-safe pt-2 px-6 shadow-[0_-8px_30px_rgba(0,0,0,0.3)]">
        <div className="flex justify-between items-center h-16">
          {TABS.map(({ path, icon: Icon, label }) => (
            <NavLink
              key={path}
              to={path}
              className={({ isActive }) =>
                cn(
                  "flex flex-col items-center justify-center w-full gap-1 transition-all duration-300",
                  isActive ? "text-white scale-110" : "text-white/40 hover:text-white/60"
                )
              }
            >
              {({ isActive }) => (
                <>
                  <Icon size={24} strokeWidth={isActive ? 2.5 : 2} className={cn("transition-transform", isActive && "drop-shadow-[0_0_8px_rgba(255,255,255,0.5)]")} />
                  <span className="text-[10px] font-medium tracking-wide uppercase">{label}</span>
                </>
              )}
            </NavLink>
          ))}
        </div>
      </nav>
    </div>
  );
}

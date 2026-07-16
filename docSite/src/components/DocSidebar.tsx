import { useEffect, useRef, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { docNavGroups } from '@/lib/docs-utils';
import { cn } from '@/lib/utils';

interface DocSidebarProps {
  isSidebarOpen: boolean;
  toggleSidebar: () => void;
}

const DocSidebar = ({ isSidebarOpen, toggleSidebar }: DocSidebarProps) => {
  const location = useLocation();
  const [isMobileViewport, setIsMobileViewport] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  // Track the same `md` breakpoint the drawer's CSS uses, so we only pull the closed drawer's
  // links out of the tab order on mobile — the desktop sidebar must stay focusable regardless
  // of `isSidebarOpen`, which is a mobile-only concept.
  useEffect(() => {
    const mql = window.matchMedia('(max-width: 767px)');
    const update = () => setIsMobileViewport(mql.matches);
    update();
    mql.addEventListener('change', update);
    return () => mql.removeEventListener('change', update);
  }, []);

  // `inert` isn't in this project's JSX typings yet, but it is a real DOM property — set it
  // imperatively so the closed mobile drawer's links drop out of the tab order without a cast.
  useEffect(() => {
    if (wrapperRef.current) {
      wrapperRef.current.inert = isMobileViewport && !isSidebarOpen;
    }
  }, [isMobileViewport, isSidebarOpen]);

  const isActive = (path: string) => location.pathname === path;

  return (
    <div ref={wrapperRef} className="sidebar-wrapper w-full">
      {docNavGroups.map((group) => (
        <div key={group.label} className="pb-6">
          <h4 className="mb-2 px-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">
            {group.label}
          </h4>
          <div className="grid grid-flow-row auto-rows-max gap-0.5 text-sm">
            {group.items.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  onClick={() => {
                    // Close the mobile drawer whenever a destination is picked.
                    if (window.innerWidth < 768) toggleSidebar();
                  }}
                  className={cn(
                    'group relative flex w-full items-center gap-2.5 rounded-md border border-transparent px-2 py-1.5',
                    'transition-colors before:absolute before:-left-2 before:top-1/2 before:h-4 before:w-0.5',
                    'before:-translate-y-1/2 before:rounded-full before:bg-primary before:transition-opacity',
                    active
                      ? 'bg-primary/10 font-medium text-primary before:opacity-100'
                      : 'text-muted-foreground before:opacity-0 hover:bg-accent hover:text-accent-foreground'
                  )}
                >
                  <Icon
                    className={cn(
                      'h-4 w-4 shrink-0 transition-colors',
                      active ? 'text-primary' : 'text-muted-foreground/70 group-hover:text-foreground'
                    )}
                  />
                  <span className="truncate">{item.title}</span>
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
};

export default DocSidebar;

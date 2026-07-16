import { Link } from 'react-router-dom';
import { Github, Menu, Search, ShieldCheck, X } from 'lucide-react';
import { ThemeToggle } from './ThemeToggle';
import { Button } from './ui/button';
import { useState } from 'react';
import { cn } from '@/lib/utils';
import { SearchCommand } from './SearchCommand';

interface HeaderProps {
  toggleSidebar: () => void;
  isSidebarOpen: boolean;
}

const Header = ({ toggleSidebar, isSidebarOpen }: HeaderProps) => {
  const [isSearchOpen, setIsSearchOpen] = useState(false);

  return (
    <>
      <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 max-w-screen-2xl items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="sidebar-toggle h-8 w-8 shrink-0 md:hidden"
            onClick={toggleSidebar}
            aria-label="Toggle navigation menu"
          >
            {isSidebarOpen ? <X className="h-4 w-4" /> : <Menu className="h-4 w-4" />}
          </Button>

          <Link to="/" className="mr-4 flex items-center gap-2 shrink-0">
            <ShieldCheck className="h-5 w-5 text-primary" />
            <span className="hidden font-bold sm:inline-block">
              Credential Manager
            </span>
          </Link>

          <div className="flex flex-1 items-center justify-end gap-2">
            <Button
              variant="outline"
              className="relative h-9 w-full max-w-[16rem] justify-start gap-2 rounded-lg bg-background text-sm font-normal text-muted-foreground shadow-none sm:pr-12"
              onClick={() => setIsSearchOpen(true)}
            >
              <Search className="h-4 w-4 shrink-0" />
              <span className="hidden lg:inline-flex">Search documentation...</span>
              <span className="inline-flex lg:hidden">Search...</span>
              <kbd className="pointer-events-none absolute right-1.5 top-1/2 hidden -translate-y-1/2 select-none items-center gap-1 rounded border bg-muted px-1.5 py-0.5 font-mono text-[10px] font-medium sm:flex">
                <span>⌘</span>K
              </kbd>
            </Button>

            <nav className="flex items-center">
              <Link
                to="https://github.com/djsmk123/flutter_credential_manager_compose"
                target="_blank"
                rel="noreferrer"
              >
                <div
                  className={cn(
                    'inline-flex h-9 w-9 items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors',
                    'hover:bg-accent hover:text-accent-foreground'
                  )}
                >
                  <Github className="h-4 w-4" />
                  <span className="sr-only">GitHub</span>
                </div>
              </Link>
              <ThemeToggle />
            </nav>
          </div>
        </div>
      </header>
      <SearchCommand open={isSearchOpen} setOpen={setIsSearchOpen} />
    </>
  );
};

export default Header;

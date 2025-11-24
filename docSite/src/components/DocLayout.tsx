import { PropsWithChildren, useEffect, useState } from 'react';
import DocSidebar from '@/components/DocSidebar';
import { Link, useLocation } from 'react-router-dom';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { docNavigation } from '@/lib/docs-utils';
import Footer from '@/components/Footer';
import { cn } from '@/lib/utils';
import { useSidebarToggle } from '@/hooks/useSidebarToggle';
import Header from './Header';
import TableOfContents from './TableOfContents';

type DocLayoutProps = PropsWithChildren

const DocLayout = ({ children }: DocLayoutProps) => {
  const { isSidebarOpen, toggleSidebar } = useSidebarToggle();
  const location = useLocation();
  const [scrollProgress, setScrollProgress] = useState(0);

  // Find current page index for prev/next navigation
  const currentIndex = docNavigation.findIndex(item => item.path === location.pathname);
  const prevPage = currentIndex > 0 ? docNavigation[currentIndex - 1] : null;
  const nextPage = currentIndex < docNavigation.length - 1 ? docNavigation[currentIndex + 1] : null;

  // Scroll to top on page change
  useEffect(() => {
    window.scrollTo(0, 0);
  }, [location.pathname]);

  // Handle scroll progress
  useEffect(() => {
    const handleScroll = () => {
      const totalHeight = document.documentElement.scrollHeight - window.innerHeight;
      const progress = (window.scrollY / totalHeight) * 100;
      setScrollProgress(progress);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="min-h-screen flex flex-col bg-background font-sans antialiased">
      {/* Progress bar */}
      <div className="fixed top-0 left-0 w-full h-1 z-[100]">
        <div 
          className="h-full bg-primary transition-all duration-300 ease-linear"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      <Header toggleSidebar={toggleSidebar} isSidebarOpen={isSidebarOpen} />

      <div className="flex-1 items-start md:grid md:grid-cols-[220px_minmax(0,1fr)] md:gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-10 container max-w-screen-2xl">
        <aside className={cn(
          "fixed top-14 z-30 -ml-2 hidden h-[calc(100vh-3.5rem)] w-full shrink-0 md:sticky md:block overflow-y-auto border-r border-border/40 pr-2 py-6 lg:py-8",
          isSidebarOpen && "block bg-background inset-0 z-50 w-full p-6 md:p-0"
        )}>
          <DocSidebar isSidebarOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
        </aside>
        
        <main className="relative py-6 lg:gap-10 lg:py-8 xl:grid xl:grid-cols-[1fr_300px]">
          <div className="mx-auto w-full min-w-0">
            <div className={cn(
              "prose prose-slate dark:prose-invert max-w-none",
              "animate-fade-in"
            )}>
              {children}

              {/* Previous/Next navigation */}
              <div className="mt-12 flex flex-row items-center justify-between gap-4 border-t pt-6 pb-6">
                {prevPage ? (
                  <Link
                    to={prevPage.path}
                    className="group flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground no-underline"
                  >
                    <ChevronLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" />
                    <span>{prevPage.title}</span>
                  </Link>
                ) : (
                  <div />
                )}

                {nextPage ? (
                  <Link
                    to={nextPage.path}
                    className="group flex items-center gap-2 text-sm font-medium text-muted-foreground transition-colors hover:text-foreground no-underline"
                  >
                    <span>{nextPage.title}</span>
                    <ChevronRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                  </Link>
                ) : (
                  <div />
                )}
              </div>
            </div>
            <Footer />
          </div>
          <TableOfContents />
        </main>
      </div>
    </div>
  );
};

export default DocLayout;

import { PropsWithChildren, useEffect, useState } from 'react';
import DocSidebar from '@/components/DocSidebar';
import { Link, useLocation } from 'react-router-dom';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { docNavigation } from '@/lib/docs-utils';
import Footer from '@/components/Footer';
import { cn } from '@/lib/utils';
import { useSidebarToggle } from '@/hooks/useSidebarToggle';
import { useIsMobile } from '@/hooks/use-mobile';
import { useDocHeadings } from '@/hooks/useDocHeadings';
import Header from './Header';
import TableOfContents, { MobileTableOfContents } from './TableOfContents';
import Breadcrumbs from './Breadcrumbs';
import BackToTop from './BackToTop';

type DocLayoutProps = PropsWithChildren

const DOC_CONTENT_ID = 'doc-article-content';

const DocLayout = ({ children }: DocLayoutProps) => {
  const { isSidebarOpen, toggleSidebar } = useSidebarToggle();
  const location = useLocation();
  const [scrollProgress, setScrollProgress] = useState(0);
  const isMobile = useIsMobile();
  // Owned once here and threaded down to both TableOfContents (desktop rail) and
  // MobileTableOfContents, which are both always mounted — calling the hook in each would run
  // its DOM scrape and IntersectionObserver twice for the same page.
  const { headings, activeId, setActiveId } = useDocHeadings();

  // Find current page index for prev/next navigation
  const currentIndex = docNavigation.findIndex(item => item.path === location.pathname);
  const prevPage = currentIndex > 0 ? docNavigation[currentIndex - 1] : null;
  const nextPage = currentIndex < docNavigation.length - 1 ? docNavigation[currentIndex + 1] : null;

  // Scroll to top on page change, and close the mobile drawer so it doesn't linger on navigate
  useEffect(() => {
    window.scrollTo(0, 0);
    if (isSidebarOpen) toggleSidebar();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location.pathname]);

  // Lock body scroll while the mobile drawer is open. Re-evaluated when `isMobile` flips (e.g.
  // rotating/resizing past `md` with the drawer still open), so it releases the lock instead of
  // leaving the desktop page unscrollable.
  useEffect(() => {
    if (!isSidebarOpen) return;

    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = isMobile ? 'hidden' : previousOverflow;
    return () => {
      document.body.style.overflow = previousOverflow;
    };
  }, [isSidebarOpen, isMobile]);

  // Handle scroll progress
  useEffect(() => {
    const handleScroll = () => {
      const totalHeight = document.documentElement.scrollHeight - window.innerHeight;
      const progress = totalHeight > 0 ? (window.scrollY / totalHeight) * 100 : 0;
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

      {/* Mobile backdrop, dismisses the drawer on tap */}
      <div
        aria-hidden="true"
        onClick={toggleSidebar}
        className={cn(
          'fixed inset-0 top-14 z-40 bg-background/80 backdrop-blur-sm transition-opacity md:hidden',
          isSidebarOpen ? 'opacity-100' : 'pointer-events-none opacity-0'
        )}
      />

      <div className="flex-1 items-start md:grid md:grid-cols-[220px_minmax(0,1fr)] md:gap-6 lg:grid-cols-[240px_minmax(0,1fr)] lg:gap-10 container max-w-screen-2xl">
        <aside
          className={cn(
            'fixed top-14 z-50 h-[calc(100vh-3.5rem)] w-full max-w-xs shrink-0 overflow-y-auto border-r',
            'border-border/40 bg-background px-6 py-6 shadow-xl transition-transform duration-300 ease-in-out',
            'md:sticky md:z-30 md:w-full md:max-w-none md:translate-x-0 md:border-r-0 md:bg-transparent',
            'md:px-0 md:pr-2 md:shadow-none lg:py-8',
            isSidebarOpen ? 'translate-x-0' : '-translate-x-full'
          )}
        >
          <DocSidebar isSidebarOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
        </aside>

        <main className="relative py-6 lg:gap-10 lg:py-8 xl:grid xl:grid-cols-[1fr_300px]">
          <div className="mx-auto w-full min-w-0">
            <Breadcrumbs contentId={DOC_CONTENT_ID} />
            <MobileTableOfContents headings={headings} activeId={activeId} setActiveId={setActiveId} />
            <article
              id={DOC_CONTENT_ID}
              className={cn(
                'prose prose-slate dark:prose-invert max-w-none',
                'animate-fade-in'
              )}
            >
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
            </article>
            <Footer />
          </div>
          <TableOfContents headings={headings} activeId={activeId} setActiveId={setActiveId} />
        </main>
      </div>
      <BackToTop />
    </div>
  );
};

export default DocLayout;

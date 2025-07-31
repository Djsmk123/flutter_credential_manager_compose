import { PropsWithChildren, useEffect, useState } from 'react';
import DocSidebar from '@/components/DocSidebar';
import { Link, useLocation } from 'react-router-dom';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { docNavigation } from '@/lib/docs-utils';
import Footer from '@/components/Footer';
import { cn } from '@/lib/utils';
import { useSidebarToggle } from '@/hooks/useSidebarToggle';

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
    <div className="min-h-screen flex flex-col bg-gray-50 dark:bg-gray-950 transition-colors duration-300">
      {/* Progress bar */}
      <div className="fixed top-0 left-0 w-full h-1 z-50">
        <div 
          className="h-full bg-blue-600 dark:bg-blue-500 transition-all duration-300 ease-linear"
          style={{ width: `${scrollProgress}%` }}
        />
      </div>

      <div className="flex min-h-screen">
        <DocSidebar isSidebarOpen={isSidebarOpen} toggleSidebar={toggleSidebar} />
        
        <div className="flex-1 flex flex-col min-w-0">
          <main className="flex-grow mx-auto w-full max-w-5xl px-3 sm:px-4 lg:px-8 py-4 sm:py-8">
            <div className={cn(
              "bg-white dark:bg-gray-900 rounded-lg shadow-sm p-4 sm:p-6 lg:p-8 mb-6 sm:mb-8",
              "doc-content prose prose-blue dark:prose-invert max-w-none",
              "animate-fade-in"
            )}>
              {children}

              {/* Previous/Next navigation */}
              <div className="mt-12 sm:mt-16 border-t border-gray-200 dark:border-gray-800 pt-4 sm:pt-6 flex flex-col sm:flex-row justify-between gap-4">
                {prevPage ? (
                  <Link
                    to={prevPage.path}
                    className="inline-flex items-center text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 no-underline group transition-all duration-200 text-sm sm:text-base"
                  >
                    <ChevronLeft size={18} className="mr-1 group-hover:-translate-x-1 transition-transform duration-200" />
                    <span className="truncate">{prevPage.title}</span>
                  </Link>
                ) : (
                  <div />
                )}

                {nextPage ? (
                  <Link
                    to={nextPage.path}
                    className="inline-flex items-center text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 no-underline group transition-all duration-200 text-sm sm:text-base"
                  >
                    <span className="truncate">{nextPage.title}</span>
                    <ChevronRight size={18} className="ml-1 group-hover:translate-x-1 transition-transform duration-200" />
                  </Link>
                ) : (
                  <div />
                )}
              </div>
            </div>
          </main>
          
          <Footer />
        </div>
      </div>
    </div>
  );
};

export default DocLayout;

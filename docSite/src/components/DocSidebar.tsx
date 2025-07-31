import React, { useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { docNavigation } from '@/lib/docs-utils';
import { Menu, X, Github } from 'lucide-react';
import { ThemeToggle } from './ThemeToggle';
import { cn } from '@/lib/utils';
import { useTheme } from './ThemeProvider';
import { motion, AnimatePresence } from 'framer-motion';

interface DocSidebarProps {
  isSidebarOpen: boolean;
  toggleSidebar: () => void;
}

const DocSidebar = ({ isSidebarOpen, toggleSidebar }: DocSidebarProps) => {
  const location = useLocation();
  const { theme } = useTheme();
  const currentYear = new Date().getFullYear();
  
  const isActive = (path: string) => {
    return location.pathname === path;
  };
  
  useEffect(() => {
    if (window.innerWidth < 1024 && isSidebarOpen) {
      toggleSidebar();
    }
  }, [location.pathname]);

  return (
    <>
      {/* Mobile Menu Button - Fixed at top right */}
      <motion.div 
        className="lg:hidden fixed top-4 right-4 z-40"
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.3 }}
      >
        <button
          className={cn(
            "sidebar-toggle p-3 rounded-full shadow-lg transition-all duration-300",
            "bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300",
            "hover:bg-gray-50 dark:hover:bg-gray-700",
            "border border-gray-200 dark:border-gray-600",
            "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-900"
          )}
          onClick={toggleSidebar}
          aria-label="Toggle navigation menu"
          aria-expanded={isSidebarOpen}
        >
          <Menu size={20} className="transition-transform duration-200" />
        </button>
      </motion.div>

      {/* Mobile overlay */}
      <AnimatePresence>
        {isSidebarOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-30"
            onClick={toggleSidebar}
          />
        )}
      </AnimatePresence>

      <AnimatePresence>
        {(isSidebarOpen || window.innerWidth >= 1024) && (
          <motion.div
            initial={{ x: -288 }} // w-72 = 288px
            animate={{ x: 0 }}
            exit={{ x: -288 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            className={cn(
              "sidebar-wrapper fixed inset-y-0 left-0 z-40 w-72 bg-gray-100 dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 lg:translate-x-0 shadow-xl lg:shadow-none",
              "lg:sticky lg:top-0 lg:h-screen lg:z-0"
            )}
          >
            <div className="h-full overflow-y-auto scrollbar-thin">
              <motion.div 
                className="sticky top-0 z-10 bg-gray-100 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 p-3 sm:p-4"
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                <div className="flex justify-between items-center">
                  <Link to="/" className="flex items-center gap-2 group">
                    <span className="font-bold text-lg sm:text-xl text-gray-900 dark:text-gray-100">Credential Manager</span>
                  </Link>
                  <div className="flex items-center gap-2">
                    <ThemeToggle />
                    <button
                      onClick={toggleSidebar}
                      className="lg:hidden p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 rounded-md hover:bg-gray-200 dark:hover:bg-gray-800 transition-colors"
                      aria-label="Close sidebar"
                    >
                      <X size={18} />
                    </button>
                  </div>
                </div>
              </motion.div>

              <motion.div 
                className="p-3 sm:p-4"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
              >
                <nav className="mt-2">
                  <ul className="space-y-1">
                    {docNavigation.map((item, index) => {
                      const active = isActive(item.path);
                      return (
                        <motion.li 
                          key={item.path} 
                          className="transform transition-transform duration-200 hover:translate-x-1"
                          initial={{ opacity: 0, x: -20 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.1 * index }}
                        >
                          <Link
                            to={item.path}
                            className={cn(
                              "block px-3 py-2 rounded-md transition-all duration-200 text-sm sm:text-base",
                              active
                                ? "bg-blue-500/10 text-blue-700 dark:text-blue-400 font-medium border-l-2 border-blue-500"
                                : "text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-800/50"
                            )}
                          >
                            {item.title}
                          </Link>
                        </motion.li>
                      );
                    })}
                  </ul>
                </nav>

                <motion.div 
                  className="mt-6 sm:mt-8 pt-4 border-t border-gray-200 dark:border-gray-800"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5 }}
                >
                  <a
                    href="https://github.com/Djsmk123/flutter_credential_manager_compose"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 px-3 py-2 rounded-md hover:bg-gray-200 dark:hover:bg-gray-800/50 transition-colors text-sm sm:text-base"
                  >
                    <Github size={16} />
                    <span>GitHub Repository</span>
                  </a>
                </motion.div>

                <motion.div 
                  className="mt-4 sm:mt-6 text-xs text-gray-500 dark:text-gray-400 px-3"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.6 }}
                >
                  <p>© 2024-{currentYear} Credential Manager</p>
                  <p className="mt-1">Build with ❤️ by <a href="https://github.com/Djsmk123" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300">Djsmk123</a></p>
                </motion.div>
              </motion.div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

export default DocSidebar;
  
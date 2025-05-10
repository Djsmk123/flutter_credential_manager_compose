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
      <motion.div 
        className="lg:hidden fixed top-4 left-4 z-30"
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ duration: 0.3 }}
      >
        <button
          className="sidebar-toggle p-2 bg-blue-600 text-white rounded-md shadow-md hover:bg-blue-700 transition-colors"
          onClick={toggleSidebar}
          aria-label="Toggle sidebar"
        >
          <Menu size={20} />
        </button>
      </motion.div>

      <AnimatePresence>
        {(isSidebarOpen || window.innerWidth >= 1024) && (
          <motion.div
            initial={{ x: -288 }} // w-72 = 288px
            animate={{ x: 0 }}
            exit={{ x: -288 }}
            transition={{ type: "spring", stiffness: 300, damping: 30 }}
            className={cn(
              "sidebar-wrapper fixed inset-y-0 left-0 z-20 w-72 bg-gray-100 dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 lg:translate-x-0 shadow-lg lg:shadow-none",
              "lg:sticky lg:top-0 lg:h-screen lg:z-0"
            )}
          >
            <div className="h-full overflow-y-auto scrollbar-thin">
              <motion.div 
                className="sticky top-0 z-10 bg-gray-100 dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 p-4"
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                <div className="flex justify-between items-center">
                  <Link to="/" className="flex items-center gap-2 group">
                    <span className="font-bold text-xl text-gray-900 dark:text-gray-100">Credential Manager</span>
                  </Link>
                  <div className="flex items-center gap-2">
                    <ThemeToggle />
                    <button
                      onClick={toggleSidebar}
                      className="lg:hidden p-1.5 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
                      aria-label="Close sidebar"
                    >
                      <X size={20} />
                    </button>
                  </div>
                </div>
              </motion.div>

              <motion.div 
                className="p-4"
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
                              "block px-3 py-2 rounded-md transition-all duration-200",
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
                  className="mt-8 pt-4 border-t border-gray-200 dark:border-gray-800"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5 }}
                >
                  <a
                    href="https://github.com/Djsmk123/flutter_credential_manager_compose"
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 px-3 py-2 rounded-md hover:bg-gray-200 dark:hover:bg-gray-800/50 transition-colors"
                  >
                    <Github size={18} />
                    <span>GitHub Repository</span>
                  </a>
                </motion.div>

                <motion.div 
                  className="mt-6 text-xs text-gray-500 dark:text-gray-400 px-3"
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
  
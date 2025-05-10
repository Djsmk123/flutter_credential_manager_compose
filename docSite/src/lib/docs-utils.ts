
import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';

// Define the navigation structure
export const docNavigation = [
  { title: 'Home', path: '/' },
  { title: 'Installation', path: '/installation' },
  { title: 'Configuration', path: '/configuration' },
  { title: 'Usage', path: '/usage' },
  { title: 'API Reference', path: '/api-reference' },
  { title: 'Examples', path: '/examples' },
  { title: 'FAQ', path: '/faq' },
  { title: 'Contributing', path: '/contributing' },
  { title: 'Changelog', path: '/changelog' },
  { title: 'Migration', path: '/migration' },
  { title: 'Blogs', path: '/blogs' },
  { title: 'React Native', path: '/react-native' }
];

// Hook to check if sidebar should be open on mobile
export function useSidebarToggle() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };
  
  // Close sidebar when clicking outside on mobile
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (isSidebarOpen && (event.target as HTMLElement).closest('.sidebar-wrapper') === null && (event.target as HTMLElement).closest('.sidebar-toggle') === null) {
        setIsSidebarOpen(false);
      }
    };
    
    document.addEventListener('click', handleClickOutside);
    return () => {
      document.removeEventListener('click', handleClickOutside);
    };
  }, [isSidebarOpen]);
  
  return { isSidebarOpen, toggleSidebar };
}

// Hook to get current path and highlight active nav item
export function useActiveNavItem() {
  const location = useLocation();
  
  const isActive = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };
  
  return { isActive };
}

// Format the section titles correctly
export function formatTitle(title: string): string {
  switch (title) {
    case 'api-reference':
      return 'API Reference';
    case 'react-native':
      return 'React Native';
    case 'faq':
      return 'FAQ';
    default:
      return title.charAt(0).toUpperCase() + title.slice(1);
  }
}

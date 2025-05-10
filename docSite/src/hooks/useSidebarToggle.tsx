
import { useState } from 'react';

export function useSidebarToggle() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const toggleSidebar = () => {
    setIsSidebarOpen((prev) => !prev);
  };

  return { isSidebarOpen, toggleSidebar };
}

import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';

const WORDS_PER_MINUTE = 200;

// Estimates reading time from the rendered word count of a container, re-measured on navigation.
export function useReadingTime(containerId: string) {
  const [minutes, setMinutes] = useState<number | null>(null);
  const location = useLocation();

  useEffect(() => {
    const timer = setTimeout(() => {
      const el = document.getElementById(containerId);
      if (!el) return;
      const words = el.textContent?.trim().split(/\s+/).filter(Boolean).length ?? 0;
      setMinutes(Math.max(1, Math.round(words / WORDS_PER_MINUTE)));
    }, 100);

    return () => clearTimeout(timer);
  }, [location.pathname, containerId]);

  return minutes;
}

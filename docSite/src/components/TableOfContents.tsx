import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';
import { useLocation } from 'react-router-dom';

interface TocItem {
  id: string;
  text: string;
  level: number;
}

const TableOfContents = () => {
  const [headings, setHeadings] = useState<TocItem[]>([]);
  const [activeId, setActiveId] = useState<string>('');
  const location = useLocation();

  useEffect(() => {
    // Small delay to ensure content is rendered
    const timer = setTimeout(() => {
      const elements = Array.from(document.querySelectorAll('h2, h3'));
      
      const items = elements.map((element) => {
        // Generate ID if missing
        if (!element.id) {
          const slug = element.textContent
            ?.toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/(^-|-$)+/g, '');
          element.id = slug || `heading-${Math.random().toString(36).substr(2, 9)}`;
        }

        return {
          id: element.id,
          text: element.textContent || '',
          level: Number(element.tagName.substring(1)),
        };
      });

      setHeadings(items);

      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              setActiveId(entry.target.id);
            }
          });
        },
        { rootMargin: '0px 0px -80% 0px' }
      );

      elements.forEach((element) => {
        observer.observe(element);
      });

      return () => observer.disconnect();
    }, 100); // 100ms delay to allow for rendering

    return () => clearTimeout(timer);
  }, [location.pathname]); // Re-run when path changes

  if (headings.length === 0) return null;

  return (
    <div className="hidden xl:block">
      <div className="sticky top-20 -mt-10 h-[calc(100vh-3.5rem)] overflow-hidden pt-6">
        <div className="space-y-2">
          <p className="font-medium text-sm text-foreground">On This Page</p>
          <ul className="m-0 list-none">
            {headings.map((heading) => (
              <li key={heading.id} className="mt-0 pt-2">
                <a
                  href={`#${heading.id}`}
                  onClick={(e) => {
                    e.preventDefault();
                    document.getElementById(heading.id)?.scrollIntoView({
                      behavior: 'smooth'
                    });
                    setActiveId(heading.id);
                    window.history.pushState(null, '', `#${heading.id}`);
                  }}
                  className={cn(
                    "inline-block no-underline transition-colors hover:text-foreground text-sm",
                    heading.level === 3 && "pl-4",
                    activeId === heading.id
                      ? "font-medium text-foreground"
                      : "text-muted-foreground"
                  )}
                >
                  {heading.text}
                </a>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default TableOfContents;

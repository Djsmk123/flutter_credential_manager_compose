import { ChevronDown, ListTree } from 'lucide-react';
import { useLocation } from 'react-router-dom';
import { cn } from '@/lib/utils';
import { buildHeadingUrl, setHeadingHash, useDocHeadings, type TocItem } from '@/hooks/useDocHeadings';

interface TocLinksProps {
  headings: TocItem[];
  activeId: string;
  onSelect: (id: string) => void;
}

const TocLinks = ({ headings, activeId, onSelect }: TocLinksProps) => {
  const location = useLocation();

  return (
    <ul className="m-0 list-none space-y-2">
      {headings.map((heading) => (
        <li key={heading.id} className="mt-0">
          <a
            href={`#${buildHeadingUrl(location.pathname, location.search, heading.id)}`}
            onClick={(e) => {
              e.preventDefault();
              document.getElementById(heading.id)?.scrollIntoView({ behavior: 'smooth' });
              onSelect(heading.id);
              setHeadingHash(location.pathname, location.search, heading.id);
            }}
            className={cn(
              'inline-block no-underline transition-colors hover:text-foreground text-sm',
              heading.level === 3 && 'pl-4',
              activeId === heading.id ? 'font-medium text-primary' : 'text-muted-foreground'
            )}
          >
            {heading.text}
          </a>
        </li>
      ))}
    </ul>
  );
};

// Sticky right-hand rail shown on wide (xl+) viewports.
const TableOfContents = () => {
  const { headings, activeId, setActiveId } = useDocHeadings();

  if (headings.length === 0) return null;

  return (
    <div className="hidden xl:block">
      <div className="sticky top-20 -mt-10 h-[calc(100vh-3.5rem)] overflow-y-auto pt-6">
        <div className="space-y-3">
          <p className="flex items-center gap-1.5 text-sm font-medium text-foreground">
            <ListTree className="h-3.5 w-3.5" />
            On This Page
          </p>
          <TocLinks headings={headings} activeId={activeId} onSelect={setActiveId} />
        </div>
      </div>
    </div>
  );
};

// Collapsible "On this page" panel for mobile/tablet, where the rail is hidden.
export const MobileTableOfContents = () => {
  const { headings, activeId, setActiveId } = useDocHeadings();

  if (headings.length === 0) return null;

  return (
    <details className="group/toc mb-8 rounded-lg border border-border bg-muted/30 xl:hidden">
      <summary className="flex cursor-pointer list-none items-center justify-between px-4 py-3 text-sm font-medium marker:content-none [&::-webkit-details-marker]:hidden">
        <span className="flex items-center gap-1.5">
          <ListTree className="h-3.5 w-3.5" />
          On this page
        </span>
        <ChevronDown className="h-4 w-4 transition-transform group-open/toc:rotate-180" />
      </summary>
      <div className="border-t border-border/60 px-4 pb-4 pt-3">
        <TocLinks headings={headings} activeId={activeId} onSelect={setActiveId} />
      </div>
    </details>
  );
};

export default TableOfContents;

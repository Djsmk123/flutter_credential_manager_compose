import { Link, useLocation } from 'react-router-dom';
import { ChevronRight, Clock, Pencil } from 'lucide-react';
import { docNavGroups, docNavigation } from '@/lib/docs-utils';
import { useReadingTime } from '@/hooks/useReadingTime';

const GITHUB_EDIT_BASE =
  'https://github.com/djsmk123/flutter_credential_manager_compose/edit/main/docSite/src/pages/';

interface BreadcrumbsProps {
  contentId: string;
}

const Breadcrumbs = ({ contentId }: BreadcrumbsProps) => {
  const location = useLocation();
  const current = docNavigation.find((item) => item.path === location.pathname);
  const group = docNavGroups.find((g) => g.items.some((item) => item.path === location.pathname));
  const minutes = useReadingTime(contentId);

  if (!current) return null;

  return (
    <div className="mb-6 flex flex-wrap items-center justify-between gap-3 border-b border-border/60 pb-4">
      <nav aria-label="Breadcrumb" className="flex items-center gap-1.5 text-sm text-muted-foreground">
        <Link to="/" className="no-underline transition-colors hover:text-foreground">
          Docs
        </Link>
        {group && current.path !== '/' && (
          <>
            <ChevronRight className="h-3.5 w-3.5" />
            <span>{group.label}</span>
          </>
        )}
        {current.path !== '/' && (
          <>
            <ChevronRight className="h-3.5 w-3.5" />
            <span className="font-medium text-foreground">{current.title}</span>
          </>
        )}
      </nav>

      <div className="flex items-center gap-4 text-xs text-muted-foreground">
        {minutes && (
          <span className="flex items-center gap-1">
            <Clock className="h-3.5 w-3.5" />
            {minutes} min read
          </span>
        )}
        <a
          href={`${GITHUB_EDIT_BASE}${current.file}`}
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 no-underline transition-colors hover:text-foreground"
        >
          <Pencil className="h-3.5 w-3.5" />
          Edit this page
        </a>
      </div>
    </div>
  );
};

export default Breadcrumbs;

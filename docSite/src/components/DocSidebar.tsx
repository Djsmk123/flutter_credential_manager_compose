import { Link, useLocation } from 'react-router-dom';
import { docNavigation } from '@/lib/docs-utils';
import { cn } from '@/lib/utils';

interface DocSidebarProps {
  isSidebarOpen: boolean;
  toggleSidebar: () => void;
}

const DocSidebar = ({}: DocSidebarProps) => {
  const location = useLocation();
  
  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <div className="w-full">
      <div className="pb-4">
        <h4 className="mb-1 rounded-md px-2 py-1 text-sm font-semibold">
          Documentation
        </h4>
        <div className="grid grid-flow-row auto-rows-max text-sm">
          {docNavigation.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={cn(
                "group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline",
                isActive(item.path)
                  ? "font-medium text-foreground"
                  : "text-muted-foreground"
              )}
            >
              {item.title}
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
};

export default DocSidebar;